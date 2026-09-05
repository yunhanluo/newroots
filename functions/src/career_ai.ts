/**
 * Career Bridge AI — maps prior experience to US career pathways.
 */
import {HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {outputLanguageInstructions, localizeJson, replyLanguageName} from "./ai_language.js";

const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

export const careerCallableOptions = {
  enforceAppCheck: false,
  secrets: [OPENAI_API_KEY],
  timeoutSeconds: 180,
};

interface ProfileInput {
  languageCode?: string;
  location?: string;
  employmentBackground?: string;
  topPriorities?: string[];
}

interface CareerAiInput {
  action?: "generate" | "regenerate_path" | "ask";
  profile: ProfileInput;
  additionalNotes?: string;
  language?: string;
  languageCode?: string;
  existingPaths?: {title: string; summary?: string}[];
  pathIndex?: number;
  pathId?: string;
  replacePathTitle?: string;
  question?: string;
  path?: Record<string, unknown>;
  qaHistory?: {question: string; answer: string}[];
}

interface CareerPathStep {
  id: string;
  title: string;
  description: string;
  timeEstimate: string;
  isCurrent?: boolean;
  certifications: string[];
  skills: string[];
}

interface CareerPath {
  id: string;
  title: string;
  summary: string;
  steps: CareerPathStep[];
}

interface CareerAiResult {
  paths: CareerPath[];
}

interface SinglePathResult {
  path: CareerPath;
}

const CAREER_ADVISOR_PROMPT =
  "You are a US career counselor helping immigrants translate foreign work " +
  "experience into realistic career pathways in the United States, with a " +
  "focus on California when location is known. Be specific about licenses, " +
  "certifications, exams, apprenticeships, and regulated trades. Never " +
  "provide legal or immigration advice.";

const PRIORITIES_NOTE =
  "IMPORTANT — survey topPriorities are NOT job interests or desired " +
  "industries. They are life areas the person wants to learn about or navigate " +
  "in the US (e.g. Healthcare means they want to understand America's " +
  "healthcare system, NOT that they want a healthcare career). Base career " +
  "pathways on priorEmployment and additional notes. Do not invent career " +
  "paths just because a priority like Healthcare, Housing, Education, or " +
  "Safety appears in the survey.";

const JSON_RULES =
  "Respond with ONLY valid JSON — no markdown fences, no commentary.";

function careerJsonRules(languageName: string): string {
  return (
    `${JSON_RULES} ${outputLanguageInstructions(languageName)} ` +
    "Path title, summary, step title, step description, certifications, and " +
    `skills must be in ${languageName}. ` +
    "JSON example values in this prompt are SCHEMA PLACEHOLDERS — do not copy " +
    `the English placeholder words. Fill them in ${languageName}. ` +
    'The ONLY allowed English token inside a string value is timeEstimate "Now" ' +
    "when the person is already in that step with no remaining wait. " +
    `Any other timeEstimate must be a duration phrase in ${languageName}.`
  );
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

function summarizeOpenAiHttpError(status: number, bodyText: string): string {
  try {
    const parsed = JSON.parse(bodyText) as {
      error?: {message?: string};
    };
    const message = parsed.error?.message?.trim();
    if (message) return message;
  } catch {
    // Fall through.
  }
  return `OpenAI request failed with HTTP ${status}.`;
}

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
      return {ok: false, reason: "OpenAI returned invalid JSON."};
    }
  } catch (error) {
    console.error("OpenAI request failed", error);
    return {ok: false, reason: "Could not reach the OpenAI API."};
  }
}

function profileContext(profile: ProfileInput, languageName: string): string {
  return JSON.stringify(
    {
      replyLanguage: languageName,
      location: profile.location?.trim() || null,
      priorEmployment: profile.employmentBackground?.trim() || null,
      topPriorities: profile.topPriorities ?? [],
    },
    null,
    2,
  );
}

function normalizeStringList(raw: unknown): string[] {
  if (!Array.isArray(raw)) return [];
  return raw
    .filter((value): value is string => typeof value === "string")
    .map((value) => value.trim())
    .filter(Boolean);
}

function normalizeTimeEstimate(raw: string | undefined): string {
  const value = raw?.trim() ?? "";
  if (value.toLowerCase() === "ongoing") return "Now";
  return value;
}

