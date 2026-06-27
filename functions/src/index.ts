/**
 * Cloud Functions for NewRoots California — the AI backend.
 *
 * These are CALLABLE functions invoked from the Flutter app's `AiService`.
 * They run server-side so the LLM API key never ships inside the app.
 *
 * Security: every function enforces App Check and requires the caller to be
 * signed in. The AI key is read from a secret (set via
 * `firebase functions:secrets:set OPENAI_API_KEY`) — see DEPLOY_PLAN.md §5.
 *
 * NOTE: the actual LLM call is left as a TODO. Each function currently returns
 * a deterministic placeholder so the app can be wired end-to-end first.
 */
import {onCall, HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {setGlobalOptions} from "firebase-functions/v2";

// Run close to California users (matches Firestore region).
setGlobalOptions({region: "us-west1", maxInstances: 10});

// The LLM key. Set with: firebase functions:secrets:set OPENAI_API_KEY
const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

const callableOptions = {
  enforceAppCheck: true,
  secrets: [OPENAI_API_KEY],
};

/** Throws if the caller is not authenticated. */
function requireAuth(request: CallableRequest): string {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }
  return uid;
}

// --- Feature 1: Integration Roadmap -----------------------------------------
interface RoadmapInput {
  language: string;
  profile: Record<string, unknown>;
}

export const generateRoadmap = onCall(callableOptions, async (request) => {
  requireAuth(request);
  const {language} = (request.data ?? {}) as RoadmapInput;

  // TODO: call the LLM with a structured prompt and return its JSON.
  //   const key = OPENAI_API_KEY.value();
  //   const completion = await callLlm(key, buildRoadmapPrompt(profile, language));
  return {
    id: "placeholder",
    language: language ?? "en",
    steps: [
      {timeframe: "First Month", title: "Open a bank account"},
      {timeframe: "First Month", title: "Register children for school"},
      {timeframe: "First Year", title: "Build credit history"},
    ],
  };
});

// --- Feature 9: ScamShield ---------------------------------------------------
interface ScamInput {
  text?: string;
  contentRef?: string; // Cloud Storage path for uploaded screenshots
  language: string;
}

export const analyzeScam = onCall(callableOptions, async (request) => {
  requireAuth(request);
  const {text, contentRef, language} = (request.data ?? {}) as ScamInput;
  if (!text && !contentRef) {
    throw new HttpsError("invalid-argument", "Provide text or contentRef.");
  }

  // TODO: (OCR contentRef if image) then call the LLM for a risk assessment.
  return {
    id: "placeholder",
    language: language ?? "en",
    riskLevel: "moderate",
    reasons: ["Placeholder — LLM analysis not wired yet."],
    recommendedActions: ["Do not share personal info or send money."],
  };
});

// --- Feature 3: Career Bridge ------------------------------------------------
interface CareerInput {
  priorRole: string;
  language: string;
}

export const careerMap = onCall(callableOptions, async (request) => {
  requireAuth(request);
  const {priorRole} = (request.data ?? {}) as CareerInput;
  if (!priorRole) {
    throw new HttpsError("invalid-argument", "priorRole is required.");
  }

  // TODO: call the LLM to produce a US career pathway for `priorRole`.
  return {
    pathway: [priorRole, "Entry-level US role", "Certification", "Target role"],
  };
});
