/**
 * ScamShield AI — risk assessment for suspicious messages, emails, jobs,
 * rentals, and government-related content. Supports pasted text and
 * screenshot images from Cloud Storage (vision).
 */
import {HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {getStorage} from "firebase-admin/storage";
import {initializeApp, getApps} from "firebase-admin/app";

if (getApps().length === 0) {
  initializeApp();
}

const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

export const scamCallableOptions = {
  enforceAppCheck: false,
  secrets: [OPENAI_API_KEY],
  timeoutSeconds: 60,
  memory: "512MiB" as const,
};

type ScamCategory = "sms" | "email" | "job" | "rental" | "government";

interface ScamAiInput {
  text?: string;
  contentRef?: string;
  category?: string;
  language?: string;
  /** Existing conversation thread text, for follow-up reevaluation. */
  priorThread?: string;
  priorRiskLevel?: string;
  /** Keep the same report id when continuing a check. */
  reportId?: string;
}

interface ScamAiResult {
  riskLevel: "low" | "moderate" | "high";
  summary: string;
  reasons: string[];
  recommendedActions: string[];
}

const CATEGORIES = new Set<ScamCategory>([
  "sms",
  "email",
  "job",
  "rental",
  "government",
]);

const CATEGORY_LABELS: Record<ScamCategory, string> = {
  sms: "text message / SMS",
  email: "email",
  job: "job offer",
  rental: "rental advertisement",
  government: "government-related message",
};

const SCAM_ADVISOR_PROMPT =
  "You are ScamShield, a careful fraud-prevention advisor for immigrant " +
  "families in the United States, with a focus on California when relevant. " +
  "Assess whether the submitted content may be a scam. Explain WHY it may " +
  "be risky using clear, plain language. Do not claim certainty that " +
  "something is fraudulent. Never provide formal legal advice. Flag common " +
  "patterns such as urgency, gift cards, wire transfers, unverified links, " +
  "requests for SSN/ITIN/bank details, government impersonation, " +
  "too-good-to-be-true jobs or rentals, and pressure to act in secret.";

const JSON_RULES =
  "Respond with ONLY valid JSON — no markdown fences, no commentary. " +
  "Schema: {\"riskLevel\":\"low\"|\"moderate\"|\"high\"," +
  "\"summary\":string,\"reasons\":string[],\"recommendedActions\":string[]}. " +
  "reasons should be 2-5 short explanations of risk signals (or why risk " +
  "appears low). recommendedActions should be 2-4 practical next steps. " +
  "summary should be 1-2 sentences.";

type ContentPart =
  | {type: "text"; text: string}
  | {type: "image_url"; image_url: {url: string}};

function normalizeCategory(raw: string | undefined): ScamCategory {
  const value = (raw ?? "sms").trim().toLowerCase();
  if (CATEGORIES.has(value as ScamCategory)) {
    return value as ScamCategory;
  }
  return "sms";
}

function normalizeRiskLevel(raw: unknown): ScamAiResult["riskLevel"] {
  const value = String(raw ?? "").trim().toLowerCase();
  if (value === "low" || value === "moderate" || value === "high") {
    return value;
  }
  return "moderate";
}

function asStringList(raw: unknown, fallback: string[]): string[] {
  if (!Array.isArray(raw)) return fallback;
  const items = raw
    .filter((v): v is string => typeof v === "string")
    .map((v) => v.trim())
    .filter(Boolean);
  return items.length ? items : fallback;
}

function assertOwnedUploadPath(uid: string, contentRef: string): string {
  const path = contentRef.trim().replace(/^\/+/, "");
  const prefix = `scamshield-uploads/${uid}/`;
  if (!path.startsWith(prefix) || path.includes("..")) {
    throw new HttpsError(
      "permission-denied",
      "Invalid upload path for this user.",
    );
  }
  return path;
}

function mimeFromPath(path: string): string {
  const lower = path.toLowerCase();
  if (lower.endsWith(".png")) return "image/png";
  if (lower.endsWith(".webp")) return "image/webp";
  if (lower.endsWith(".gif")) return "image/gif";
  if (lower.endsWith(".txt")) return "text/plain";
  return "image/jpeg";
}

async function loadUploadContent(
  uid: string,
  contentRef: string,
): Promise<{kind: "image"; dataUrl: string} | {kind: "text"; text: string}> {
  const path = assertOwnedUploadPath(uid, contentRef);
  const bucket = getStorage().bucket();
  const file = bucket.file(path);
  const [exists] = await file.exists();
  if (!exists) {
    throw new HttpsError("not-found", "Uploaded file was not found.");
  }
  const [buffer] = await file.download();
  const mime = mimeFromPath(path);
  if (mime.startsWith("text/")) {
    return {kind: "text", text: buffer.toString("utf8")};
  }
  if (buffer.byteLength > 8 * 1024 * 1024) {
    throw new HttpsError(
      "invalid-argument",
      "Screenshot is too large to analyze.",
    );
  }
  const dataUrl = `data:${mime};base64,${buffer.toString("base64")}`;
  return {kind: "image", dataUrl};
}

async function callOpenAiJson(
  apiKey: string,
  userParts: ContentPart[],
): Promise<ScamAiResult> {
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "gpt-4o-mini",
      temperature: 0.2,
      response_format: {type: "json_object"},
      messages: [
        {role: "system", content: `${SCAM_ADVISOR_PROMPT}\n${JSON_RULES}`},
        {role: "user", content: userParts},
      ],
    }),
  });
  const bodyText = await response.text();
  if (!response.ok) {
    console.error("OpenAI error", response.status, bodyText);
    throw new HttpsError(
      "unavailable",
      `OpenAI request failed with HTTP ${response.status}.`,
    );
  }
  const json = JSON.parse(bodyText) as {
    choices?: {message?: {content?: string}}[];
  };
  const content = json.choices?.[0]?.message?.content?.trim();
  if (!content) {
    throw new HttpsError("internal", "OpenAI returned an empty analysis.");
  }
  let parsed: Record<string, unknown>;
  try {
    parsed = JSON.parse(content) as Record<string, unknown>;
  } catch {
    console.error("OpenAI JSON parse failed", content);
    throw new HttpsError("internal", "OpenAI returned invalid JSON.");
  }

  return {
    riskLevel: normalizeRiskLevel(parsed.riskLevel),
    summary: String(parsed.summary ?? "").trim() ||
      "Review this carefully before taking action.",
    reasons: asStringList(parsed.reasons, [
      "Could not extract detailed risk signals. Stay cautious.",
    ]),
    recommendedActions: asStringList(parsed.recommendedActions, [
      "Do not send money or share personal information until you verify the source.",
    ]),
  };
}

