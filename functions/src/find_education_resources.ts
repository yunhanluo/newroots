/**
 * Education Navigator — find nearby California public schools and curated
 * support programs (libraries, tutoring, STEM, enrollment help).
 */
import {readFileSync} from "fs";
import {dirname, join} from "path";
import {fileURLToPath} from "url";
import {HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {localizeStringList, replyLanguageName} from "./ai_language.js";

const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

export const educationResourcesCallableOptions = {
  enforceAppCheck: false,
  secrets: [OPENAI_API_KEY],
  timeoutSeconds: 45,
  memory: "512MiB" as const,
};

interface EducationResource {
  id: string;
  title: string;
  kind: string;
  category: string;
  description: string;
  address: string;
  city: string;
  zip: string;
  district: string;
  website: string;
  phone: string;
  gradeLow: number | null;
  gradeHigh: number | null;
  gradeBands: string[];
  lat: number;
  lng: number;
  statewide?: boolean;
  verified?: boolean;
  source?: string;
}

interface FindInput {
  location?: string;
  radiusKm?: number;
  limit?: number;
  /** elementary | middle | high | all / empty */
  gradeBand?: string;
  /** Lowest grade the family cares about (-1 = PK, 0 = K, 1-12). */
  gradeMin?: number;
  /** Highest grade the family cares about (-1 = PK, 0 = K, 1-12). */
  gradeMax?: number;
  /** school | enrollment_help | library | tutoring | stem | all / empty */
  kind?: string;
  language?: string;
}

const VALID_GRADE_BANDS = new Set(["elementary", "middle", "high"]);
const GRADE_FLOOR = -1;
const GRADE_CEILING = 12;
const VALID_KINDS = new Set([
  "school",
  "private_school",
  "enrollment_help",
  "library",
  "tutoring",
  "stem",
]);

const SCHOOL_KINDS = new Set(["school", "private_school"]);

let cached: EducationResource[] | null = null;

function loadResources(): EducationResource[] {
  if (cached) return cached;
  const here = dirname(fileURLToPath(import.meta.url));
  const path = join(here, "..", "data", "ca_education_resources.json");
  cached = JSON.parse(readFileSync(path, "utf8")) as EducationResource[];
  return cached;
}

function distanceKm(
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number,
): number {
  const toRad = (deg: number) => (deg * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return 6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function matchesGradeBand(item: EducationResource, gradeBand: string): boolean {
  if (!gradeBand || gradeBand === "all") return true;
  if (!VALID_GRADE_BANDS.has(gradeBand)) return true;
  if (!item.gradeBands || item.gradeBands.length === 0) {
    // Statewide / unknown grade span — keep for non-school kinds.
    return !SCHOOL_KINDS.has(item.kind);
  }
  return item.gradeBands.includes(gradeBand);
}

/**
 * Keeps resources whose grade span overlaps the requested range. Programs with
 * no grade span (libraries, statewide help) stay visible; schools do not,
 * since an unknown span cannot be shown to serve the requested grades.
 */
function matchesGradeRange(
  item: EducationResource,
  gradeMin: number,
  gradeMax: number,
): boolean {
  const low = item.gradeLow;
  const high = item.gradeHigh;
  if (low === null || low === undefined || high === null || high === undefined) {
    return !SCHOOL_KINDS.has(item.kind);
  }
  return low <= gradeMax && high >= gradeMin;
}

function matchesKind(item: EducationResource, kind: string): boolean {
  if (!kind || kind === "all") return true;
  if (!VALID_KINDS.has(kind)) return true;
  return item.kind === kind;
}

async function geocode(locationText: string): Promise<{
  latitude: number;
  longitude: number;
  label: string;
}> {
  const query = locationText.trim();
  const q =
    /california|\bca\b/i.test(query) ? query : `${query}, California, USA`;
  const url = new URL("https://nominatim.openstreetmap.org/search");
  url.searchParams.set("q", q);
  url.searchParams.set("format", "json");
  url.searchParams.set("limit", "1");
  url.searchParams.set("countrycodes", "us");

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 5000);
  try {
    const response = await fetch(url, {
      headers: {
        "User-Agent": "NewRootsCalifornia/0.1 (education-navigator)",
        "Accept": "application/json",
      },
      signal: controller.signal,
    });
    if (!response.ok) {
      throw new HttpsError(
        "unavailable",
        `Geocoding failed (HTTP ${response.status}).`,
      );
    }
    const data = (await response.json()) as {
      lat?: string;
      lon?: string;
      display_name?: string;
    }[];
    if (!data.length || !data[0].lat || !data[0].lon) {
      throw new HttpsError(
        "not-found",
        "Could not find that location. Try a California city or ZIP code.",
      );
    }
    return {
      latitude: Number(data[0].lat),
      longitude: Number(data[0].lon),
      label: data[0].display_name ?? query,
    };
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    throw new HttpsError(
      "unavailable",
      "Could not look up that location. Try again shortly.",
    );
  } finally {
    clearTimeout(timer);
  }
}

export async function handleFindEducationResources(
  request: CallableRequest,
  requireAuth: (req: CallableRequest) => string,
): Promise<Record<string, unknown>> {
  requireAuth(request);
  const data = (request.data ?? {}) as FindInput;
  const location = String(data.location ?? "").trim();
  if (!location) {
    throw new HttpsError("invalid-argument", "Provide a city or ZIP code.");
  }

  const gradeBand = String(data.gradeBand ?? "all").trim().toLowerCase();
  const kind = String(data.kind ?? "all").trim().toLowerCase();
  const radiusKm = Math.min(Math.max(Number(data.radiusKm) || 25, 5), 80);
  const limit = Math.min(Math.max(Number(data.limit) || 40, 5), 80);

  const clampGrade = (value: number) =>
    Math.min(Math.max(Math.round(value), GRADE_FLOOR), GRADE_CEILING);
  const hasRange =
    Number.isFinite(Number(data.gradeMin)) &&
    Number.isFinite(Number(data.gradeMax));
  let gradeMin = GRADE_FLOOR;
  let gradeMax = GRADE_CEILING;
  if (hasRange) {
    const a = clampGrade(Number(data.gradeMin));
    const b = clampGrade(Number(data.gradeMax));
    gradeMin = Math.min(a, b);
    gradeMax = Math.max(a, b);
  }
  // A full-width range means "any grade", so skip grade filtering entirely.
  const filterByRange =
    hasRange && !(gradeMin === GRADE_FLOOR && gradeMax === GRADE_CEILING);

  const point = await geocode(location);
  const all = loadResources().filter((item) => {
    if (!matchesKind(item, kind)) return false;
    return filterByRange ?
      matchesGradeRange(item, gradeMin, gradeMax) :
      matchesGradeBand(item, gradeBand);
  });

  const nearby = all
    .filter((item) => !item.statewide)
    .map((item) => {
      const distance = distanceKm(
        point.latitude,
        point.longitude,
        item.lat,
        item.lng,
      );
      return {item, distance};
    })
    .filter(({distance}) => distance <= radiusKm)
    .sort((a, b) => a.distance - b.distance)
    .slice(0, limit);

  const statewide = all
    .filter((item) => item.statewide)
    .map((item) => ({item, distance: 0 as number | null}));

  const resources = [...nearby, ...statewide].map(({item, distance}) => ({
    id: item.id,
    title: item.title,
    kind: item.kind,
    category: item.category,
    description: item.description,
    address: item.address,
    city: item.city,
    zip: item.zip,
    district: item.district,
    website: item.website,
    phone: item.phone,
    gradeLow: item.gradeLow,
    gradeHigh: item.gradeHigh,
    gradeBands: item.gradeBands ?? [],
    lat: item.statewide ? null : item.lat,
    lng: item.statewide ? null : item.lng,
    verified: item.verified !== false,
    source: item.source ?? "cde",
    distanceKm: item.statewide ? null : distance,
  }));

  const languageName = replyLanguageName(data.language);
  try {
    const apiKey = OPENAI_API_KEY.value();
    if (apiKey) {
      const toTranslate = resources.map((resource) =>
        resource.description.includes(" · ") ? "" : resource.description
      );
      const localized = await localizeStringList(
        apiKey,
        toTranslate,
        languageName,
      );
      for (let i = 0; i < resources.length; i++) {
        if (toTranslate[i]) resources[i].description = localized[i];
      }
    }
  } catch (error) {
    console.warn("findEducationResources description localize failed", error);
  }

  return {
    locationLabel: point.label,
    latitude: point.latitude,
    longitude: point.longitude,
    source: "cde+curated",
    resources,
  };
}