function normalizeSteps(raw: CareerPathStep[] | undefined, pathIndex: number): CareerPathStep[] {
  if (!raw?.length) return [];
  return raw.map((step, stepIndex) => ({
    id: step.id?.trim() || `p${pathIndex + 1}s${stepIndex + 1}`,
    title: step.title?.trim() || `Step ${stepIndex + 1}`,
    description: step.description?.trim() || "",
    timeEstimate: normalizeTimeEstimate(step.timeEstimate),
    isCurrent: stepIndex === 0 || step.isCurrent === true,
    certifications: normalizeStringList(step.certifications),
    skills: normalizeStringList(step.skills),
  }));
}

const CAREER_PATH_COUNT = 3;

function normalizePaths(raw: CareerPath[] | undefined): CareerPath[] {
  if (!raw?.length) return [];
  return raw
    .filter((path) => path.title?.trim() || path.steps?.length)
    .slice(0, CAREER_PATH_COUNT)
    .map((path, index) => ({
      id: path.id?.trim() || `path${index + 1}`,
      title: path.title?.trim() || `Career path ${index + 1}`,
      summary: path.summary?.trim() || "",
      steps: normalizeSteps(path.steps, index),
    }))
    .filter((path) => path.steps.length >= 2);
}

function normalizePath(
  raw: CareerPath | undefined,
  pathIndex: number,
  pathId?: string,
): CareerPath | null {
  if (!raw?.title?.trim() && !raw?.steps?.length) return null;
  const steps = normalizeSteps(raw.steps, pathIndex);
  if (steps.length < 2) return null;
  return {
    id: pathId?.trim() || raw.id?.trim() || `path${pathIndex + 1}`,
    title: raw.title?.trim() || `Career path ${pathIndex + 1}`,
    summary: raw.summary?.trim() || "",
    steps,
  };
}

async function regenerateCareerPath(
  apiKey: string,
  profile: ProfileInput,
  additionalNotes: string,
  existingPaths: {title: string; summary?: string}[],
  pathIndex: number,
  pathId: string,
  replacePathTitle: string,
  languageName: string,
): Promise<Record<string, unknown>> {
  const notes = additionalNotes.trim() || "None provided.";
  const location = profile.location?.trim() || "the United States";
  const otherPaths = existingPaths
    .filter((_, index) => index !== pathIndex)
    .map((path) => path.title)
    .join(", ") || "None";

  const result = await tryOpenAiJson<SinglePathResult>(apiKey, [
    {
      role: "system",
      content:
        `${outputLanguageInstructions(languageName)}\n` +
        `${CAREER_ADVISOR_PROMPT}\n${careerJsonRules(languageName)}`,
    },
    {
      role: "user",
      content:
        `Write this entire career path in ${languageName}.\n\n` +
        "Create ONE new, realistic US career pathway to replace an existing option. " +
        "The pathway is a linear progression from current situation (top) to a " +
        "future role (bottom).\n\n" +
        "Survey / profile:\n" +
        `${profileContext(profile, languageName)}\n\n` +
        `${PRIORITIES_NOTE}\n\n` +
        "Additional notes from the user:\n" +
        `${notes}\n\n` +
        `Location context: ${location}\n\n` +
        `Path being replaced: "${replacePathTitle}"\n` +
        `Other paths to keep distinct from: ${otherPaths}\n\n` +
        "Requirements:\n" +
        "- Propose a MEANINGFULLY DIFFERENT career direction from the other paths.\n" +
        "- Ground the path in prior employment / notes — NOT survey priorities.\n" +
        "- 3–6 steps from CURRENT (first step, isCurrent: true) to FUTURE.\n" +
        "- EVERY step MUST include a non-empty description (1–3 sentences) in " +
        `${languageName}.\n` +
        `- EVERY timeEstimate except the English token "Now" must be in ${languageName}.\n` +
        "- Include REAL, SPECIFIC certifications, licenses, and exams at each step, " +
        `with labels in ${languageName}.\n` +
        `- Include concrete skills in ${languageName}.\n\n` +
        "Return JSON (placeholder strings must be replaced with " +
        `${languageName} text):\n` +
        '{ "path": { "id": "pathId", "title": "<title>", "summary": "<summary>", ' +
        '"steps": [{ "id": "s1", "title": "<title>", "description": "<description>", ' +
        '"timeEstimate": "Now", "isCurrent": true, "certifications": [], ' +
        '"skills": ["<skill>"] }] } }',
    },
  ]);

  if (!result.ok) {
    throw new HttpsError("unavailable", result.reason);
  }

  const path = normalizePath(result.data.path, pathIndex, pathId);
  if (!path) {
    throw new HttpsError(
      "internal",
      "AI returned an invalid career path. Please try again.",
    );
  }

  const localized = await localizeJson(apiKey, {path}, languageName);
  const next = normalizePath(
    localized.path as CareerPath | undefined,
    pathIndex,
    pathId,
  );
  if (!next) {
    throw new HttpsError(
      "internal",
      "Could not write this career path in the requested language.",
    );
  }
  return {path: next};
}