export async function handleAnalyzeScam(
  request: CallableRequest,
  requireAuth: (req: CallableRequest) => string,
): Promise<Record<string, unknown>> {
  const uid = requireAuth(request);
  const data = (request.data ?? {}) as ScamAiInput;
  const text = data.text?.trim() ?? "";
  const contentRef = data.contentRef?.trim() ?? "";
  if (!text && !contentRef) {
    throw new HttpsError(
      "invalid-argument",
      "Paste message text or upload a screenshot.",
    );
  }

  const apiKey = OPENAI_API_KEY.value();
  if (!apiKey) {
    throw new HttpsError(
      "failed-precondition",
      "OPENAI_API_KEY is not configured on the server.",
    );
  }

  const category = normalizeCategory(data.category);
  const language = data.language?.trim() || "en";
  const priorThread = data.priorThread?.trim() ?? "";
  const priorRiskLevel = data.priorRiskLevel?.trim() ?? "";
  const reportId = data.reportId?.trim() || `scam_${Date.now()}`;
  const parts: ContentPart[] = [];

  let prompt =
    `Content category: ${CATEGORY_LABELS[category]} (${category})\n` +
    `Reply language preference: ${language}\n\n`;

  if (priorThread) {
    prompt +=
      "This is a FOLLOW-UP. Reassess scam / fraud risk for the FULL " +
      "conversation thread, including earlier messages and the new content. " +
      "Explain what changed if risk went up or down.\n";
    if (priorRiskLevel) {
      prompt += `Previous risk assessment: ${priorRiskLevel}\n`;
    }
    prompt +=
      `\nEarlier messages in the thread:\n"""\n` +
      `${priorThread.slice(0, 10000)}\n"""\n`;
  } else {
    prompt += "Analyze the following for scam / fraud risk.\n";
  }

  if (text) {
    prompt += priorThread ?
      `\nNew follow-up message:\n"""\n${text.slice(0, 8000)}\n"""` :
      `\nPasted content:\n"""\n${text.slice(0, 12000)}\n"""`;
  }

  if (contentRef) {
    const upload = await loadUploadContent(uid, contentRef);
    if (upload.kind === "text") {
      prompt +=
        `\n\nUploaded text file content:\n"""\n` +
        `${upload.text.slice(0, 12000)}\n"""`;
    } else {
      prompt += priorThread ?
        "\n\nA new follow-up screenshot is attached. Read any visible text " +
        "and reassess the full conversation." :
        "\n\nA screenshot image is attached. Read any visible text and " +
        "assess scam risk based on what you see.";
      parts.push({
        type: "image_url",
        image_url: {url: upload.dataUrl},
      });
    }
  }

  parts.unshift({type: "text", text: prompt});

  const analysis = await callOpenAiJson(apiKey, parts);

  return {
    id: reportId,
    language,
    category,
    riskLevel: analysis.riskLevel,
    summary: analysis.summary,
    reasons: analysis.reasons,
    recommendedActions: analysis.recommendedActions,
    contentRef: contentRef || null,
    previousRiskLevel: priorRiskLevel || null,
    createdAt: new Date().toISOString(),
  };
}
