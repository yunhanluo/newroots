/**
 * Housing Navigator AI — answers user questions about the current tutorial section.
 */
import {HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";

const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

export const housingCallableOptions = {
  enforceAppCheck: false,
  secrets: [OPENAI_API_KEY],
};

interface HousingChatTurn {
  role?: string;
  content?: string;
}

interface HousingAiInput {
  question?: string;
  sectionTitle?: string;
  sectionSummary?: string;
  language?: string;
  /** Prior turns in this temporary session (user/assistant), excluding the latest question. */
  history?: HousingChatTurn[];
}

const HOUSING_ADVISOR_PROMPT =
  "You are a helpful housing guide for immigrants learning to rent in the " +
  "United States, with a focus on California when relevant. Explain rental " +
  "requirements, qualifying without credit history, housing resources, " +
  "tenant rights, and scam prevention in plain language. Keep answers short " +
  "and practical. Never provide formal legal advice; suggest talking to a " +
  "legal aid clinic or housing counselor when appropriate.";

async function askOpenAi(
  apiKey: string,
  messages: {role: string; content: string}[],
): Promise<string> {
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
    throw new HttpsError("internal", "OpenAI returned an empty answer.");
  }
  return content;
}

export async function handleHousingAi(
  request: CallableRequest,
  requireAuth: (req: CallableRequest) => string,
): Promise<Record<string, unknown>> {
  requireAuth(request);
  const data = (request.data ?? {}) as HousingAiInput;
  const question = data.question?.trim() ?? "";
  if (!question) {
    throw new HttpsError("invalid-argument", "Provide a question.");
  }

  const apiKey = OPENAI_API_KEY.value();
  if (!apiKey) {
    throw new HttpsError(
      "failed-precondition",
      "OPENAI_API_KEY is not configured on the server.",
    );
  }

  const sectionTitle = data.sectionTitle?.trim() || "Housing";
  const sectionSummary = data.sectionSummary?.trim() || "";
  const language = data.language?.trim() || "en";

  const history: {role: string; content: string}[] = [];
  for (const turn of data.history ?? []) {
    const role = turn.role?.trim();
    const content = turn.content?.trim() ?? "";
    if (!content) continue;
    if (role !== "user" && role !== "assistant") continue;
    history.push({role, content});
  }

  const sectionContext =
    `Current tutorial section: ${sectionTitle}\n` +
    (sectionSummary ? `Section summary: ${sectionSummary}\n` : "") +
    `Reply language preference: ${language}\n` +
    "Use the section context for grounding. The user may ask follow-ups " +
    "that refer to earlier messages in this temporary conversation.";

  const answer = await askOpenAi(apiKey, [
    {role: "system", content: HOUSING_ADVISOR_PROMPT},
    {role: "system", content: sectionContext},
    ...history,
    {role: "user", content: question},
  ]);

  return {answer};
}
