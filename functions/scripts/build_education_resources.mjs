/**
 * Build ca_education_resources.json from the official CDE Public Schools
 * directory (tab-delimited), the CDE private schools GIS layer, and curated
 * support programs.
 *
 * Usage:
 *   node scripts/build_education_resources.mjs
 *   node scripts/build_education_resources.mjs /path/to/pubschls.txt [private.csv]
 *
 * If no local files are passed, downloads:
 *   https://www.cde.ca.gov/schooldirectory/report?rid=dl1&tp=txt
 *   https://gis.data.ca.gov/api/download/v1/items/261ee2533c3945afbaf3458ee32fae56/csv?layers=0
 */
import {mkdirSync, readFileSync, writeFileSync} from "fs";
import {dirname, join, resolve} from "path";
import {fileURLToPath} from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, "..");
const OUT_FUNCTIONS = join(ROOT, "data", "ca_education_resources.json");
const OUT_ASSETS = resolve(ROOT, "..", "assets", "data", "ca_education_resources.json");
const CDE_URL = "https://www.cde.ca.gov/schooldirectory/report?rid=dl1&tp=txt";
const CDE_PRIVATE_URL =
  "https://gis.data.ca.gov/api/download/v1/items/261ee2533c3945afbaf3458ee32fae56/csv?layers=0";

/// Private school rows carry no contact columns, so link the official CDE
/// directory record where phone and website are published.
const CDE_DETAILS_URL = "https://www.cde.ca.gov/SchoolDirectory/details?cdscode=";

const GRADE_TOKEN = {
  PK: -1,
  TK: 0,
  K: 0,
  KG: 0,
};

const GRADE_WORDS = {
  "PRESCHOOL": -1,
  "PRE-KINDERGARTEN": -1,
  "TRANSITIONAL KINDERGARTEN": 0,
  "KINDERGARTEN": 0,
  "FIRST GRADE": 1,
  "SECOND GRADE": 2,
  "THIRD GRADE": 3,
  "FOURTH GRADE": 4,
  "FIFTH GRADE": 5,
  "SIXTH GRADE": 6,
  "SEVENTH GRADE": 7,
  "EIGHTH GRADE": 8,
  "NINTH GRADE": 9,
  "TENTH GRADE": 10,
  "ELEVENTH GRADE": 11,
  "TWELFTH GRADE": 12,
};

