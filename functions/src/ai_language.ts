/** Shared reply-language helpers for AI Cloud Functions. */

const LANGUAGE_NAMES: Record<string, string> = {
  en: "English",
  es: "Spanish (español)",
  zh: "Simplified Chinese (简体中文)",
  vi: "Vietnamese (Tiếng Việt)",
  ko: "Korean (한국어)",
  hi: "Hindi (हिन्दी)",
  ar: "Arabic (العربية)",
  english: "English",
  spanish: "Spanish (español)",
  chinese: "Simplified Chinese (简体中文)",
  vietnamese: "Vietnamese (Tiếng Việt)",
  korean: "Korean (한국어)",
  hindi: "Hindi (हिन्दी)",
  arabic: "Arabic (العربية)",
};

export function replyLanguageName(raw: string | undefined): string {
  const value = (raw ?? "en").trim();
  if (!value) return "English";
  const mapped = LANGUAGE_NAMES[value.toLowerCase()];
  return mapped ?? value;
}

export function isEnglishOutput(languageName: string): boolean {
  return languageName.toLowerCase().startsWith("english");
}

export function outputLanguageInstructions(languageName: string): string {
  const englishOk = isEnglishOutput(languageName);
  return (
    `MANDATORY OUTPUT LANGUAGE: ${languageName}. ` +
    (englishOk ?
      "Write every human-readable string in English. " :
      `Write every human-readable string in ${languageName}. ` +
      `Do not use English for those strings unless ${languageName} is English. `) +
    "Keep JSON keys, ids, enums, booleans, and status values in English."
  );
}

/**
 * Second-pass translation, same idea as ScamShield writing analysis in the
 * preferred language even when the source material is English.
 */
const SKIP_LOCALIZE_KEYS = new Set([
  "id",
  "status",
  "timeEstimate",
  "riskLevel",
]);

const ENGLISH_MARKERS =
  /\b(the|and|your|with|from|this|that|obtain|complete|apply|training|months?|weeks?|steps?|license|certificate)\b/gi;

function extractReadableStrings(value: unknown, out: string[], key?: string): void {
  if (key && SKIP_LOCALIZE_KEYS.has(key)) return;
  if (typeof value === "string") {
    const trimmed = value.trim();
    if (trimmed) out.push(trimmed);
    return;
  }
  if (Array.isArray(value)) {
    for (const item of value) extractReadableStrings(item, out, key);
    return;
  }
  if (value && typeof value === "object") {
    for (const [nextKey, nextValue] of Object.entries(value)) {
      extractReadableStrings(nextValue, out, nextKey);
    }
  }
}

function stillLooksEnglish(data: unknown): boolean {
  const strings: string[] = [];
  extractReadableStrings(data, strings);
  const text = strings.join(" ");
  if (text.length < 40) return false;
  return (text.match(ENGLISH_MARKERS)?.length ?? 0) >= 8;
}

async function rewriteJson<T extends Record<string, unknown>>(
  apiKey: string,
  data: T,
  languageName: string,
): Promise<T> {
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
        {
          role: "system",
          content:
            `You translate JSON for immigrant users. Rewrite every ` +
            `human-readable string entirely in ${languageName}. ` +
            `Do not leave titles, summaries, descriptions, questions, ` +
            `answers, checklist text, certification labels, or skills in ` +
            `English unless ${languageName} is English. ` +
            `Keep JSON keys, ids, booleans, enums, URLs, and official ` +
            `license/exam codes (e.g. C-36, OSHA 10). ` +
            `Keep the timeEstimate token "Now" in English if present. ` +
            `Return ONLY JSON with the same shape.`,
        },
        {
          role: "user",
          content:
            `Write your entire result in ${languageName}.\n\n` +
            `Translate this JSON into ${languageName}:\n` +
            JSON.stringify(data),
        },
      ],
    }),
  });
  const bodyText = await response.text();
  if (!response.ok) {
    console.error("localizeJson OpenAI error", response.status, bodyText);
    throw new Error(`Language rewrite failed with HTTP ${response.status}.`);
  }
  const json = JSON.parse(bodyText) as {
    choices?: {message?: {content?: string}}[];
  };
  const content = json.choices?.[0]?.message?.content?.trim();
  if (!content) {
    throw new Error("Language rewrite returned an empty message.");
  }
  return JSON.parse(content) as T;
}

export async function localizeJson<T extends Record<string, unknown>>(
  apiKey: string,
  data: T,
  languageName: string,
): Promise<T> {
  if (isEnglishOutput(languageName)) return data;

  let localized = await rewriteJson(apiKey, data, languageName);
  if (stillLooksEnglish(localized)) {
    console.warn("localizeJson still looked English; retrying", languageName);
    localized = await rewriteJson(apiKey, localized, languageName);
  }
  return localized;
}

/** Translate a list of UI/resource blurbs, preserving order and empties. */
export async function localizeStringList(
  apiKey: string,
  values: string[],
  languageName: string,
): Promise<string[]> {
  if (isEnglishOutput(languageName) || values.length === 0) return values;

  const unique: string[] = [];
  const seen = new Map<string, number>();
  const indexOfUnique: number[] = [];
  for (const value of values) {
    const key = value.trim();
    if (!key) {
      indexOfUnique.push(-1);
      continue;
    }
    let idx = seen.get(key);
    if (idx === undefined) {
      idx = unique.length;
      unique.push(key);
      seen.set(key, idx);
    }
    indexOfUnique.push(idx);
  }
  if (unique.length === 0) return values;

  try {
    const localized = await localizeJson(apiKey, {strings: unique}, languageName);
    const next = localized.strings;
    if (!Array.isArray(next) || next.length !== unique.length) return values;
    const translated = unique.map((original, i) => {
      const item = next[i];
      return typeof item === "string" && item.trim() ? item.trim() : original;
    });
    return values.map((original, i) => {
      const idx = indexOfUnique[i];
      return idx < 0 ? original : translated[idx];
    });
  } catch (error) {
    console.warn("localizeStringList failed", error);
    return values;
  }
}
