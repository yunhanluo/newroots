/**
 * Seeds curated English/ESL resources with geohash fields.
 */
import {CallableRequest} from "firebase-functions/v2/https";
import {getFirestore} from "firebase-admin/firestore";
import {initializeApp, getApps} from "firebase-admin/app";

if (getApps().length === 0) {
  initializeApp();
}

interface SeedResource {
  id: string;
  title: string;
  description: string;
  address: string;
  city: string;
  latitude: number;
  longitude: number;
  languages: string[];
  sourceUrl: string;
}

// Approximate coordinates for demo ESL / adult education programs in CA.
const ENGLISH_RESOURCES: SeedResource[] = [
  {
    id: "esl-sfpl",
    title: "San Francisco Public Library — ESL & Conversation",
    description:
      "Free English conversation practice and ESL resources through SFPL branches.",
    address: "100 Larkin St",
    city: "San Francisco",
    latitude: 37.7793,
    longitude: -122.4192,
    languages: ["en", "es", "zh"],
    sourceUrl: "https://sfpl.org/",
  },
  {
    id: "esl-oakland-adult",
    title: "Oakland Adult & Career Education — ESL",
    description:
      "Adult ESL classes for beginners through advanced learners in Oakland.",
    address: "Oakland Adult Education",
    city: "Oakland",
    latitude: 37.8044,
    longitude: -122.2712,
    languages: ["en", "es"],
    sourceUrl: "https://www.ousd.org/",
  },
  {
    id: "esl-sjeccd",
    title: "San José — Community College ESL",
    description:
      "ESL and noncredit English courses through San José area community colleges.",
    address: "San José, CA",
    city: "San Jose",
    latitude: 37.3382,
    longitude: -121.8863,
    languages: ["en", "es", "vi"],
    sourceUrl: "https://www.sjcc.edu/",
  },
  {
    id: "esl-la-library",
    title: "Los Angeles Public Library — Learn English",
    description:
      "Free English learning programs, conversation clubs, and online ESL tools.",
    address: "630 W 5th St",
    city: "Los Angeles",
    latitude: 34.0505,
    longitude: -118.2551,
    languages: ["en", "es", "ko", "zh"],
    sourceUrl: "https://www.lapl.org/",
  },
  {
    id: "esl-lausd-adult",
    title: "LAUSD Division of Adult & Career Education — ESL",
    description:
      "Large adult ESL program across Los Angeles with day and evening classes.",
    address: "Los Angeles, CA",
    city: "Los Angeles",
    latitude: 34.0522,
    longitude: -118.2437,
    languages: ["en", "es"],
    sourceUrl: "https://www.lausd.org/",
  },
  {
    id: "esl-sd-library",
    title: "San Diego Public Library — ESL Conversation",
    description:
      "English conversation groups and learner resources at San Diego libraries.",
    address: "330 Park Blvd",
    city: "San Diego",
    latitude: 32.7087,
    longitude: -117.1637,
    languages: ["en", "es"],
    sourceUrl: "https://www.sandiego.gov/public-library",
  },
  {
    id: "esl-sacramento-adult",
    title: "Sacramento City Unified — Adult ESL",
    description:
      "Adult education ESL classes for immigrants and English learners in Sacramento.",
    address: "Sacramento, CA",
    city: "Sacramento",
    latitude: 38.5816,
    longitude: -121.4944,
    languages: ["en", "es", "hmn"],
    sourceUrl: "https://www.scusd.edu/",
  },
  {
    id: "esl-fresno-adult",
    title: "Fresno Adult School — ESL",
    description:
      "ESL classes for adults in the Fresno area, including beginner levels.",
    address: "Fresno, CA",
    city: "Fresno",
    latitude: 36.7378,
    longitude: -119.7871,
    languages: ["en", "es"],
    sourceUrl: "https://www.fresnou.org/",
  },
  {
    id: "esl-anaheim-nroc",
    title: "North Orange Continuing Education — ESL",
    description:
      "Free and low-cost ESL classes in the North Orange County area.",
    address: "Anaheim, CA",
    city: "Anaheim",
    latitude: 33.8366,
    longitude: -117.9143,
    languages: ["en", "es", "vi", "ko"],
    sourceUrl: "https://www.noce.edu/",
  },
  {
    id: "esl-usahello",
    title: "USAHello — Free Online English",
    description:
      "Free online English lessons and immigrant resources (statewide / remote).",
    address: "Online",
    city: "California",
    latitude: 36.7783,
    longitude: -119.4179,
    languages: ["en", "es"],
    sourceUrl: "https://usahello.org/",
  },
];

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

export const seedEnglishCallableOptions = {
  enforceAppCheck: false,
};

export async function handleSeedEnglishResources(
  request: CallableRequest,
  requireAuth: (req: CallableRequest) => string,
): Promise<Record<string, unknown>> {
  requireAuth(request);
  const db = getFirestore();
  const batch = db.batch();
  let written = 0;

  for (const resource of ENGLISH_RESOURCES) {
    const ref = db.collection("resources").doc(resource.id);
    batch.set(
      ref,
      {
        type: "english",
        title: resource.title,
        description: resource.description,
        address: resource.address,
        city: resource.city,
        latitude: resource.latitude,
        longitude: resource.longitude,
        geohash: encodeGeohash(resource.latitude, resource.longitude, 9),
        languages: resource.languages,
        sourceUrl: resource.sourceUrl,
        verified: true,
        updatedAt: new Date().toISOString(),
      },
      {merge: true},
    );
    written += 1;
  }

  await batch.commit();
  return {ok: true, written};
}