/** @type {Array<Record<string, unknown>>} */
const SUPPORT_PROGRAMS = [
  {
    id: "edu-support-cde-directory",
    title: "California School Directory (CDE)",
    kind: "enrollment_help",
    category: "statewide",
    description:
      "Official California Department of Education directory to look up schools and districts.",
    address: "",
    city: "Sacramento",
    zip: "95814",
    district: "",
    website: "https://www.cde.ca.gov/SchoolDirectory/",
    phone: "",
    gradeLow: null,
    gradeHigh: null,
    gradeBands: ["elementary", "middle", "high"],
    lat: 38.5767,
    lng: -121.4934,
    statewide: true,
    verified: true,
    source: "cde",
  },
  {
    id: "edu-support-cde-enrollment",
    title: "CDE — Enrollment and registration guidance",
    kind: "enrollment_help",
    category: "statewide",
    description:
      "Statewide guidance on enrolling children in California public schools.",
    address: "",
    city: "Sacramento",
    zip: "95814",
    district: "",
    website: "https://www.cde.ca.gov/sp/hs/",
    phone: "",
    gradeLow: null,
    gradeHigh: null,
    gradeBands: ["elementary", "middle", "high"],
    lat: 38.5767,
    lng: -121.4934,
    statewide: true,
    verified: true,
    source: "cde",
  },
  {
    id: "edu-support-cde-el",
    title: "CDE — English learner resources",
    kind: "enrollment_help",
    category: "statewide",
    description:
      "Official resources for English learner programs and family supports.",
    address: "",
    city: "Sacramento",
    zip: "95814",
    district: "",
    website: "https://www.cde.ca.gov/sp/el/",
    phone: "",
    gradeLow: null,
    gradeHigh: null,
    gradeBands: ["elementary", "middle", "high"],
    lat: 38.5767,
    lng: -121.4934,
    statewide: true,
    verified: true,
    source: "cde",
  },
  {
    id: "edu-support-211",
    title: "211 California — local education referrals",
    kind: "enrollment_help",
    category: "statewide",
    description:
      "Call 211 or search online for local school, tutoring, and youth program referrals.",
    address: "",
    city: "Sacramento",
    zip: "95814",
    district: "",
    website: "https://www.211ca.org/",
    phone: "211",
    gradeLow: null,
    gradeHigh: null,
    gradeBands: ["elementary", "middle", "high"],
    lat: 38.5767,
    lng: -121.4934,
    statewide: true,
    verified: true,
    source: "211",
  },
  {
    id: "edu-lib-sfpl",
    title: "San Francisco Public Library — homework help",
    kind: "library",
    category: "library",
    description:
      "Free library card, computers, Wi‑Fi, and homework / tutoring resources for students.",
    address: "100 Larkin St",
    city: "San Francisco",
    zip: "94102",
    district: "",
    website: "https://sfpl.org/",
    phone: "415-557-4400",
    gradeLow: 0,
    gradeHigh: 12,
    gradeBands: ["elementary", "middle", "high"],
    lat: 37.7793,
    lng: -122.4192,
    statewide: false,
    verified: true,
    source: "curated",
  },
  {
    id: "edu-lib-lapl",
    title: "Los Angeles Public Library — student zone",
    kind: "library",
    category: "library",
    description:
      "Homework help, reading programs, and free student resources across LA branches.",
    address: "630 W 5th St",
    city: "Los Angeles",
    zip: "90071",
    district: "",
    website: "https://www.lapl.org/",
    phone: "213-228-7000",
    gradeLow: 0,
    gradeHigh: 12,
    gradeBands: ["elementary", "middle", "high"],
    lat: 34.0505,
    lng: -118.2551,
    statewide: false,
    verified: true,
    source: "curated",
  },
  {
    id: "edu-lib-sdpl",
    title: "San Diego Public Library — kids & teens",
    kind: "library",
    category: "library",
    description:
      "Free books, computers, and homework support for children and teens.",
    address: "330 Park Blvd",
    city: "San Diego",
    zip: "92101",
    district: "",
    website: "https://www.sandiego.gov/public-library",
    phone: "619-236-5800",
    gradeLow: 0,
    gradeHigh: 12,
    gradeBands: ["elementary", "middle", "high"],
    lat: 32.7089,
    lng: -117.1635,
    statewide: false,
    verified: true,
    source: "curated",
  },
  {
    id: "edu-lib-oakland",
    title: "Oakland Public Library — student support",
    kind: "library",
    category: "library",
    description:
      "Homework centers, reading programs, and free Wi‑Fi for Oakland families.",
    address: "125 14th St",
    city: "Oakland",
    zip: "94612",
    district: "",
    website: "https://oaklandlibrary.org/",
    phone: "510-238-3134",
    gradeLow: 0,
    gradeHigh: 12,
    gradeBands: ["elementary", "middle", "high"],
    lat: 37.8037,
    lng: -122.2712,
    statewide: false,
    verified: true,
    source: "curated",
  },
  {
    id: "edu-lib-sjpl",
    title: "San José Public Library — education resources",
    kind: "library",
    category: "library",
    description:
      "Student homework help, bilingual materials, and free library programs.",
    address: "150 E San Fernando St",
    city: "San Jose",
    zip: "95112",
    district: "",
    website: "https://www.sjpl.org/",
    phone: "408-808-2000",
    gradeLow: 0,
    gradeHigh: 12,
    gradeBands: ["elementary", "middle", "high"],
    lat: 37.3352,
    lng: -121.8853,
    statewide: false,
    verified: true,
    source: "curated",
  },
  {
    id: "edu-tutor-brainfuse",
    title: "Brainfuse HelpNow (via many CA libraries)",
    kind: "tutoring",
    category: "online",
    description:
      "Live online tutoring available free through many California public library cards.",
    address: "",
    city: "California",
    zip: "",
    district: "",
    website: "https://www.brainfuse.com/home/partners.asp",
    phone: "",
    gradeLow: 0,
    gradeHigh: 12,
    gradeBands: ["elementary", "middle", "high"],
    lat: 37.5,
    lng: -119.5,
    statewide: true,
    verified: true,
    source: "curated",
  },
  {
    id: "edu-tutor-khan",
    title: "Khan Academy — free online tutoring",
    kind: "tutoring",
    category: "online",
    description:
      "Free lessons and practice in math, science, and more for K–12 students.",
    address: "",
    city: "California",
    zip: "",
    district: "",
    website: "https://www.khanacademy.org/",
    phone: "",
    gradeLow: 0,
    gradeHigh: 12,
    gradeBands: ["elementary", "middle", "high"],
    lat: 37.5,
    lng: -119.5,
    statewide: true,
    verified: true,
    source: "curated",
  },
  {
    id: "edu-stem-exploratorium",
    title: "Exploratorium — science learning",
    kind: "stem",
    category: "museum",
    description:
      "Hands-on science museum and free / low-cost learning programs in San Francisco.",
    address: "Pier 15",
    city: "San Francisco",
    zip: "94111",
    district: "",
    website: "https://www.exploratorium.edu/",
    phone: "415-528-4444",
    gradeLow: 0,
    gradeHigh: 12,
    gradeBands: ["elementary", "middle", "high"],
    lat: 37.801,
    lng: -122.3988,
    statewide: false,
    verified: true,
    source: "curated",
  },
  {
    id: "edu-stem-caltech",
    title: "Caltech — K–12 STEM outreach",
    kind: "stem",
    category: "outreach",
    description:
      "Science and engineering programs and resources for students and educators.",
    address: "1200 E California Blvd",
    city: "Pasadena",
    zip: "91125",
    district: "",
    website: "https://www.caltech.edu/campus-life-events/outreach",
    phone: "",
    gradeLow: 6,
    gradeHigh: 12,
    gradeBands: ["middle", "high"],
    lat: 34.1377,
    lng: -118.1253,
    statewide: false,
    verified: true,
    source: "curated",
  },
  {
    id: "edu-stem-lawrence-hall",
    title: "Lawrence Hall of Science — UC Berkeley",
    kind: "stem",
    category: "museum",
    description:
      "Science museum and youth STEM programs overlooking the Bay Area.",
    address: "1 Centennial Dr",
    city: "Berkeley",
    zip: "94720",
    district: "",
    website: "https://lawrencehallofscience.org/",
    phone: "510-642-5132",
    gradeLow: 0,
    gradeHigh: 12,
    gradeBands: ["elementary", "middle", "high"],
    lat: 37.8735,
    lng: -122.247,
    statewide: false,
    verified: true,
    source: "curated",
  },
  {
    id: "edu-stem-cssf",
    title: "California Science & Engineering Fair",
    kind: "stem",
    category: "statewide",
    description:
      "Statewide science fair pathway for middle and high school students.",
    address: "",
    city: "Los Angeles",
    zip: "90037",
    district: "",
    website: "https://cssf.usc.edu/",
    phone: "",
    gradeLow: 6,
    gradeHigh: 12,
    gradeBands: ["middle", "high"],
    lat: 34.0205,
    lng: -118.2856,
    statewide: true,
    verified: true,
    source: "curated",
  },
];

