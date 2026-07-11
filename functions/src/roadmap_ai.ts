/**
 * Roadmap AI — LLM-driven clarifications and roadmap generation.
 */
import {HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";

const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

export const roadmapCallableOptions = {
  enforceAppCheck: false,
  secrets: [OPENAI_API_KEY],
};

interface ProfileInput {
  languageCode?: string;
  location?: string;
  familySize?: number;
  topPriorities?: string[];
  employmentBackground?: string;
  childrenInfo?: string;
  skippedQuestions?: number[];
  onboardingComplete?: boolean;
}

interface ClarificationInput {
  question: string;
  answer: string;
}

interface ChecklistItem {
  id: string;
  text: string;
  done: boolean;
}

interface SectionData {
  summary: string;
  checklist: ChecklistItem[];
  notes?: {id: string; text: string; createdAt?: string}[];
  qaHistory?: {question: string; answer: string; askedAt?: string}[];
}

interface RoadmapData {
  firstMonth: SectionData;
  firstThreeMonths: SectionData;
  firstYear: SectionData;
}

type RoadmapAction =
  | "generate"
  | "clarify"
  | "ask"
  | "regenerate_all"
  | "regenerate_section"
  | "debug";

interface RoadmapAiInput {
  action: RoadmapAction;
  profile: ProfileInput;
  clarifications?: ClarificationInput[];
  roadmap?: RoadmapData & {
    notes?: {text: string; createdAt?: string}[];
    qaHistory?: {question: string; answer: string}[];
  };
  userMessage?: string;
  section?: string;
}

interface PlanResult {
  status: "needs_clarification" | "complete";
  questions?: string[];
  roadmap?: RoadmapData;
}

interface SectionResult {
  sectionData: SectionData;
}

const SURVEY_STEP_LABELS: Record<number, string> = {
  1: "preferred language",
  2: "location / city",
  3: "family size",
  4: "top priorities",
  5: "employment background",
  6: "children's ages",
};

const ROADMAP_ADVISOR_PROMPT =
  "You are an expert integration advisor helping immigrant families settle in " +
  "California and the broader US. You create practical, compassionate settlement " +
  "roadmaps. Never provide legal or immigration advice. Be specific and actionable.";

const JSON_RULES =
  "Respond with ONLY valid JSON — no markdown fences, no commentary.";

function normalizeChecklist(
  raw: ChecklistItem[] | undefined,
  prefix: string,
): ChecklistItem[] {
  if (!raw?.length) return [];
  return raw
    .filter((entry) => entry.text?.trim())
    .map((entry, index) => ({
      id: entry.id?.trim() || `${prefix}${index + 1}`,
      text: entry.text.trim(),
      done: false,
    }));
}

function normalizeSection(
  raw: SectionData | undefined,
  prefix: string,
): SectionData {
  return {
    summary: raw?.summary?.trim() ?? "",
    checklist: normalizeChecklist(raw?.checklist, prefix),
  };
}

function normalizeRoadmap(raw: RoadmapData | undefined): RoadmapData {
  return {
    firstMonth: normalizeSection(raw?.firstMonth, "m"),
    firstThreeMonths: normalizeSection(raw?.firstThreeMonths, "q"),
    firstYear: normalizeSection(raw?.firstYear, "y"),
  };
}

function profileContext(profile: ProfileInput): string {
  const skipped = (profile.skippedQuestions ?? [])
    .map((step) => SURVEY_STEP_LABELS[step] ?? `question ${step}`)
    .join(", ");

  return JSON.stringify(
    {
      languageCode: profile.languageCode ?? "unknown",
      location: profile.location?.trim() || null,
      familySize: profile.familySize ?? null,
      topPriorities: profile.topPriorities ?? [],
      employmentBackground: profile.employmentBackground?.trim() || null,
      childrenInfo: profile.childrenInfo?.trim() || null,
      skippedSurveyTopics: skipped || "none",
      onboardingComplete: profile.onboardingComplete ?? false,
    },
    null,
    2,
  );
}

function clarificationsContext(clarifications: ClarificationInput[]): string {
  if (!clarifications.length) return "None yet.";
  return clarifications
    .map(
      (exchange, index) =>
        `${index + 1}. Q: ${exchange.question}\n   A: ${exchange.answer}`,
    )
    .join("\n");
}

function roadmapContext(roadmap: RoadmapAiInput["roadmap"]): string {
  if (!roadmap) return "None.";
  return JSON.stringify(
    {
      firstMonth: roadmap.firstMonth,
      firstThreeMonths: roadmap.firstThreeMonths,
      firstYear: roadmap.firstYear,
    },
    null,
    2,
  );
}

function sectionLabels(): Record<string, string> {
  return {
    firstMonth: "First Month",
    firstThreeMonths: "First 3 Months",
    firstYear: "First Year",
  };
}

function focusedSectionContext(
  sectionKey: string | undefined,
  roadmap: RoadmapAiInput["roadmap"],
): string {
  if (!roadmap || !sectionKey) return "No specific section selected.";
  const labels = sectionLabels();
  const label = labels[sectionKey] ?? sectionKey;
  const sectionMap: Record<string, SectionData | undefined> = {
    firstMonth: roadmap.firstMonth,
    firstThreeMonths: roadmap.firstThreeMonths,
    firstYear: roadmap.firstYear,
  };
  const sectionData = sectionMap[sectionKey];
  if (!sectionData) return `Section "${label}" not found.`;
  return JSON.stringify({section: label, data: sectionData}, null, 2);
}

interface OpenAiFailure {
  ok: false;
  reason: string;
}

interface OpenAiSuccess<T> {
  ok: true;
  data: T;
}

type OpenAiResult<T> = OpenAiSuccess<T> | OpenAiFailure;

async function tryOpenAiJson<T>(
  apiKey: string,
  messages: {role: string; content: string}[],
): Promise<OpenAiResult<T>> {
  try {
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages,
        temperature: 0.5,
        response_format: {type: "json_object"},
      }),
    });
    const bodyText = await response.text();
    if (!response.ok) {
      const reason = summarizeOpenAiHttpError(response.status, bodyText);
      console.error("OpenAI error", response.status, bodyText);
      return {ok: false, reason};
    }
    const json = JSON.parse(bodyText) as {
      choices?: {message?: {content?: string}}[];
    };
    const content = json.choices?.[0]?.message?.content?.trim();
    if (!content) {
      return {ok: false, reason: "OpenAI returned an empty message."};
    }
    try {
      return {ok: true, data: JSON.parse(content) as T};
    } catch {
      console.error("OpenAI JSON parse failed", content);
      return {
        ok: false,
        reason: "OpenAI returned invalid JSON for the roadmap.",
      };
    }
  } catch (error) {
    console.error("OpenAI request failed", error);
    return {ok: false, reason: "Could not reach the OpenAI API."};
  }
}

