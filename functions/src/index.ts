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
import {handleRoadmapAi, roadmapCallableOptions} from "./roadmap_ai.js";
import {handleCareerAi, careerCallableOptions} from "./career_ai.js";
import {handleHousingAi, housingCallableOptions} from "./housing_ai.js";
import {handleAnalyzeScam, scamCallableOptions} from "./scam_ai.js";
import {
  handleFindEnglishResources,
  findEnglishCallableOptions,
} from "./find_english_resources.js";
import {
  handleSeedEnglishResources,
  seedEnglishCallableOptions,
} from "./seed_english_resources.js";
import {
  handleFindHealthCenters,
  healthCentersCallableOptions,
} from "./find_health_centers.js";
import {
  handleFindEducationResources,
  educationResourcesCallableOptions,
} from "./find_education_resources.js";
import {
  handleEducationSchoolSummary,
  educationAiCallableOptions,
} from "./education_ai.js";
import {
  handleSeedSupportGroups,
  seedSupportGroupsCallableOptions,
} from "./seed_support_groups.js";
import {
  handleEnsureAdminClaim,
  ensureAdminClaimCallableOptions,
} from "./ensure_admin_claim.js";

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

export const roadmapAi = onCall(roadmapCallableOptions, async (request) => {
  return handleRoadmapAi(request, requireAuth);
});

// --- Feature 9: ScamShield ---------------------------------------------------
export const analyzeScam = onCall(scamCallableOptions, async (request) => {
  return handleAnalyzeScam(request, requireAuth);
});

// --- Feature 3: Career Bridge ------------------------------------------------
export const careerMap = onCall(careerCallableOptions, async (request) => {
  return handleCareerAi(request, requireAuth);
});

// --- Feature 2: Housing Navigator --------------------------------------------
export const housingAi = onCall(housingCallableOptions, async (request) => {
  return handleHousingAi(request, requireAuth);
});

// --- Feature 4: English Resource Finder (live Places + seed fallback) --------
export const seedEnglishResources = onCall(
  seedEnglishCallableOptions,
  async (request) => {
    return handleSeedEnglishResources(request, requireAuth);
  },
);

export const findEnglishResources = onCall(
  findEnglishCallableOptions,
  async (request) => {
    return handleFindEnglishResources(request, requireAuth);
  },
);

// --- Feature 6: Healthcare Navigator (HRSA community health centers) ---------
export const findHealthCenters = onCall(
  healthCentersCallableOptions,
  async (request) => {
    return handleFindHealthCenters(request, requireAuth);
  },
);

// --- Feature 5: Education Navigator (CDE schools + support programs) ---------
export const findEducationResources = onCall(
  educationResourcesCallableOptions,
  async (request) => {
    return handleFindEducationResources(request, requireAuth);
  },
);

export const educationSchoolSummary = onCall(
  educationAiCallableOptions,
  async (request) => {
    return handleEducationSchoolSummary(request, requireAuth);
  },
);

// --- Feature 8: Mutual Support Groups ---------------------------------------
export const seedSupportGroups = onCall(
  seedSupportGroupsCallableOptions,
  async (request) => {
    return handleSeedSupportGroups(request, requireAuth);
  },
);

export const ensureAdminClaim = onCall(
  ensureAdminClaimCallableOptions,
  async (request) => {
    return handleEnsureAdminClaim(request, requireAuth);
  },
);
