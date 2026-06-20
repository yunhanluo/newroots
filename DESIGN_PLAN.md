# NewRoots California — General Design Plan

> AI-powered integration, community, and safety navigator for immigrant families.
> **Platform: cross-platform mobile app (iOS + Android) built with Flutter + Firebase.**

This document outlines the recommended architecture, technology choices, and feature-to-system mapping for building NewRoots California as a native mobile app. It is scoped to be **realistic for a small team (or a single Congressional App Challenge student)** while leaving a clean path to scale into a public-benefit platform.

---

## 1. Design Principles

1. **Mobile-first & offline-friendly.** Many newcomers rely on phones and limited data plans; key guides should work offline.
2. **Multilingual from day one.** Language is a first-class concept, not an afterthought (including RTL for Arabic).
3. **Trust and safety over flash.** Clear sourcing of resources, honest AI ("navigation, not legal advice"), privacy by default.
4. **Accessible.** Large tap targets, high contrast, screen-reader support (TalkBack/VoiceOver), ~6th-grade reading level.
5. **Build small, ship the core, expand.** Start with 2–3 flagship features (Roadmap, ScamShield, Resource Finder) rather than all 10 at once.

---

## 2. Recommended Tech Stack

### Decision summary

| Layer | Recommendation | Why |
|---|---|---|
| App framework | **Flutter (Dart)** | One codebase → iOS + Android, high performance, consistent UI, excellent Firebase integration (FlutterFire). |
| State management | **Riverpod** (or Bloc) | Predictable, testable state; Riverpod is simpler to learn. |
| Backend platform | **Firebase** (BaaS) | Auth, database, storage, serverless functions, push, and analytics in one place — minimal ops for a small team. |
| Database | **Cloud Firestore** | Real-time, offline-first NoSQL; great for mobile. (Model carefully — see §5.) |
| Auth | **Firebase Authentication** | Email/phone/social login; phone auth is friendly for newcomers. |
| File storage | **Cloud Storage for Firebase** | ScamShield uploads (screenshots/emails). |
| Serverless / AI | **Cloud Functions for Firebase** | Hold secret keys; run LLM calls server-side. |
| LLM | **Vertex AI (Gemini)** via Firebase, or OpenAI/Anthropic via Cloud Functions | Vertex AI integrates natively with Firebase + App Check; third-party providers go through Functions. |
| Push notifications | **Firebase Cloud Messaging (FCM)** | Scam alerts, group activity, reminders. |
| Translation | **Vertex AI/LLM for dynamic content + Flutter `intl`/ARB files for static UI** | Static strings localized once; dynamic AI responses generated in target language. |
| Remote config / flags | **Firebase Remote Config** | Toggle features, tune content without app store releases. |
| Analytics & crash | **Firebase Analytics + Crashlytics** | Usage insight and crash reporting. |
| Security | **Firebase App Check + Security Rules** | Block abuse; enforce per-user data access. |

### Why a backend is required (not just the app + database)

A mobile app **cannot safely hold secret API keys** — anyone can decompile the binary and extract them. So even though Firebase lets the app talk to Firestore directly, AI provider keys and any privileged logic must live in **Cloud Functions**:

- **Secret management:** AI/third-party keys stay server-side in Functions.
- **AI orchestration:** roadmap generation, ScamShield risk analysis, career mapping run in Functions.
- **Moderation & validation:** server-side checks on user uploads and group posts.
- **App Check** ensures only your real app (not scripts) can call your backend.

> Firestore + Firebase Auth handle most CRUD directly from the app (guarded by Security Rules). **Cloud Functions are the "backend" for anything secret or privileged**, primarily AI.

---

## 3. High-Level Architecture

```
┌─────────────────────────────────────────────┐
│              Flutter App (iOS/Android)        │
│   - Riverpod state, GoRouter navigation       │
│   - i18n (ARB files) + RTL                    │
│   - Offline cache (Firestore persistence)     │
│   - FlutterFire SDKs + App Check              │
└───────┬───────────────────────────┬───────────┘
        │ (direct, via Rules)        │ (secret/privileged)
┌───────▼──────────────┐   ┌─────────▼───────────────┐
│   Firebase            │   │  Cloud Functions         │
│   - Firestore (DB)    │   │  - /generateRoadmap      │
│   - Auth              │   │  - /analyzeScam          │
│   - Cloud Storage     │   │  - /careerMap            │
│   - FCM (push)        │   │  - moderation hooks      │
│   - Remote Config     │   └─────────┬────────────────┘
│   - Analytics/Crash   │             │
└───────────────────────┘   ┌─────────▼───────────────┐
                            │  LLM: Vertex AI (Gemini) │
                            │  or OpenAI/Anthropic     │
                            └──────────────────────────┘
```

---

## 4. Feature → System Mapping