function summarizeOpenAiHttpError(status: number, bodyText: string): string {
  try {
    const parsed = JSON.parse(bodyText) as {
      error?: {message?: string; code?: string; type?: string};
    };
    const message = parsed.error?.message?.trim();
    if (message) return message;
  } catch {
    // Fall through to generic message.
  }
  return `OpenAI request failed with HTTP ${status}.`;
}

async function tryOpenAiText(
  apiKey: string,
  messages: {role: string; content: string}[],
): Promise<OpenAiResult<string>> {
  try {
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages,
        temperature: 0.4,
      }),
    });
    const bodyText = await response.text();
    if (!response.ok) {
      const reason = summarizeOpenAiHttpError(response.status, bodyText);
      console.error("OpenAI error", response.status, bodyText);
      return {ok: false, reason};
    }
    const json = JSON.parse(bodyText) as {
      choices?: {message?: {content?: string}}[];
    };
    const content = json.choices?.[0]?.message?.content?.trim();
    if (!content) {
      return {ok: false, reason: "OpenAI returned an empty message."};
    }
    return {ok: true, data: content};
  } catch (error) {
    console.error("OpenAI request failed", error);
    return {ok: false, reason: "Could not reach the OpenAI API."};
  }
}

function sanitizeQuestions(raw: unknown): string[] {
  if (!Array.isArray(raw)) return [];
  return raw
    .filter((value): value is string => typeof value === "string")
    .map((question) => question.trim())
    .filter(Boolean)
    .slice(0, 6);
}

