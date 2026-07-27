/**
 * English Resource Finder — live nearby ESL via Photon (OpenStreetMap).
 * Photon is a fast geocoder; no API key required. Falls back to seeded
 * Firestore data if live search fails or returns nothing.
 */
import {HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {getFirestore} from "firebase-admin/firestore";
import {initializeApp, getApps} from "firebase-admin/app";
import {handleSeedEnglishResources} from "./seed_english_resources.js";

if (getApps().length === 0) {
  initializeApp();
}

export const findEnglishCallableOptions = {
  enforceAppCheck: false,
  timeoutSeconds: 30,
};

const BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz";

function encodeGeohash(
  latitude: number,
  longitude: number,
  precision = 9,
): string {
  let latMin = -90;
  let latMax = 90;
  let lngMin = -180;
  let lngMax = 180;
  let hash = "";
  let bit = 0;
  let ch = 0;
  let even = true;

  while (hash.length < precision) {
    if (even) {
      const mid = (lngMin + lngMax) / 2;
      if (longitude >= mid) {
        ch |= 1 << (4 - bit);
        lngMin = mid;
      } else {
        lngMax = mid;
      }
    } else {
      const mid = (latMin + latMax) / 2;
      if (latitude >= mid) {
        ch |= 1 << (4 - bit);
        latMin = mid;
      } else {
        latMax = mid;
      }
    }
    even = !even;
    if (bit < 4) {
      bit += 1;
    } else {
      hash += BASE32[ch];
      bit = 0;
      ch = 0;
    }
  }
  return hash;
}

type Direction = "top" | "bottom" | "left" | "right";

function adjacent(hash: string, direction: Direction): string {
  if (!hash) return "";
  const neighbor: Record<Direction, [string, string]> = {
    right: [
      "bc01fg45238967deuvhjyznpkmstqrwx",
      "p0r21436x8zb9dcf5h7kjnmqesgutwvy",
    ],
    left: [
      "238967debc01fg45kmstqrwxuvhjyznp",
      "14365h7k9dcfesgujnmqp0r2twvyx8zb",
    ],
    top: [
      "p0r21436x8zb9dcf5h7kjnmqesgutwvy",
      "bc01fg45238967deuvhjyznpkmstqrwx",
    ],
    bottom: [
      "14365h7k9dcfesgujnmqp0r2twvyx8zb",
      "238967debc01fg45kmstqrwxuvhjyznp",
    ],
  };
  const border: Record<Direction, [string, string]> = {
    right: ["bcfguvyz", "prxz"],
    left: ["0145hjnp", "028b"],
    top: ["prxz", "bcfguvyz"],
    bottom: ["028b", "0145hjnp"],
  };

  const last = hash[hash.length - 1];
  let parent = hash.slice(0, -1);
  const type = hash.length % 2 === 1 ? 0 : 1;
  if (border[direction][type].includes(last) && parent) {
    parent = adjacent(parent, direction);
  }
  if (!parent && border[direction][type].includes(last)) {
    return "";
  }
  const idx = BASE32.indexOf(last);
  return parent + neighbor[direction][type][idx];
}

function queryPrefixes(hash: string): Set<string> {
  const top = adjacent(hash, "top");
  const bottom = adjacent(hash, "bottom");
  return new Set(
    [
      hash,
      top,
      bottom,
      adjacent(hash, "left"),
      adjacent(hash, "right"),
      adjacent(top, "left"),
      adjacent(top, "right"),
      adjacent(bottom, "left"),
      adjacent(bottom, "right"),
    ].filter(Boolean),
  );
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

interface ResourcePayload {
  id: string;
  type: string;
  title: string;
  description: string;
  address: string;
  city: string;
  geohash: string | null;
  latitude: number | null;
  longitude: number | null;
  languages: string[];
  sourceUrl: string | null;
  verified: boolean;
  distanceKm: number;
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

interface PhotonFeature {
  geometry?: {coordinates?: [number, number]};
  properties?: {
    osm_id?: number;
    osm_type?: string;
    osm_key?: string;
    osm_value?: string;
    name?: string;
    street?: string;
    housenumber?: string;
    city?: string;
    state?: string;
    postcode?: string;
    country?: string;
    countrycode?: string;
    type?: string;
  };
}

function isRelevantEnglishHit(name: string, osmValue: string): boolean {
  const blob = `${name} ${osmValue}`.toLowerCase();
  if (osmValue === "language_school") return true;
  return (
    /\besl\b/.test(blob) ||
    /english as a second language/.test(blob) ||
    /adult (english|school|education)/.test(blob) ||
    /english (class|classes|school|learning|conversation|literacy)/.test(
      blob,
    ) ||
    /learn english/.test(blob) ||
    /language school/.test(blob) ||
    /esl/.test(blob)
  );
}

async function photonQuery(
  textQuery: string,
  latitude: number,
  longitude: number,
  signal: AbortSignal,
): Promise<PhotonFeature[]> {
  const url = new URL("https://photon.komoot.io/api/");
  url.searchParams.set("q", textQuery);
  url.searchParams.set("lat", String(latitude));
  url.searchParams.set("lon", String(longitude));
  url.searchParams.set("limit", "15");
  url.searchParams.set("lang", "en");

  const response = await fetch(url, {
    headers: {
      "User-Agent": "NewRootsCalifornia/0.1 (english-resource-finder)",
      "Accept": "application/json",
    },
    signal,
  });
  if (!response.ok) {
    throw new Error(`Photon HTTP ${response.status}`);
  }
  const json = (await response.json()) as {features?: PhotonFeature[]};
  return json.features ?? [];
}

async function searchPhotonNearby(
  latitude: number,
  longitude: number,
): Promise<ResourcePayload[]> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 6000);
  const queries = [
    "ESL",
    "English as a Second Language",
    "adult English class",
    "language school English",
  ];

  try {
    const settled = await Promise.allSettled(
      queries.map((q) => photonQuery(q, latitude, longitude, controller.signal)),
    );

    const byId = new Map<string, ResourcePayload>();
    for (const result of settled) {
      if (result.status !== "fulfilled") continue;
      for (const feature of result.value) {
        const props = feature.properties ?? {};
        const coords = feature.geometry?.coordinates;
        if (!coords || coords.length < 2) continue;
        const [lng, lat] = coords;
        if (!Number.isFinite(lat) || !Number.isFinite(lng)) continue;

        const name = props.name?.trim() ?? "";
        const osmValue = props.osm_value ?? "";
        if (!name || !isRelevantEnglishHit(name, osmValue)) continue;

        const distance = distanceKm(latitude, longitude, lat, lng);
        if (distance > 50) continue;

        const country = (props.countrycode || props.country || "").toLowerCase();
        if (country && !country.includes("us") && country !== "usa") continue;

        const osmType = props.osm_type || "N";
        const osmId = props.osm_id ?? 0;
        const id = `photon-${osmType}-${osmId}-${name.toLowerCase()}`;
        if (byId.has(id)) continue;

        const street = [props.housenumber, props.street]
          .filter(Boolean)
          .join(" ")
          .trim();
        const address = [
          street,
          props.city,
          props.state,
          props.postcode,
        ]
          .filter(Boolean)
          .join(", ");
        const mapsUrl = osmId ?
          `https://www.openstreetmap.org/${
            osmType === "W" ? "way" : osmType === "R" ? "relation" : "node"
          }/${osmId}` :
          null;

        byId.set(id, {
          id,
          type: "english",
          title: name,
          description:
            "Live nearby result for English / ESL learning.",
          address,
          city: props.city ?? "",
          geohash: encodeGeohash(lat, lng, 9),
          latitude: lat,
          longitude: lng,
          languages: ["en"],
          sourceUrl: mapsUrl,
          verified: false,
          distanceKm: distance,
        });
      }
    }

    return [...byId.values()].sort((a, b) => a.distanceKm - b.distanceKm);
  } finally {
    clearTimeout(timer);
  }
}

async function searchSeededNearby(
  latitude: number,
  longitude: number,
): Promise<ResourcePayload[]> {
  const prefix = encodeGeohash(latitude, longitude, 4);
  const prefixes = queryPrefixes(prefix);
  const db = getFirestore();
  const byId = new Map<string, Record<string, unknown> & {id: string}>();

  await Promise.all(
    [...prefixes].map(async (p) => {
      const snap = await db
        .collection("resources")
        .where("type", "==", "english")
        .where("geohash", ">=", p)
        .where("geohash", "<", p + "\uf8ff")
        .limit(40)
        .get();
      for (const doc of snap.docs) {
        if (!byId.has(doc.id)) {
          byId.set(doc.id, {id: doc.id, ...doc.data()});
        }
      }
    }),
  );

  return [...byId.values()]
    .map((raw) => {
      const lat = Number(raw.latitude);
      const lng = Number(raw.longitude);
      const distanceKmValue =
        Number.isFinite(lat) && Number.isFinite(lng) ?
          distanceKm(latitude, longitude, lat, lng) :
          Number.POSITIVE_INFINITY;
      return {
        id: String(raw.id),
        type: String(raw.type ?? "english"),
        title: String(raw.title ?? ""),
        description: String(raw.description ?? ""),
        address: String(raw.address ?? ""),
        city: String(raw.city ?? ""),
        geohash: raw.geohash ? String(raw.geohash) : null,
        latitude: Number.isFinite(lat) ? lat : null,
        longitude: Number.isFinite(lng) ? lng : null,
        languages: Array.isArray(raw.languages) ?
          raw.languages.filter((v): v is string => typeof v === "string") :
          [],
        sourceUrl: raw.sourceUrl ? String(raw.sourceUrl) : null,
        verified: Boolean(raw.verified),
        distanceKm: distanceKmValue,
      };
    })
    .filter((item) => item.distanceKm <= 80)
    .sort((a, b) => a.distanceKm - b.distanceKm);
}

export async function handleFindEnglishResources(
  request: CallableRequest,
  requireAuth: (req: CallableRequest) => string,
): Promise<Record<string, unknown>> {
  requireAuth(request);
  const location = String(
    (request.data as {location?: string} | undefined)?.location ?? "",
  ).trim();
  if (!location) {
    throw new HttpsError("invalid-argument", "Provide a city or ZIP code.");
  }

  const point = await geocode(location);

  let resources: ResourcePayload[] = [];
  let source = "photon";

  try {
    resources = await searchPhotonNearby(point.latitude, point.longitude);
  } catch (error) {
    console.error("Photon search failed, falling back to seed data", error);
    source = "seed_fallback";
  }

  if (!resources.length) {
    // Read-only fallback first (fast). Seed only if nothing is stored yet.
    resources = await searchSeededNearby(point.latitude, point.longitude);
    if (!resources.length) {
      await handleSeedEnglishResources(request, requireAuth);
      resources = await searchSeededNearby(point.latitude, point.longitude);
    }
    source = "seed_fallback";
  }

  return {
    locationLabel: point.label,
    latitude: point.latitude,
    longitude: point.longitude,
    source,
    resources,
  };
}