| Feature | Cloud Function? | AI? | Firestore data | Notes |
|---|---|---|---|---|
| 1. Integration Roadmap | Yes | Yes | profile, generated plan | Generate once, store, allow regeneration. |
| 2. Housing Navigator | Maybe | Yes | curated housing resources | Retrieval + AI explanation. |
| 3. Career Bridge | Yes | Yes | saved career maps | LLM maps prior role → US pathway. |
| 4. English Resource Finder | No | Optional | localized ESL resources | Filter by location/language. |
| 5. Education Navigator | No | Optional | school/district resources | Geo + grade filters. |
| 6. Healthcare Navigator | No | Optional | clinics, language tags | Find providers by spoken language. |
| 7. Community Connection | No | Optional | orgs, events | Curated + community-submitted. |
| 8. Mutual Support Groups | Yes (moderation) | No | groups, memberships, posts | Real-time; needs moderation. |
| 9. ScamShield | Yes | Yes | uploads, risk reports, alerts | Core differentiator; LLM risk + explanation. |
| 10. Community Safety Guide | No | No | emergency contacts, KYR docs | Mostly static, localized, offline-cached. |

---

## 5. Data Model (Firestore collections)

Firestore is NoSQL, so model for the queries you need (denormalize where it helps reads):

- `users/{uid}` → profile (language, family_size, location/geohash, employment, children_ages)
- `users/{uid}/roadmaps/{id}` → generated plan
- `resources/{id}` → { type, title, description, geohash, languages[], source_url, verified }
- `groups/{id}` + `groups/{id}/members/{uid}` + `groups/{id}/posts/{id}`
- `users/{uid}/scamReports/{id}` → { contentRef, risk_level, ai_explanation, isPublic }
- `scamAlerts/{id}` → { region, summary, severity, createdAt }
- `emergencyContacts/{id}` → { region, type, phone, languages[] }

**Querying notes (vs. a relational DB):**
- Use **geohash** for "near me" queries (the `geoflutterfire` approach) since Firestore lacks native geo-range queries.
- `array-contains` works for filtering by a single language tag; combining many inequality filters is limited — denormalize or add composite indexes.
- Keep private data under `users/{uid}/...` so Security Rules are simple (owner-only).

**Security Rules** enforce access: owner-only for profiles/roadmaps/scamReports; public-read for `resources`, `scamAlerts`, `emergencyContacts`; group posts readable by members only.

---

## 6. AI Strategy

- **Secrets stay in Cloud Functions.** If using a third-party LLM (OpenAI/Anthropic), the key lives in Functions config. If using **Vertex AI in Firebase (Gemini)**, calls can be made with App Check protection.
- **Structured prompts with guardrails.** System prompts enforce: respond in the user's language, never give legal/immigration *advice*, always recommend verifying with official sources, cite the resource source.
- **Structured JSON outputs** for roadmaps and scam risk so the Flutter UI renders typed cards.
- **ScamShield flow:** app uploads text/screenshot to Cloud Storage → Function (OCR if image) → LLM returns `{ risk_level, reasons[], recommended_actions[] }` → store + optionally contribute anonymized pattern to `scamAlerts`.
- **Cost control:** small/cheap model, cache common roadmap templates, per-user rate limiting, App Check to block abuse.

---

## 7. Multilingual Approach

- **Static UI strings:** Flutter `intl` + ARB files per locale (en, es, zh, vi, ko, hi, ar). Enable RTL layout for Arabic.
- **Dynamic content:** generated by the LLM directly in the target language.
- **Curated resources:** store a `languages[]` tag; optionally store human-reviewed translations of key descriptions.
- Language selection stored in the user profile, with device locale as fallback (`flutter_localizations`).

---

## 8. Security, Privacy & Trust

- All traffic over HTTPS (Firebase default).
- Minimal PII; **never request immigration status.** Sensitive fields optional.
- Firestore encryption at rest (default) + strict Security Rules + **App Check**.
- Clear disclaimers: "NewRoots is a navigation tool, not a substitute for legal, medical, or financial professionals."
- Content moderation on group posts and scam uploads (Cloud Functions).
- Plain-language, multilingual privacy policy (required for App Store / Play Store).

---

## 9. Suggested Build Phases (MVP-first)

1. **Phase 1 (MVP):** Auth + profile, Integration Roadmap (AI via Function), Resource Finder (1 category), English + Spanish. → demoable end-to-end.
2. **Phase 2:** ScamShield (the standout feature), more languages (zh, vi), Safety Guide (offline).
3. **Phase 3:** Community groups + FCM alerts, Career Bridge, Education/Healthcare navigators.
4. **Phase 4:** Partnerships, county content seeding, mentor network.

---

## 10. Accessibility & UX Notes

- Large fonts, high contrast, bottom nav bar, simple flows.
- Reading level ~6th grade for all UI copy.
- Offline cache of static safety guides via Firestore persistence + bundled assets.
- Test with TalkBack (Android) and VoiceOver (iOS), and Flutter's `Semantics` widgets.

---

## Stack TL;DR

**Flutter (Dart)** app on **iOS + Android**, backed by **Firebase** (Firestore, Auth, Cloud Storage, FCM, Remote Config, Analytics/Crashlytics). **Yes, there is a backend** — **Cloud Functions** hold secret keys and run the **AI** (Vertex AI Gemini or OpenAI/Anthropic). **App Check + Security Rules** secure everything.