async function planRoadmapWithAi(
  apiKey: string,
  profile: ProfileInput,
  clarifications: ClarificationInput[],
  options: {forceComplete?: boolean} = {},
): Promise<Record<string, unknown>> {
  const forceComplete = options.forceComplete ?? false;

  const instruction = forceComplete ?
    "You MUST produce a complete roadmap now. Do not ask clarifying questions." :
    "Use your own judgment: if the survey and prior answers are enough, produce " +
    "the roadmap. If important context is missing, ambiguous, or priorities need " +
    "disambiguation, ask clarifying questions first. Decide how many questions " +
    "(0–6) are truly needed — do not ask unnecessary questions. Do not ask about " +
    "survey topics the user skipped. Do not repeat questions already answered.";

  const result = await tryOpenAiJson<PlanResult>(apiKey, [
    {role: "system", content: `${ROADMAP_ADVISOR_PROMPT}\n${JSON_RULES}`},
    {
      role: "user",
      content:
        `${instruction}\n\n` +
        "Survey profile:\n" +
        `${profileContext(profile)}\n\n` +
        "Prior clarification Q&A:\n" +
        `${clarificationsContext(clarifications)}\n\n` +
        "Return JSON shaped like:\n" +
        "{\n" +
        '  "status": "needs_clarification" | "complete",\n' +
        '  "questions": ["..."],  // only when status is needs_clarification\n' +
        '  "roadmap": {\n' +
        '    "firstMonth": { "summary": "...", "checklist": [{"id":"m1","text":"...","done":false}] },\n' +
        '    "firstThreeMonths": { "summary": "...", "checklist": [...] },\n' +
        '    "firstYear": { "summary": "...", "checklist": [...] }\n' +
        "  }\n" +
        "}\n\n" +
        "Each section needs a warm 2–3 sentence summary and 4–7 concrete checklist " +
        "steps tailored to this family. Reference their location and priorities when known.",
    },
  ]);

  if (!result.ok) {
    throw new HttpsError("unavailable", result.reason);
  }

  const plan = result.data;

  if (!forceComplete && plan.status === "needs_clarification") {
    const questions = sanitizeQuestions(plan.questions);
    if (questions.length) {
      return {
        status: "needs_clarification",
        questions,
        question: questions[0],
      };
    }
  }

  const roadmap = normalizeRoadmap(plan.roadmap);
  if (
    roadmap.firstMonth.summary ||
    roadmap.firstMonth.checklist.length ||
    roadmap.firstThreeMonths.checklist.length ||
    roadmap.firstYear.checklist.length
  ) {
    return {status: "complete", roadmap};
  }

  throw new HttpsError(
    "internal",
    "AI returned an invalid roadmap. Please try again.",
  );
}

