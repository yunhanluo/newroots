/**
 * Content moderation for mutual support group posts and replies.
 *
 * Firestore onCreate hooks hide new threads from other members until they
 * pass: local PII/scam rules, OpenAI Moderation, and a community-policy LLM
 * check. Authors still see pending/rejected items with a plain-language reason.
 */
import {
  FieldValue,
  type DocumentReference,
  type QueryDocumentSnapshot,
} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {initializeApp, getApps} from "firebase-admin/app";
import {defineSecret} from "firebase-functions/params";
import type {FirestoreEvent} from "firebase-functions/v2/firestore";

if (getApps().length === 0) {
  initializeApp();
}

const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

export const groupModerationTriggerOptions = {
  region: "us-west1" as const,
  secrets: [OPENAI_API_KEY],
  timeoutSeconds: 60,
  memory: "512MiB" as const,
};

export type ModerationCategory =
  | "ok"
  | "pii"
  | "scam"
  | "hate"
  | "harassment"
  | "sexual"
  | "self_harm"
  | "violence"
  | "other";

export interface ModerationDecision {
  allowed: boolean;
  category: ModerationCategory;
  reason: string;
  message: string;
  sources: string[];
}

const USER_MESSAGES: Record<ModerationCategory, string> = {
  ok: "",
  pii:
    "This looks like a real ID or account number. Please remove the " +
    "number and try again. You can still talk about the topic.",
  scam:
    "This looks like it could be asking people for money or personal " +
    "details. Please keep the group free of sales and suspicious offers.",
  hate: "Please keep this group respectful. Unkind or hateful posts are not allowed.",
  harassment:
    "Please keep this group respectful. Harassment is not allowed.",
  sexual:
    "This post does not fit a family support group. Please keep posts appropriate.",
  self_harm:
    "If you are in crisis, call or text 988 in the US. This was hidden " +
    "because it may include harmful content.",
  violence: "Violent content is not allowed in this group.",
  other:
    "This did not meet our community guidelines. Please rewrite it and try again.",
};

interface LocalRule {
  category: Exclude<ModerationCategory, "ok">;
  pattern: RegExp;
}

const LOCAL_RULES: LocalRule[] = [
  // Actual SSN/ITIN shape (123-45-6789), not the words.
  {category: "pii", pattern: /\b\d{3}-\d{2}-\d{4}\b/},
  // 16-digit card shape with separators.
  {category: "pii", pattern: /\b(?:\d{4}[ -]){3}\d{4}\b/},
  {
    category: "scam",
    pattern:
      /\b(gift ?cards?|western union|moneygram|wire transfer)\b.{0,80}\b(send|pay|buy|purchase|deposit)\b/i,
  },
  {
    category: "scam",
    pattern:
      /\b(send|pay|buy|purchase|deposit)\b.{0,80}\b(gift ?cards?|western union|moneygram|wire transfer)\b/i,
  },
  {
    category: "scam",
    pattern:
      /\b(green card|work permit|visa|citizenship)s?\b.{0,20}\b(for sale|guaranteed)\b/i,
  },
  {
    category: "scam",
    pattern: /\bbuy (a )?(green card|work permit|visa|citizenship)\b/i,
  },
  {
    category: "scam",
    pattern:
      /\bi can (get|make|guarantee) you (a )?(papers?|green card|visa|work permit)\b/i,
  },
  {
    category: "pii",
    pattern:
      /\bsend me your (password|ssn|itin|passport|green card|id)\b/i,
  },
];

const COMMUNITY_PROMPT =
  "You review posts in a mutual support group for immigrant families in " +
  "California. Allow everyday help, job and housing questions, emotional " +
  "support, cultural sharing, scam warnings, and ordinary talk about " +
  "Social Security, ITIN, green cards, visas, work permits, and " +
  "immigration status. " +
  "Reject only clear violations: pasted ID or account numbers, asking " +
  "someone to send passwords or documents, selling immigration papers, " +
  "soliciting money via gift cards or wire transfer, hate, harassment, " +
  "sexual content, graphic violence, or fraud. " +
  "When unsure, allow. Mentioning 'social security', 'SSN', or 'green card' " +
  "without a real number is not a violation. " +
  "Respond with ONLY valid JSON: " +
  "{\"allowed\":boolean,\"category\":\"ok\"|\"pii\"|\"scam\"|\"hate\"|" +
  "\"harassment\"|\"sexual\"|\"self_harm\"|\"violence\"|\"other\"," +
  "\"reason\":string}.";

export function checkLocalPolicy(text: string): ModerationDecision | null {
  const haystack = text.trim();
  if (!haystack) return null;
  for (const rule of LOCAL_RULES) {
    if (rule.pattern.test(haystack)) {
      return reject(rule.category, `local:${rule.category}`, ["local"]);
    }
  }
  return null;
}

function reject(
  category: Exclude<ModerationCategory, "ok">,
  reason: string,
  sources: string[],
): ModerationDecision {
  return {
    allowed: false,
    category,
    reason,
    message: USER_MESSAGES[category],
    sources,
  };
}