function parseGradeToken(raw) {
  const token = String(raw ?? "").trim().toUpperCase();
  if (!token || token === "NO DATA") return null;
  if (Object.prototype.hasOwnProperty.call(GRADE_TOKEN, token)) {
    return GRADE_TOKEN[token];
  }
  const num = Number(token);
  if (Number.isFinite(num) && num >= -1 && num <= 12) return num;
  return null;
}

function parseGradeSpan(offered) {
  const text = String(offered ?? "").trim();
  if (!text || /^no data$/i.test(text)) {
    return {gradeLow: null, gradeHigh: null, gradeBands: []};
  }
  const parts = text.split(/[-–—to]+/i).map((p) => p.trim()).filter(Boolean);
  if (parts.length === 1) {
    const g = parseGradeToken(parts[0]);
    return {
      gradeLow: g,
      gradeHigh: g,
      gradeBands: bandsForRange(g, g),
    };
  }
  const low = parseGradeToken(parts[0]);
  const high = parseGradeToken(parts[parts.length - 1]);
  return {
    gradeLow: low,
    gradeHigh: high,
    gradeBands: bandsForRange(low, high),
  };
}

function bandsForRange(low, high) {
  if (low == null && high == null) return [];
  const start = low ?? high ?? 0;
  const end = high ?? low ?? 12;
  const bands = [];
  if (start <= 5 && end >= 0) bands.push("elementary");
  if (start <= 8 && end >= 6) bands.push("middle");
  if (start <= 12 && end >= 9) bands.push("high");
  return bands;
}

