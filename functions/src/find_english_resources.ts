/**
 * English Resource Finder — curated California ESL providers
 * (adult schools, community colleges, libraries, plus statewide online tools).
 */
import {readFileSync} from "fs";
import {dirname, join} from "path";
import {fileURLToPath} from "url";
import {HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {localizeStringList, replyLanguageName} from "./ai_language.js";

const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

export const findEnglishCallableOptions = {
  enforceAppCheck: false,
  secrets: [OPENAI_API_KEY],
  timeoutSeconds: 45,
  memory: "256MiB" as const,
};

interface EslResource {
  id: string;
  title: string;
  description: string;
  address: string;
  city: string;
  zip: string;
  lat: number;
  lng: number;
  website: string;
  category: string;
  languages: string[];
  verified?: boolean;
  statewide?: boolean;
}

interface FindInput {
  location?: string;
  radiusKm?: number;
  limit?: number;
  language?: string;
}

let cached: EslResource[] | null = null;

function loadResources(): EslResource[] {
  if (cached) return cached;
  const here = dirname(fileURLToPath(import.meta.url));
  const path = join(here, "..", "data", "ca_esl_resources.json");
  cached = JSON.parse(readFileSync(path, "utf8")) as EslResource[];
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

function categoryLabel(category: string): string {
  switch (category) {
  case "adult_school":
    return "Adult school";
  case "community_college":
    return "Community college";
  case "library":
    return "Public library";
  case "online":
    return "Online / statewide";
  default:
    return "English learning";
  }
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
        "User-Agent": "NewRootsCalifornia/0.1 (english-resource-finder)",
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

export async function handleFindEnglishResources(
  request: CallableRequest,
  requireAuth: (req: CallableRequest) => string,
): Promise<Record<string, unknown>> {
  requireAuth(request);
  const data = (request.data ?? {}) as FindInput;
  const location = String(data.location ?? "").trim();
  if (!location) {
    throw new HttpsError("invalid-argument", "Provide a city or ZIP code.");
  }

  const radiusKm = Math.min(Math.max(Number(data.radiusKm) || 50, 10), 120);
  const limit = Math.min(Math.max(Number(data.limit) || 40, 5), 80);
  const point = await geocode(location);
  const all = loadResources();

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
    .map((item) => ({item, distance: 0}));

  const resources = [...nearby, ...statewide].map(({item, distance}) => ({
    id: item.id,
    type: "english",
    title: item.title,
    description: `${categoryLabel(item.category)}. ${item.description}`,
    address: item.address,
    city: item.city,
    geohash: null,
    latitude: item.statewide ? null : item.lat,
    longitude: item.statewide ? null : item.lng,
    languages: item.languages ?? [],
    sourceUrl: item.website || null,
    verified: item.verified !== false,
    distanceKm: item.statewide ? null : distance,
  }));

  const languageName = replyLanguageName(data.language);
  try {
    const apiKey = OPENAI_API_KEY.value();
    if (apiKey) {
      const descriptions = await localizeStringList(
        apiKey,
        resources.map((resource) => resource.description),
        languageName,
      );
      for (let i = 0; i < resources.length; i++) {
        resources[i].description = descriptions[i];
      }
    }
  } catch (error) {
    console.warn("findEnglishResources description localize failed", error);
  }

  return {
    locationLabel: point.label,
    latitude: point.latitude,
    longitude: point.longitude,
    source: "curated",
    resources,
  };
}