function allow(sources: string[]): ModerationDecision {
  return {
    allowed: true,
    category: "ok",
    reason: "",
    message: "",
    sources,
  };
}

function imagePathsFromData(data: Record<string, unknown>): string[] {
  const paths: string[] = [];
  const raw = data.imagePaths;
  if (Array.isArray(raw)) {
    for (const item of raw) {
      const path = `${item}`.trim();
      if (path) paths.push(path);
    }
  }
  if (paths.length === 0) {
    const legacy = `${data.imagePath ?? ""}`.trim();
    if (legacy) paths.push(legacy);
  }
  return paths.slice(0, 6);
}

function assertGroupImagePath(groupId: string, path: string): string | null {
  const clean = path.trim().replace(/^\/+/, "");
  const prefix = `group-posts/${groupId}/`;
  if (!clean.startsWith(prefix) || clean.includes("..")) return null;
  return clean;
}

function mimeFromPath(path: string): string {
  const lower = path.toLowerCase();
  if (lower.endsWith(".png")) return "image/png";
  if (lower.endsWith(".webp")) return "image/webp";
  if (lower.endsWith(".gif")) return "image/gif";
  return "image/jpeg";
}

type ModerationInput =
  | {type: "text"; text: string}
  | {type: "image_url"; image_url: {url: string}};

interface OpenAiModerationResult {
  flagged: boolean;
  categories?: Record<string, boolean>;
}

function categoryFromOpenAi(
  categories: Record<string, boolean> | undefined,
): Exclude<ModerationCategory, "ok"> {
  if (!categories) return "other";
  if (categories["sexual/minors"] || categories.sexual) return "sexual";
  if (
    categories["self-harm/instructions"] ||
    categories["self-harm/intent"] ||
    categories["self-harm"]
  ) {
    return "self_harm";
  }
  if (categories["hate/threatening"] || categories.hate) return "hate";
  if (categories["harassment/threatening"] || categories.harassment) {
    return "harassment";
  }
  if (categories["violence/graphic"] || categories.violence) return "violence";
  if (categories["illicit/violent"]) return "violence";
  return "other";
}

async function loadGroupImage(
  groupId: string,
  rawPath: string,
): Promise<ModerationInput | null> {
  const path = assertGroupImagePath(groupId, rawPath);
  if (!path) return null;
  try {
    const file = getStorage().bucket().file(path);
    const [exists] = await file.exists();
    if (!exists) return null;
    const [buffer] = await file.download();
    if (buffer.byteLength > 4 * 1024 * 1024) {
      console.warn("Skipping oversized group image for moderation", path);
      return null;
    }
    return {
      type: "image_url",
      image_url: {url: `data:${mimeFromPath(path)};base64,${buffer.toString("base64")}`},
    };
  } catch (error) {
    console.warn("Could not load group post image for moderation", path, error);
    return null;
  }
}

async function callOpenAiModeration(
  apiKey: string,
  input: ModerationInput[],
): Promise<OpenAiModerationResult | null> {
  if (input.length === 0) return null;
  const response = await fetch("https://api.openai.com/v1/moderations", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "omni-moderation-latest",
      input,
    }),
  });
  const bodyText = await response.text();
  if (!response.ok) {
    console.error("OpenAI moderation error", response.status, bodyText);
    throw new Error(`OpenAI moderation HTTP ${response.status}`);
  }
  const json = JSON.parse(bodyText) as {
    results?: OpenAiModerationResult[];
  };
  const results = json.results ?? [];
  const flagged = results.find((item) => item.flagged);
  return flagged ?? results[0] ?? {flagged: false};
}

function parseCategory(raw: unknown): ModerationCategory {
  const value = `${raw ?? ""}`.trim().toLowerCase();
  switch (value) {
  case "ok":
  case "pii":
  case "scam":
  case "hate":
  case "harassment":
  case "sexual":
  case "self_harm":
  case "violence":
  case "other":
    return value;
  default:
    return "other";
  }
}

async function callCommunityLlm(
  apiKey: string,
  text: string,
): Promise<ModerationDecision | null> {
  const clipped = text.trim().slice(0, 4000);
  if (!clipped) return null;
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "gpt-4o-mini",
      temperature: 0,
      response_format: {type: "json_object"},
      messages: [
        {role: "system", content: COMMUNITY_PROMPT},
        {role: "user", content: clipped},
      ],
    }),
  });
  const bodyText = await response.text();
  if (!response.ok) {
    console.error("OpenAI community check error", response.status, bodyText);
    throw new Error(`OpenAI community check HTTP ${response.status}`);
  }
  const json = JSON.parse(bodyText) as {
    choices?: {message?: {content?: string}}[];
  };
  const content = json.choices?.[0]?.message?.content?.trim();
  if (!content) return null;
  let parsed: Record<string, unknown>;
  try {
    parsed = JSON.parse(content) as Record<string, unknown>;
  } catch {
    console.error("Community check JSON parse failed", content);
    return null;
  }
  const allowed = parsed.allowed !== false;
  const category = parseCategory(parsed.category);
  if (allowed || category === "ok") {
    return allow(["llm"]);
  }
  return reject(
    category,
    `${parsed.reason ?? "community policy"}`.trim().slice(0, 200),
    ["llm"],
  );
}

