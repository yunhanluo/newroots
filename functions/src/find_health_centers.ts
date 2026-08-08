/**
 * Healthcare Navigator — find nearby HRSA community health centers in California.
 * Uses the offline CA extract of HRSA Service Delivery / Look-Alike sites.
 */
import {readFileSync} from "fs";
import {dirname, join} from "path";
import {fileURLToPath} from "url";
import {HttpsError, CallableRequest} from "firebase-functions/v2/https";

export const healthCentersCallableOptions = {
  enforceAppCheck: false,
  timeoutSeconds: 30,
  memory: "512MiB" as const,
};

interface HealthCenter {
  id: string;
  name: string;
  org: string;
  address: string;
  city: string;
  zip: string;
  phone: string;
  website: string;
  type: string;
  lat: number;
  lng: number;
}

interface FindInput {
  location?: string;
  radiusKm?: number;
  limit?: number;
}

let cachedCenters: HealthCenter[] | null = null;

function loadCenters(): HealthCenter[] {
  if (cachedCenters) return cachedCenters;
  const here = dirname(fileURLToPath(import.meta.url));
  const path = join(here, "..", "data", "hrsa_ca_health_centers.json");
  const raw = readFileSync(path, "utf8");
  cachedCenters = JSON.parse(raw) as HealthCenter[];
  return cachedCenters;
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
        "User-Agent": "NewRootsCalifornia/0.1 (healthcare-navigator)",
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

export async function handleFindHealthCenters(
  request: CallableRequest,
  requireAuth: (req: CallableRequest) => string,
): Promise<Record<string, unknown>> {
  requireAuth(request);
  const data = (request.data ?? {}) as FindInput;
  const location = String(data.location ?? "").trim();
  if (!location) {
    throw new HttpsError("invalid-argument", "Provide a city or ZIP code.");
  }

  const radiusKm = Math.min(Math.max(Number(data.radiusKm) || 40, 5), 120);
  const limit = Math.min(Math.max(Number(data.limit) || 40, 5), 80);
  const point = await geocode(location);
  const centers = loadCenters();

  const nearby = centers
    .map((center) => {
      const distance = distanceKm(
        point.latitude,
        point.longitude,
        center.lat,
        center.lng,
      );
      return {...center, distanceKm: distance};
    })
    .filter((center) => center.distanceKm <= radiusKm)
    .sort((a, b) => a.distanceKm - b.distanceKm)
    .slice(0, limit);

  return {
    locationLabel: point.label,
    latitude: point.latitude,
    longitude: point.longitude,
    source: "hrsa",
    centers: nearby,
  };
}