async function regenerateSectionWithAi(
  apiKey: string,
  profile: ProfileInput,
  clarifications: ClarificationInput[],
  section: string,
  existingRoadmap: RoadmapAiInput["roadmap"],
): Promise<Record<string, unknown>> {
  const sectionLabels: Record<string, string> = {
    firstMonth: "First Month",
    firstThreeMonths: "First 3 Months",
    firstYear: "First Year",
  };
  const label = sectionLabels[section];
  if (!label) {
    throw new HttpsError("invalid-argument", "Unknown section.");
  }

  const prefix = section === "firstMonth" ?
    "m" :
    section === "firstThreeMonths" ?
      "q" :
      "y";

  const result = await tryOpenAiJson<SectionResult>(apiKey, [
    {role: "system", content: `${ROADMAP_ADVISOR_PROMPT}\n${JSON_RULES}`},
    {
      role: "user",
      content:
        `Regenerate ONLY the "${label}" section of this integration roadmap.\n\n` +
        "Survey profile:\n" +
        `${profileContext(profile)}\n\n` +
        "Clarification Q&A:\n" +
        `${clarificationsContext(clarifications)}\n\n` +
        "Existing roadmap (keep other sections consistent in tone):\n" +
        `${roadmapContext(existingRoadmap)}\n\n` +
        "Return JSON:\n" +
        '{ "sectionData": { "summary": "...", "checklist": [{"id":"...","text":"...","done":false}] } }',
    },
  ]);

  if (!result.ok) {
    throw new HttpsError("unavailable", result.reason);
  }

  if (!result.data.sectionData) {
    throw new HttpsError(
      "unavailable",
      "AI returned an empty section. Please try again.",
    );
  }

  return {
    status: "complete",
    section,
    sectionData: normalizeSection(result.data.sectionData, prefix),
  };
}

export async function handleRoadmapAi(
  request: CallableRequest,
  requireAuth: (req: CallableRequest) => string,
): Promise<Record<string, unknown>> {
  requireAuth(request);
  const data = (request.data ?? {}) as RoadmapAiInput;
  const action = data.action ?? "generate";
  const profile = data.profile ?? {};
  const clarifications = data.clarifications ?? [];

  if (action === "debug") {
    const apiKey = OPENAI_API_KEY.value();
    const apiKeyConfigured = Boolean(apiKey?.trim());
    if (!apiKeyConfigured) {
      return {
        status: "debug",
        apiKeyConfigured: false,
        openAiReachable: false,
        detail: "OPENAI_API_KEY secret is empty.",
      };
    }

    const ping = await tryOpenAiText(apiKey, [
      {role: "user", content: "Reply with the single word OK."},
    ]);

    return {
      status: "debug",
      apiKeyConfigured: true,
      openAiReachable: ping.ok,
      detail: ping.ok ? "OpenAI responded successfully." : ping.reason,
    };
  }

  const apiKey = OPENAI_API_KEY.value();

  if (!apiKey) {
    throw new HttpsError(
      "failed-precondition",
      "OPENAI_API_KEY is not configured on the server.",
    );
  }

  if (action === "ask") {
    const question = data.userMessage?.trim();
    if (!question) {
      throw new HttpsError("invalid-argument", "userMessage is required.");
    }

    const sectionKey = data.section;
    const sectionLabel = sectionKey ?
      sectionLabels()[sectionKey] ?? sectionKey :
      "the roadmap";

    const aiAnswer = await tryOpenAiText(apiKey, [
      {role: "system", content: ROADMAP_ADVISOR_PROMPT},
      {
        role: "user",
        content:
          `Answer the user's question about the "${sectionLabel}" section of ` +
          "their settlement roadmap.\n\n" +
          "Survey profile:\n" +
          `${profileContext(profile)}\n\n` +
          "Focused section (summary, checklist, notes, prior Q&A):\n" +
          `${focusedSectionContext(sectionKey, data.roadmap)}\n\n` +
          "Full roadmap for broader context:\n" +
          `${roadmapContext(data.roadmap)}\n\n` +
          `User question: ${question}`,
      },
    ]);

    if (!aiAnswer.ok) {
      throw new HttpsError("unavailable", aiAnswer.reason);
    }

    return {status: "answer", answer: aiAnswer.data};
  }

  if (action === "regenerate_section") {
    const section = data.section;
    if (!section) {
      throw new HttpsError("invalid-argument", "section is required.");
    }
    return regenerateSectionWithAi(
      apiKey,
      profile,
      clarifications,
      section,
      data.roadmap,
    );
  }

  if (action === "generate" || action === "clarify") {
    return planRoadmapWithAi(apiKey, profile, clarifications);
  }

  if (action === "regenerate_all") {
    return planRoadmapWithAi(apiKey, profile, clarifications, {
      forceComplete: true,
    });
  }

  throw new HttpsError("invalid-argument", `Unknown action: ${action}`);
}
