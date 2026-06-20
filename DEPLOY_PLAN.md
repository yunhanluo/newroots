# NewRoots California — Detailed Deploy Plan

A step-by-step guide to take the app from local development to the **App Store and Google Play**, plus deploying the backend. Matches the stack in `DESIGN_PLAN.md`: **Flutter (Dart)** app backed by **Firebase** (Firestore, Auth, Cloud Storage, Cloud Functions, FCM), with an **LLM** (Vertex AI Gemini or OpenAI/Anthropic) called from Cloud Functions.

---

## 0. Prerequisites & Accounts

| Need | Service | Cost |
|---|---|---|
| Code hosting | GitHub | Free |
| Backend (DB/Auth/Functions/etc.) | Firebase (Google Cloud) | Free tier (Spark) → Blaze (pay-as-you-go, needed for Functions + outbound AI calls) |
| AI | Vertex AI (Gemini) **or** OpenAI/Anthropic | Pay-as-you-go (set budget alerts) |
| iOS distribution | **Apple Developer Program** | **$99/year** |
| Android distribution | **Google Play Developer** | **$25 one-time** |

Local tools:

```bash
# Flutter SDK + Dart
flutter --version            # ensure stable channel
# Firebase tooling
npm i -g firebase-tools
dart pub global activate flutterfire_cli
# Platform tooling
# - Xcode (macOS, for iOS builds)
# - Android Studio + SDK (for Android builds)
flutter doctor               # must be all green for both platforms
```

> Note: building/signing **iOS requires a Mac with Xcode**. Android can build anywhere.

---

## 1. Environments

Use separate Firebase projects so test data never touches production:

| Environment | Firebase project | App identifier (suffix) |
|---|---|---|
| **Dev** | `newroots-dev` | `org.newroots.app.dev` |
| **Prod** | `newroots-prod` | `org.newroots.app` |

Wire these into Flutter using **flavors** (Android product flavors + iOS schemes) so each build points at the right Firebase config. Run FlutterFire config once per flavor:

```bash
flutterfire configure --project=newroots-dev   --out=lib/firebase_options_dev.dart
flutterfire configure --project=newroots-prod  --out=lib/firebase_options_prod.dart
```

---

## 2. Repository Setup

```bash
git init
gh repo create newroots --private --source=. --push
```

`.gitignore` essentials: `.dart_tool/`, `build/`, `*.g.dart` (if generated), `ios/Pods/`, `android/.gradle/`, `**/firebase_options*.dart` only if they contain restricted keys (Firebase config is generally safe to commit, but keep service-account JSON and any AI keys OUT of git), `functions/node_modules/`, `.env*`, signing keystores (`*.jks`, `*.keystore`), and `ios/` provisioning profiles.

Branching: `main` = release-ready. Feature branches → PR → CI → merge.

---

## 3. Firebase Provisioning (per project: dev + prod)

In the Firebase console (or CLI) for each project:

1. **Create project**, choose region close to California (e.g. `us-west1`) for Firestore/Functions.
2. **Enable Authentication** → email/password, phone, and any social providers.
3. **Create Firestore** in production mode (locked); you'll add rules next.
4. **Enable Cloud Storage** (for ScamShield uploads).
5. **Upgrade to the Blaze plan** (required for Cloud Functions and outbound network/AI calls). Set a **budget alert**.
6. **Enable Cloud Messaging (FCM)** for push.
7. **Enable App Check** (reCAPTCHA / Play Integrity / App Attest).
8. (If using Gemini) **Enable Vertex AI** in the linked Google Cloud project.

Register the **iOS app** and **Android app** in each Firebase project; download `GoogleService-Info.plist` / `google-services.json` (FlutterFire CLI handles wiring).

---

## 4. Security Rules & Indexes (tracked in git)

Define rules locally and deploy them — don't hand-edit in the console for production.

```bash
firebase init firestore        # creates firestore.rules + firestore.indexes.json
firebase init storage          # creates storage.rules
```

