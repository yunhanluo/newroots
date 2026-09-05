/**
 * Roadmap AI — LLM-driven clarifications and roadmap generation.
 */
import {HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {outputLanguageInstructions, localizeJson, replyLanguageName} from "./ai_language.js";

const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

export const roadmapCallableOptions = {
  enforceAppCheck: false,
  secrets: [OPENAI_API_KEY],
  timeoutSeconds: 180,
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
  language?: string;
  languageCode?: string;
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

function roadmapJsonRules(languageName: string): string {
  return (
    `${JSON_RULES} ${outputLanguageInstructions(languageName)} ` +
    "status must stay English (needs_clarification or complete). " +
    `Write questions, summaries, and checklist text entirely in ${languageName}.`
  );
}

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

function profileContext(profile: ProfileInput, languageName: string): string {
  const skipped = (profile.skippedQuestions ?? [])
    .map((step) => SURVEY_STEP_LABELS[step] ?? `question ${step}`)
    .join(", ");

  return JSON.stringify(
    {
      replyLanguage: languageName,
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
  options: {forceComplete?: boolean; languageName?: string} = {},
): Promise<Record<string, unknown>> {
  const forceComplete = options.forceComplete ?? false;
  const languageName = options.languageName ?? "English";

  const instruction = forceComplete ?
    "You MUST produce a complete roadmap now. Do not ask clarifying questions." :
    "Use your own judgment: if the survey and prior answers are enough, produce " +
    "the roadmap. If important context is missing, ambiguous, or priorities need " +
    "disambiguation, ask clarifying questions first. Decide how many questions " +
    "(0–6) are truly needed — do not ask unnecessary questions. Do not ask about " +
    "survey topics the user skipped. Do not repeat questions already answered.";

  const result = await tryOpenAiJson<PlanResult>(apiKey, [
    {
      role: "system",
      content:
        `${outputLanguageInstructions(languageName)}\n` +
        `${ROADMAP_ADVISOR_PROMPT}\n${roadmapJsonRules(languageName)}`,
    },
    {
      role: "user",
      content:
        `Write your entire roadmap in ${languageName}.\n\n` +
        `${instruction}\n\n` +
        "Survey profile:\n" +
        `${profileContext(profile, languageName)}\n\n` +
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
        "steps tailored to this family. Reference their location and priorities when known. " +
        `Write those summaries and steps in ${languageName}.`,
    },
  ]);

  if (!result.ok) {
    throw new HttpsError("unavailable", result.reason);
  }

  const plan = result.data;

  if (!forceComplete && plan.status === "needs_clarification") {
    const questions = sanitizeQuestions(plan.questions);
    if (questions.length) {
      const localized = await localizeJson(apiKey, {questions}, languageName);
      const next = sanitizeQuestions(localized.questions);
      if (!next.length) {
        throw new HttpsError(
          "internal",
          "Could not write questions in the requested language.",
        );
      }
      return {
        status: "needs_clarification",
        questions: next,
        question: next[0],
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
    const localized = await localizeJson(apiKey, {roadmap}, languageName);
    if (!localized.roadmap) {
      throw new HttpsError(
        "internal",
        "Could not write the roadmap in the requested language.",
      );
    }
    return {
      status: "complete",
      roadmap: normalizeRoadmap(localized.roadmap as RoadmapData),
    };
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
  languageName: string,
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
    {
      role: "system",
      content:
        `${outputLanguageInstructions(languageName)}\n` +
        `${ROADMAP_ADVISOR_PROMPT}\n${roadmapJsonRules(languageName)}`,
    },
    {
      role: "user",
      content:
        `Write your entire ${label} section in ${languageName}.\n\n` +
        `Regenerate ONLY the "${label}" section of this integration roadmap.\n\n` +
        "Survey profile:\n" +
        `${profileContext(profile, languageName)}\n\n` +
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

  const sectionData = normalizeSection(result.data.sectionData, prefix);
  const localized = await localizeJson(apiKey, {sectionData}, languageName);
  if (!localized.sectionData) {
    throw new HttpsError(
      "internal",
      "Could not write this section in the requested language.",
    );
  }
  return {
    status: "complete",
    section,
    sectionData: normalizeSection(localized.sectionData as SectionData, prefix),
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
  const languageName = replyLanguageName(
    data.language || data.languageCode,
  );
  console.info("roadmapAi language", {
    language: data.language,
    languageCode: data.languageCode,
    profileLanguage: profile.languageCode,
    resolved: languageName,
  });

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
      {
        role: "system",
        content:
          `${outputLanguageInstructions(languageName)}\n${ROADMAP_ADVISOR_PROMPT}`,
      },
      {
        role: "user",
        content:
          `Answer entirely in ${languageName}. Do not answer in English ` +
          `unless ${languageName} is English.\n\n` +
          `The question is about the "${sectionLabel}" section of ` +
          "their settlement roadmap.\n\n" +
          "Survey profile:\n" +
          `${profileContext(profile, languageName)}\n\n` +
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

    const localized = await localizeJson(
      apiKey,
      {answer: aiAnswer.data},
      languageName,
    );
    const answer = localized.answer?.trim();
    if (!answer) {
      throw new HttpsError(
        "internal",
        "Could not write the answer in the requested language.",
      );
    }
    return {status: "answer", answer};
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
      languageName,
    );
  }

  if (action === "generate" || action === "clarify") {
    return planRoadmapWithAi(apiKey, profile, clarifications, {
      languageName,
    });
  }

  if (action === "regenerate_all") {
    return planRoadmapWithAi(apiKey, profile, clarifications, {
      forceComplete: true,
      languageName,
    });
  }

  throw new HttpsError("invalid-argument", `Unknown action: ${action}`);
}
