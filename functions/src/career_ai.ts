/**
 * Career Bridge AI — maps prior experience to US career pathways.
 */
import {HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";

const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

export const careerCallableOptions = {
  enforceAppCheck: false,
  secrets: [OPENAI_API_KEY],
};

interface ProfileInput {
  languageCode?: string;
  location?: string;
  employmentBackground?: string;
  topPriorities?: string[];
}

interface CareerAiInput {
  action?: "generate" | "regenerate_path";
  profile: ProfileInput;
  additionalNotes?: string;
  language?: string;
  existingPaths?: {title: string; summary?: string}[];
  pathIndex?: number;
  pathId?: string;
  replacePathTitle?: string;
}

interface CareerPathStep {
  id: string;
  title: string;
  description: string;
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

const JSON_RULES =
  "Respond with ONLY valid JSON — no markdown fences, no commentary.";

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

function profileContext(profile: ProfileInput): string {
  return JSON.stringify(
    {
      languageCode: profile.languageCode ?? "en",
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

function normalizeSteps(raw: CareerPathStep[] | undefined, pathIndex: number): CareerPathStep[] {
  if (!raw?.length) return [];
  return raw.map((step, stepIndex) => ({
    id: step.id?.trim() || `p${pathIndex + 1}s${stepIndex + 1}`,
    title: step.title?.trim() || `Step ${stepIndex + 1}`,
    description: step.description?.trim() || "",
    isCurrent: stepIndex === 0 || step.isCurrent === true,
    certifications: normalizeStringList(step.certifications),
    skills: normalizeStringList(step.skills),
  }));
}

function normalizePaths(raw: CareerPath[] | undefined): CareerPath[] {
  if (!raw?.length) return [];
  return raw
    .filter((path) => path.title?.trim() || path.steps?.length)
    .slice(0, 4)
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
): Promise<Record<string, unknown>> {
  const notes = additionalNotes.trim() || "None provided.";
  const location = profile.location?.trim() || "the United States";
  const otherPaths = existingPaths
    .filter((_, index) => index !== pathIndex)
    .map((path) => path.title)
    .join(", ") || "None";

  const result = await tryOpenAiJson<SinglePathResult>(apiKey, [
    {role: "system", content: `${CAREER_ADVISOR_PROMPT}\n${JSON_RULES}`},
    {
      role: "user",
      content:
        "Create ONE new, realistic US career pathway to replace an existing option. " +
        "The pathway is a linear progression from current situation (top) to a " +
        "future role (bottom).\n\n" +
        "Survey / profile:\n" +
        `${profileContext(profile)}\n\n` +
        "Additional notes from the user:\n" +
        `${notes}\n\n` +
        `Location context: ${location}\n\n` +
        `Path being replaced: "${replacePathTitle}"\n` +
        `Other paths to keep distinct from: ${otherPaths}\n\n` +
        "Requirements:\n" +
        "- Propose a MEANINGFULLY DIFFERENT career direction from the other paths.\n" +
        "- 3–6 steps from CURRENT (first step, isCurrent: true) to FUTURE.\n" +
        "- Include REAL, SPECIFIC certifications, licenses, and exams at each step.\n" +
        "- Include concrete skills at each step.\n\n" +
        "Return JSON:\n" +
        '{ "path": { "id": "...", "title": "...", "summary": "...", "steps": [...] } }',
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

  return {path};
}

async function generateCareerPaths(
  apiKey: string,
  profile: ProfileInput,
  additionalNotes: string,
): Promise<Record<string, unknown>> {
  const notes = additionalNotes.trim() || "None provided.";
  const location = profile.location?.trim() || "the United States";

  const result = await tryOpenAiJson<CareerAiResult>(apiKey, [
    {role: "system", content: `${CAREER_ADVISOR_PROMPT}\n${JSON_RULES}`},
    {
      role: "user",
      content:
        "Create 2–4 distinct, realistic US career pathways based on this person's " +
        "background. Each pathway is a linear progression from their current " +
        "situation (top) toward a future role (bottom).\n\n" +
        "Survey / profile:\n" +
        `${profileContext(profile)}\n\n` +
        "Additional notes from the user (skills, education, goals):\n" +
        `${notes}\n\n` +
        `Location context: ${location}\n\n` +
        "Requirements:\n" +
        "- Each path has 3–6 steps ordered from CURRENT (first step, isCurrent: true) " +
        "to FUTURE (last step).\n" +
        "- Include REAL, SPECIFIC certifications, licenses, exams, or registrations " +
        "needed at each step — e.g. for a plumber: California C-36 license, " +
        "apprenticeship hours, OSHA 10, etc.\n" +
        "- Include concrete skills to develop at each step.\n" +
        "- Paths should be meaningfully different (not minor variations).\n" +
        "- Use plain language.\n\n" +
        "Return JSON:\n" +
        "{\n" +
        '  "paths": [\n' +
        "    {\n" +
        '      "id": "path1",\n' +
        '      "title": "Licensed Plumber",\n' +
        '      "summary": "2-3 sentence overview",\n' +
        '      "steps": [\n' +
        "        {\n" +
        '          "id": "s1",\n' +
        '          "title": "Current experience",\n' +
        '          "description": "...",\n' +
        '          "isCurrent": true,\n' +
        '          "certifications": [],\n' +
        '          "skills": ["..."]\n' +
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

  return {paths};
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

  const apiKey = OPENAI_API_KEY.value();
  if (!apiKey) {
    throw new HttpsError(
      "failed-precondition",
      "OPENAI_API_KEY is not configured on the server.",
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
    );
  }

  return generateCareerPaths(apiKey, profile, additionalNotes);
}