async function generateCareerPaths(
  apiKey: string,
  profile: ProfileInput,
  additionalNotes: string,
  languageName: string,
): Promise<Record<string, unknown>> {
  const notes = additionalNotes.trim() || "None provided.";
  const location = profile.location?.trim() || "the United States";

  const result = await tryOpenAiJson<CareerAiResult>(apiKey, [
    {
      role: "system",
      content:
        `${outputLanguageInstructions(languageName)}\n` +
        `${CAREER_ADVISOR_PROMPT}\n${careerJsonRules(languageName)}`,
    },
    {
      role: "user",
      content:
        `Write your entire career map in ${languageName}.\n\n` +
        "Create EXACTLY 3 distinct, realistic US career pathways based on this person's " +
        "background. Each pathway is a linear progression from their current " +
        "situation (top) toward a future role (bottom).\n\n" +
        "Survey / profile:\n" +
        `${profileContext(profile, languageName)}\n\n` +
        `${PRIORITIES_NOTE}\n\n` +
        "Additional notes from the user (skills, education, goals):\n" +
        `${notes}\n\n` +
        `Location context: ${location}\n\n` +
        "Requirements:\n" +
        "- Return EXACTLY 3 paths in the paths array — no fewer, no more.\n" +
        "- Base pathways on priorEmployment and additional notes, NOT topPriorities.\n" +
        "- Each path has 3–6 steps ordered from CURRENT (first step, isCurrent: true) " +
        "to FUTURE (last step).\n" +
        "- EVERY step MUST include a non-empty description (1–3 sentences) in " +
        `${languageName}.\n` +
        `- EVERY timeEstimate except the English token "Now" must be in ${languageName}.\n` +
        "- Include REAL, SPECIFIC certifications, licenses, exams, or registrations " +
        "needed at each step (keep official exam/license codes, but write surrounding " +
        `labels in ${languageName}).\n` +
        `- Include concrete skills in ${languageName}.\n` +
        "- Paths should be meaningfully different (not minor variations).\n\n" +
        `Return JSON. Replace every <placeholder> with ${languageName} text:\n` +
        "{\n" +
        '  "paths": [\n' +
        "    {\n" +
        '      "id": "path1",\n' +
        '      "title": "<path title>",\n' +
        '      "summary": "<2-3 sentence overview>",\n' +
        '      "steps": [\n' +
        "        {\n" +
        '          "id": "s1",\n' +
        '          "title": "<step title>",\n' +
        '          "description": "<1-3 sentences>",\n' +
        '          "timeEstimate": "Now",\n' +
        '          "isCurrent": true,\n' +
        '          "certifications": [],\n' +
        '          "skills": ["<skill>"]\n' +
        "        }\n" +
        "      ]\n" +
        "    }\n" +
        "  ]\n" +
        "}",
    },
  ]);

  if (!result.ok) {
    throw new HttpsError("unavailable", result.reason);
  }

  const paths = normalizePaths(result.data.paths);
  if (!paths.length) {
    throw new HttpsError(
      "internal",
      "AI returned no valid career paths. Please try again.",
    );
  }

  const localized = await localizeJson(apiKey, {paths}, languageName);
  if (!Array.isArray(localized.paths)) {
    throw new HttpsError(
      "internal",
      "Could not write career paths in the requested language.",
    );
  }
  const next = normalizePaths(localized.paths as CareerPath[]);
  if (!next.length) {
    throw new HttpsError(
      "internal",
      "Could not write career paths in the requested language.",
    );
  }
  return {paths: next};
}

interface AskResult {
  answer?: string;
}