Rules to implement:
- `users/{uid}/**`: read/write only if `request.auth.uid == uid`.
- `resources`, `scamAlerts`, `emergencyContacts`: public read; write only by admins (custom claim).
- `groups/{id}/posts`: read/write only by group members.
- Storage `scamshield-uploads/{uid}/**`: owner-only.

Add **composite indexes** for multi-field queries (e.g. resources by `type` + `languages`).

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

---

## 5. Cloud Functions (the AI backend)

```bash
firebase init functions        # choose TypeScript
cd functions && npm install
```

Implement callable functions: `generateRoadmap`, `analyzeScam`, `careerMap`, plus moderation triggers.

**Secrets** (AI keys) go in Secret Manager, never in code:

```bash
firebase functions:secrets:set OPENAI_API_KEY        # or ANTHROPIC_API_KEY
# (Vertex AI/Gemini uses Google service-account auth, no key needed)
```

Harden functions: enforce **App Check**, verify `context.auth`, add per-user rate limiting, set timeouts, return friendly errors.

Deploy:

```bash
firebase use newroots-dev  && firebase deploy --only functions   # test first
firebase use newroots-prod && firebase deploy --only functions   # release
```

---

## 6. App Build Configuration

1. **Bundle IDs / package names** set per flavor (see §1).
2. **App icons & splash** via `flutter_launcher_icons` / `flutter_native_splash`.
3. **App Check** integrated in the Flutter app init.
4. **Permissions:** camera/photos (ScamShield uploads), notifications (FCM) — add usage strings to `Info.plist` (iOS) and `AndroidManifest.xml`.
5. **Versioning:** manage `version: x.y.z+build` in `pubspec.yaml`; bump build number every store upload.

Local verification before any release build:

```bash
flutter pub get
flutter analyze        # lint — must pass
flutter test           # unit/widget tests
flutter run --flavor dev   # smoke test on simulator/device
```

Smoke test: sign up → create profile → generate roadmap (Function/AI works) → run one ScamShield analysis → switch language → receive a test push.

---

## 7. CI/CD Pipeline

Use **GitHub Actions** for CI (lint/test/build) and **Codemagic** or **Fastlane** for store delivery. Example CI:

```yaml
# .github/workflows/ci.yml
name: CI
on: [pull_request]
jobs:
  flutter:
    runs-on: macos-latest        # macOS so iOS build can be validated
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: stable }
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk --flavor dev --debug   # build smoke check
```

Separate release workflows (manual trigger or on tag) handle signed builds + upload via Fastlane.

Backend CD: deploy Firebase rules/functions on merge to `main`:

```yaml
# (in a deploy workflow)
- run: npm i -g firebase-tools
- run: firebase deploy --only functions,firestore:rules,storage --project newroots-prod --token "$FIREBASE_TOKEN"
```

---

## 8. Android Release → Google Play

1. **Generate an upload keystore** and configure signing in `android/key.properties` + `build.gradle` (keep keystore out of git; store as a CI secret).
2. Build the app bundle:

```bash
flutter build appbundle --flavor prod --release
```

3. In **Play Console:** create the app, fill store listing (multilingual descriptions), content rating, **data safety form**, target audience, privacy policy URL.
4. Upload the `.aab` to the **Internal testing** track first → then Closed/Open testing → **Production**.
5. Enroll in **Play App Signing** (Google manages the signing key).

---

## 9. iOS Release → App Store

> Requires a Mac + Xcode + Apple Developer Program membership.

1. In **Apple Developer:** create App ID, certificates, and provisioning profiles (or let Xcode "Automatically manage signing").
2. Build the IPA / archive:

```bash
flutter build ipa --flavor prod --release
```

3. Upload to **App Store Connect** (via Xcode Organizer or `xcrun altool` / Transporter / Fastlane `deliver`).
4. Create the App Store listing: multilingual metadata, screenshots per device size, privacy nutrition labels, **age rating**, privacy policy URL.
5. Submit for **App Review** (expect 1–3 days; AI + user-generated content may draw extra scrutiny — be ready to explain moderation).
6. Use **TestFlight** for beta testing before public release.

---