export async function evaluateGroupContent(input: {
  groupId: string;
  title?: string;
  text?: string;
  imagePaths?: string[];
}): Promise<ModerationDecision> {
  const title = (input.title ?? "").trim();
  const text = (input.text ?? "").trim();
  const combined = [title, text].filter(Boolean).join("\n");
  const sources: string[] = [];

  const local = checkLocalPolicy(combined);
  if (local) return local;

  const apiKey = OPENAI_API_KEY.value();
  if (!apiKey) {
    console.warn("OPENAI_API_KEY missing; applying local group moderation only.");
    return allow(["local"]);
  }

  const imagePaths = (input.imagePaths ?? []).slice(0, 6);

  if (combined) {
    try {
      const moderation = await callOpenAiModeration(apiKey, [
        {type: "text", text: combined.slice(0, 12000)},
      ]);
      sources.push("openai_moderation");
      if (moderation?.flagged) {
        const category = categoryFromOpenAi(moderation.categories);
        return reject(category, `openai:${category}`, sources);
      }
    } catch (error) {
      console.error("OpenAI moderation unavailable; continuing", error);
    }
  }

  for (const path of imagePaths) {
    const image = await loadGroupImage(input.groupId, path);
    if (!image) continue;
    try {
      const moderation = await callOpenAiModeration(apiKey, [image]);
      sources.push("openai_moderation_image");
      if (moderation?.flagged) {
        const category = categoryFromOpenAi(moderation.categories);
        return reject(category, `openai_image:${category}`, sources);
      }
    } catch (error) {
      console.error("OpenAI image moderation unavailable; continuing", path, error);
    }
  }

  if (combined) {
    try {
      const community = await callCommunityLlm(apiKey, combined);
      sources.push("llm");
      if (community && !community.allowed) {
        return {...community, sources: [...sources, ...community.sources]};
      }
    } catch (error) {
      console.error("Community LLM check unavailable; continuing", error);
    }
  }

  return allow(sources.length ? sources : ["local"]);
}

async function deleteGroupImages(groupId: string, paths: string[]): Promise<void> {
  if (paths.length === 0) return;
  const bucket = getStorage().bucket();
  for (const raw of paths) {
    const path = assertGroupImagePath(groupId, raw);
    if (!path) continue;
    try {
      await bucket.file(path).delete({ignoreNotFound: true});
    } catch (error) {
      console.warn("Could not delete rejected group image", path, error);
    }
  }
}

async function applyDecision(
  ref: DocumentReference,
  data: Record<string, unknown>,
  groupId: string,
  options: {decrementReplyCount?: boolean} = {},
): Promise<void> {
  const current = `${data.moderationStatus ?? ""}`.trim().toLowerCase();
  if (current === "approved" || current === "rejected") return;

  const latest = await ref.get();
  if (latest.data()?.removed === true) return;

  if (current !== "pending") {
    try {
      await ref.update({moderationStatus: "pending"});
    } catch (error) {
      console.warn("Could not mark content pending", ref.path, error);
    }
  }

  let decision: ModerationDecision;
  try {
    decision = await evaluateGroupContent({
      groupId,
      title: `${data.title ?? ""}`,
      text: `${data.text ?? ""}`,
      imagePaths: imagePathsFromData(data),
    });
  } catch (error) {
    console.error("Group moderation failed; leaving content pending", ref.path, error);
    return;
  }

  const payload: Record<string, unknown> = {
    moderationStatus: decision.allowed ? "approved" : "rejected",
    moderationCategory: decision.category,
    moderationReason: decision.reason,
    moderationMessage: decision.message,
    moderationSources: decision.sources,
    moderatedAt: FieldValue.serverTimestamp(),
  };

  if (!decision.allowed) {
    const paths = imagePathsFromData(data);
    await deleteGroupImages(groupId, paths);
    if (paths.length > 0) {
      payload.imagePaths = [];
    }
  }

  await ref.update(payload);

  if (!decision.allowed && options.decrementReplyCount) {
    const postRef = ref.parent.parent;
    if (postRef) {
      try {
        await postRef.update({replyCount: FieldValue.increment(-1)});
      } catch (error) {
        console.warn("Could not decrement replyCount after reject", postRef.path, error);
      }
    }
  }
}

type PostParams = {groupId: string; postId: string};
type ReplyParams = {groupId: string; postId: string; replyId: string};

export async function handleGroupPostCreated(
  event: FirestoreEvent<QueryDocumentSnapshot | undefined, PostParams>,
): Promise<void> {
  const snap = event.data;
  if (!snap) return;
  const data = snap.data() as Record<string, unknown>;
  await applyDecision(snap.ref, data, event.params.groupId);
}

export async function handleGroupReplyCreated(
  event: FirestoreEvent<QueryDocumentSnapshot | undefined, ReplyParams>,
): Promise<void> {
  const snap = event.data;
  if (!snap) return;
  const data = snap.data() as Record<string, unknown>;
  await applyDecision(snap.ref, data, event.params.groupId, {
    decrementReplyCount: true,
  });
}
