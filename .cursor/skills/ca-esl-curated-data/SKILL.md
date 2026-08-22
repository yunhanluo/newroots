---
name: ca-esl-curated-data
description: >-
  Maintain and expand NewRoots California curated ESL resource data
  (assets/data/ca_esl_resources.json and functions/data copy). Use when the
  user mentions ESL coverage, English Learning data quality, adult schools,
  CAEP, community college ESL listings, or asks to expand/fix English
  resource pins.
---

# California curated ESL data

You own expanding and maintaining the curated ESL directory for NewRoots.

## Source of truth

- App/asset: `assets/data/ca_esl_resources.json`
- Functions copy (required for deploy): `functions/data/ca_esl_resources.json`
- Keep both files identical.
- Finder: `functions/src/find_english_resources.ts` (geocode + radius filter; no Photon).

## Entry schema

```json
{
  "id": "esl-kebab-unique",
  "title": "Agency — ESL",
  "description": "One or two sentences about who they serve.",
  "address": "Street or Online",
  "city": "City",
  "zip": "#####",
  "lat": 0.0,
  "lng": 0.0,
  "website": "https://...",
  "category": "adult_school | community_college | library | online",
  "languages": ["en", "es"],
  "verified": true,
  "statewide": false
}
```

- Prefer public adult schools, community college ESL/noncredit, library literacy, and a few statewide online tools.
- Use real campus/main-office coordinates (approximate OK; not city centroid when a better point is known).
- `statewide: true` only for online directories/tools; those skip map pins and always append in results.
- Never use Photon/OSM as the primary ESL database again.

## When expanding

1. Deduplicate by `id` and near-duplicate title+city.
2. Prefer coverage gaps (smaller cities, Central Valley, North State, Imperial, Inland Empire) before adding more downtown LA/SF duplicates.
3. After edits, copy JSON to both paths, run `npm run build` in `functions/`, deploy `findEnglishResources` when the user wants it live.
4. Do not invent fake agencies; if unsure, skip or mark only well-known public providers.

## Quality bar

Trusted public providers beat noisy live map search. Sparse-but-real > dense-but-wrong.