async function askCareerQuestion(
  apiKey: string,
  profile: ProfileInput,
  additionalNotes: string,
  languageName: string,
  path: Record<string, unknown> | undefined,
  qaHistory: {question: string; answer: string}[],
  question: string,
  otherPathTitles: string[],
): Promise<Record<string, unknown>> {
  const notes = additionalNotes.trim() || "None provided.";
  const priorQa = qaHistory
    .map((item) => `Q: ${item.question}\nA: ${item.answer}`)
    .join("\n\n") || "None yet.";
  const otherPaths = otherPathTitles.filter(Boolean).join(", ") || "None";

  const result = await tryOpenAiJson<AskResult>(apiKey, [
    {
      role: "system",
      content:
        `${outputLanguageInstructions(languageName)}\n` +
        `${CAREER_ADVISOR_PROMPT}\n${JSON_RULES} ` +
        `The answer field must be entirely in ${languageName}.`,
    },
    {
      role: "user",
      content:
        `Answer entirely in ${languageName}. Do not answer in English ` +
        `unless ${languageName} is English.\n\n` +
        "Survey / profile:\n" +
        `${profileContext(profile, languageName)}\n\n` +
        `${PRIORITIES_NOTE}\n\n` +
        "Additional background notes from the user:\n" +
        `${notes}\n\n` +
        "This career path (steps, progress, saved notes):\n" +
        `${JSON.stringify(path ?? {}, null, 2)}\n\n` +
        `Other paths (titles only, for contrast): ${otherPaths}\n\n` +
        "Prior questions and answers in this session:\n" +
        `${priorQa}\n\n` +
        `User question: ${question}\n\n` +
        'Return JSON: { "answer": "..." }',
    },
  ]);

  if (!result.ok) {
    throw new HttpsError("unavailable", result.reason);
  }

  const answer = result.data.answer?.trim() ?? "";
  if (!answer) {
    throw new HttpsError("internal", "AI returned an empty answer.");
  }

  const localized = await localizeJson(apiKey, {answer}, languageName);
  const next = localized.answer?.trim();
  if (!next) {
    throw new HttpsError(
      "internal",
      "Could not write the answer in the requested language.",
    );
  }
  return {answer: next};
}

export async function handleCareerAi(
  request: CallableRequest,
  requireAuth: (req: CallableRequest) => string,
): Promise<Record<string, unknown>> {
  requireAuth(request);
  const data = (request.data ?? {}) as CareerAiInput;
  const action = data.action ?? "generate";
  const profile = data.profile ?? {};
  const additionalNotes = data.additionalNotes ?? "";
  const languageName = replyLanguageName(
    data.language || data.languageCode,
  );
  console.info("careerMap language", {
    language: data.language,
    languageCode: data.languageCode,
    profileLanguage: profile.languageCode,
    resolved: languageName,
  });

  const apiKey = OPENAI_API_KEY.value();
  if (!apiKey) {
    throw new HttpsError(
      "failed-precondition",
      "OPENAI_API_KEY is not configured on the server.",
    );
  }

  if (action === "ask") {
    const question = data.question?.trim() ?? "";
    if (!question) {
      throw new HttpsError("invalid-argument", "Provide a question.");
    }
    return askCareerQuestion(
      apiKey,
      profile,
      additionalNotes,
      languageName,
      data.path,
      data.qaHistory ?? [],
      question,
      (data.existingPaths ?? [])
        .map((item) => item.title?.trim() ?? "")
        .filter(Boolean),
    );
  }

  const hasBackground =
    profile.employmentBackground?.trim() || additionalNotes.trim();
  if (!hasBackground) {
    throw new HttpsError(
      "invalid-argument",
      "Provide prior employment background or additional notes.",
    );
  }

  if (action === "regenerate_path") {
    const pathIndex = data.pathIndex;
    if (pathIndex == null || pathIndex < 0) {
      throw new HttpsError("invalid-argument", "pathIndex is required.");
    }
    return regenerateCareerPath(
      apiKey,
      profile,
      additionalNotes,
      data.existingPaths ?? [],
      pathIndex,
      data.pathId ?? `path${pathIndex + 1}`,
      data.replacePathTitle ?? "this path",
      languageName,
    );
  }

  return generateCareerPaths(apiKey, profile, additionalNotes, languageName);
}