function cleanWebsite(raw) {
  let value = String(raw ?? "").trim();
  if (!value || /^no data$/i.test(value)) return "";
  if (!/^https?:\/\//i.test(value)) value = `https://${value}`;
  try {
    // eslint-disable-next-line no-new
    new URL(value);
    return value;
  } catch {
    return "";
  }
}

function isSchoolRow(row) {
  const cds = (row.CDSCode || "").trim();
  if (!/^\d{14}$/.test(cds)) return false;
  if (cds.endsWith("0000000")) return false;
  if ((row.StatusType || "").trim().toLowerCase() !== "active") return false;
  const school = (row.School || "").trim();
  if (!school || /^no data$/i.test(school)) return false;
  const lat = Number(row.Latitude);
  const lng = Number(row.Longitude);
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return false;
  if (lat < 32 || lat > 42 || lng < -125 || lng > -114) return false;
  return true;
}

function categoryFromEil(eilName, eilCode) {
  const name = `${eilName || ""} ${eilCode || ""}`.toLowerCase();
  if (name.includes("high")) return "high_school";
  if (name.includes("middle") || name.includes("junior")) return "middle_school";
  if (name.includes("elementary") || name.includes("primary")) {
    return "elementary_school";
  }
  if (name.includes("k-12") || name.includes("adult")) return "other_school";
  return "public_school";
}

/** Web Mercator (EPSG:3857) → WGS84, used by the CDE private schools layer. */
function mercatorToLatLng(x, y) {
  const mx = Number(x);
  const my = Number(y);
  if (!Number.isFinite(mx) || !Number.isFinite(my)) return null;
  const lng = (mx / 20037508.34) * 180;
  const lat =
    (Math.atan(Math.exp((my / 20037508.34) * Math.PI)) * 2 - Math.PI / 2) *
    (180 / Math.PI);
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null;
  return {lat, lng};
}

function parseCsvFile(text) {
  const clean = text.replace(/^\uFEFF/, "");
  const rows = [];
  /** @type {string[]} */
  let row = [];
  let field = "";
  let quoted = false;
  for (let i = 0; i < clean.length; i++) {
    const char = clean[i];
    if (quoted) {
      if (char === "\"") {
        if (clean[i + 1] === "\"") {
          field += "\"";
          i++;
        } else {
          quoted = false;
        }
      } else {
        field += char;
      }
      continue;
    }
    if (char === "\"") {
      quoted = true;
    } else if (char === ",") {
      row.push(field);
      field = "";
    } else if (char === "\n") {
      row.push(field);
      rows.push(row);
      row = [];
      field = "";
    } else if (char !== "\r") {
      field += char;
    }
  }
  if (field.length || row.length) {
    row.push(field);
    rows.push(row);
  }
  if (rows.length < 2) throw new Error("Private schools CSV is empty.");
  const headers = rows[0].map((h) => h.trim());
  return rows.slice(1).map((cols) => {
    /** @type {Record<string, string>} */
    const record = {};
    for (let c = 0; c < headers.length; c++) {
      record[headers[c]] = (cols[c] ?? "").trim();
    }
    return record;
  });
}

function parseGradeWord(raw) {
  const token = String(raw ?? "").trim().toUpperCase();
  if (!token) return null;
  if (Object.prototype.hasOwnProperty.call(GRADE_WORDS, token)) {
    return GRADE_WORDS[token];
  }
  return null;
}

function parseTabFile(text) {
  const lines = text.replace(/^\uFEFF/, "").split(/\r?\n/).filter((l) => l.length);
  if (lines.length < 2) throw new Error("CDE file is empty.");
  const headers = lines[0].split("\t").map((h) => h.trim());
  const rows = [];
  for (let i = 1; i < lines.length; i++) {
    const cols = lines[i].split("\t");
    /** @type {Record<string, string>} */
    const row = {};
    for (let c = 0; c < headers.length; c++) {
      row[headers[c]] = (cols[c] ?? "").trim();
    }
    rows.push(row);
  }
  return rows;
}

async function loadSourceText(localPath, url, label) {
  if (localPath) {
    console.log(`Reading local ${label} file: ${localPath}`);
    return readFileSync(localPath, "utf8");
  }
  console.log(`Downloading CDE ${label} file…`);
  const response = await fetch(url, {
    headers: {
      "User-Agent": "NewRootsCalifornia/0.1 (education-resource-builder)",
      Accept: "text/plain,text/csv,*/*",
    },
  });
  if (!response.ok) {
    throw new Error(`CDE ${label} download failed: HTTP ${response.status}`);
  }
  return await response.text();
}

function normalizeSchools(rows) {
  const out = [];
  for (const row of rows) {
    if (!isSchoolRow(row)) continue;
    const grades = parseGradeSpan(row.GSoffered || row.GSserved);
    const website = cleanWebsite(row.WebSite);
    out.push({
      id: `cde-${row.CDSCode}`,
      title: row.School,
      kind: "school",
      category: categoryFromEil(row.EILName, row.EILCode),
      description: [
        row.EILName && row.EILName !== "No Data" ? row.EILName : "Public school",
        row.District && row.District !== "No Data" ? row.District : "",
      ]
        .filter(Boolean)
        .join(" · "),
      address: row.Street && row.Street !== "No Data" ? row.Street : "",
      city: row.City && row.City !== "No Data" ? row.City : "",
      zip: (row.Zip || "").split("-")[0] || "",
      district: row.District && row.District !== "No Data" ? row.District : "",
      website,
      phone: row.Phone && row.Phone !== "No Data" ? row.Phone : "",
      gradeLow: grades.gradeLow,
      gradeHigh: grades.gradeHigh,
      gradeBands: grades.gradeBands,
      lat: Number(Number(row.Latitude).toFixed(6)),
      lng: Number(Number(row.Longitude).toFixed(6)),
      statewide: false,
      verified: true,
      source: "cde",
    });
  }
  return out;
}

function normalizePrivateSchools(rows) {
  const out = [];
  for (const row of rows) {
    const name = (row.USER_Name || "").trim();
    if (!name) continue;
    const point = mercatorToLatLng(row.X, row.Y);
    if (!point) continue;
    if (
      point.lat < 32 ||
      point.lat > 42.2 ||
      point.lng < -125 ||
      point.lng > -114
    ) {
      continue;
    }

    const cds = (row.USER_CDS || "").trim();
    const low = parseGradeWord(row.USER_LowGrade);
    const high = parseGradeWord(row.USER_HighGrade);
    const classification = (row.USER_Classification || "").trim();
    const coedType = (row.USER_Type || "").trim();

    out.push({
      id: cds ? `cde-private-${cds}` : `cde-private-${row.OBJECTID}`,
      title: name,
      kind: "private_school",
      category: classification ? classification.toLowerCase() : "private",
      description: [
        "Private school (tuition based)",
        classification,
        coedType,
      ]
        .filter(Boolean)
        .join(" · "),
      address: (row.USER_Street || "").trim(),
      city: (row.USER_City || "").trim(),
      zip: (row.USER_Zip || "").split("-")[0] || "",
      district: (row.USER_County || "").trim()
        ? `${row.USER_County.trim()} County`
        : "",
      website: cds ? `${CDE_DETAILS_URL}${cds}` : "",
      phone: "",
      gradeLow: low,
      gradeHigh: high,
      gradeBands: bandsForRange(low, high),
      lat: Number(point.lat.toFixed(6)),
      lng: Number(point.lng.toFixed(6)),
      statewide: false,
      verified: true,
      source: "cde-private",
    });
  }
  return out;
}

async function main() {
  const publicPath = process.argv[2] ? resolve(process.argv[2]) : "";
  const privatePath = process.argv[3] ? resolve(process.argv[3]) : "";

  const publicText = await loadSourceText(
    publicPath || undefined,
    CDE_URL,
    "public schools",
  );
  const schools = normalizeSchools(parseTabFile(publicText));
  if (schools.length < 1000) {
    throw new Error(
      `Expected thousands of active schools, got ${schools.length}. Aborting.`,
    );
  }

  const privateText = await loadSourceText(
    privatePath || undefined,
    CDE_PRIVATE_URL,
    "private schools",
  );
  const privateSchools = normalizePrivateSchools(parseCsvFile(privateText));
  if (privateSchools.length < 500) {
    throw new Error(
      `Expected thousands of private schools, got ${privateSchools.length}. Aborting.`,
    );
  }

  const ids = new Set();
  const combined = [...schools, ...privateSchools, ...SUPPORT_PROGRAMS].filter(
    (item) => {
      if (ids.has(item.id)) return false;
      ids.add(item.id);
      return true;
    },
  );

  const json = `${JSON.stringify(combined)}\n`;
  mkdirSync(dirname(OUT_FUNCTIONS), {recursive: true});
  mkdirSync(dirname(OUT_ASSETS), {recursive: true});
  writeFileSync(OUT_FUNCTIONS, json);
  writeFileSync(OUT_ASSETS, json);

  const supportCount = SUPPORT_PROGRAMS.length;
  console.log(
    `Wrote ${combined.length} resources ` +
      `(${schools.length} public + ${privateSchools.length} private + ` +
      `${supportCount} support) →\n` +
      `  ${OUT_FUNCTIONS}\n` +
      `  ${OUT_ASSETS}`,
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