## 10. Push Notifications (FCM)

- Android: works via `google-services.json` out of the box.
- iOS: upload an **APNs Auth Key (.p8)** to Firebase → Project Settings → Cloud Messaging; enable Push Notifications + Background Modes capabilities in Xcode.
- Test from the Firebase console "Cloud Messaging" composer to a test device token.

---

## 11. AI Provider Hardening (production)

- Set a **monthly budget alert / cap** in Google Cloud (Vertex) or the OpenAI/Anthropic dashboard.
- Enforce **App Check** on all callable functions so only the real app can invoke AI.
- **Per-user rate limiting** in Functions (Firestore counters or a token bucket).
- Timeouts + graceful fallback messages; log token usage to monitor cost.

---

## 12. Observability & Monitoring

| Concern | Tool |
|---|---|
| Crashes | Firebase **Crashlytics** |
| Usage analytics | Firebase **Analytics** |
| Function errors/logs | Cloud Functions logs / Cloud Logging |
| Performance | Firebase **Performance Monitoring** |
| AI cost | GCP/provider billing dashboard + custom usage logs |
| Alerts | Cloud Monitoring alerts (error rate, budget) |

---

## 13. Security & Store-Readiness Checklist (pre-launch)

- [ ] Firestore + Storage Security Rules deployed and tested (owner-only private data).
- [ ] App Check enforced on Functions and Firestore.
- [ ] AI keys in Secret Manager, never in the app binary or git.
- [ ] Signing keystore (Android) and certificates (iOS) backed up securely.
- [ ] Rate limiting on AI/auth-sensitive functions.
- [ ] Content moderation on uploads/group posts.
- [ ] Multilingual privacy policy published (required by both stores).
- [ ] Play **Data Safety** form + Apple **privacy labels** completed accurately.
- [ ] Permissions justified with usage strings; no unused permissions.
- [ ] `flutter analyze` + tests pass; dependency audit clean.

---

## 14. Launch Runbook

1. Freeze `main`; CI green.
2. Deploy backend to prod: `firebase deploy --only functions,firestore:rules,firestore:indexes,storage --project newroots-prod`.
3. Seed initial data: resources, emergency contacts, sample scam alerts.
4. Bump app version/build in `pubspec.yaml`.
5. Build signed release artifacts (`appbundle` + `ipa`, prod flavor).
6. Upload to **Play internal testing** and **TestFlight**; smoke test on real devices.
7. Promote to Production / submit for App Review.
8. Confirm Crashlytics, Analytics, and budget alerts are receiving data.
9. Announce once both stores approve.

---

## 15. Post-Launch Operations

- **Backups:** schedule **Firestore exports** to Cloud Storage (via `gcloud firestore export` on a Cloud Scheduler job).
- **Backend rollback:** redeploy a previous Functions version; keep rules versioned in git. (Firestore data changes aren't auto-reversible — migrate carefully.)
- **App rollback:** halt staged rollout in Play Console; for iOS, expedite a fixed build (no instant rollback once released).
- **OTA-style updates:** use **Firebase Remote Config** to toggle features/content without a store release; code changes still require a new store build.
- **Content updates:** build a small admin tool (web or protected screen) to add/verify resources and post scam alerts.
- **Scaling:** Firebase scales automatically; watch Firestore read/write costs and Function invocation costs; add caching and pagination as usage grows.
- **Cost review:** monthly check of Firebase (Blaze) + AI spend.

---

## Deploy TL;DR

Build a **Flutter** app with **dev/prod Firebase projects** (flavors). Data/auth/storage/push run on **Firebase**; the **AI backend is Cloud Functions** (keys in Secret Manager, protected by **App Check**). CI via **GitHub Actions**; store delivery via **Fastlane/Codemagic** to **Google Play** (`.aab`, $25 once) and the **App Store** (`.ipa`, $99/yr, needs a Mac). Lock down with **Security Rules + App Check**, set **AI budget caps + rate limits**, wire up **Crashlytics/Analytics**, complete both stores' **privacy forms**, then follow the launch runbook.
