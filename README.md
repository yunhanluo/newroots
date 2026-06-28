# newroots California

AI-powered integration, community, and safety navigator for immigrant families.
Cross-platform mobile app built with **Flutter + Firebase**.

> This repository is currently a **scaffold / basic outline**. Most screens and
> services are placeholders (search for `TODO` / `UnimplementedError`).
> See `DESIGN_PLAN.md` and `DEPLOY_PLAN.md` for the full architecture.

## Status

| Area | State |
|---|---|
| App structure (routing, theme, flavors) | Scaffolded |
| Feature screens (10 features) | Placeholders |
| Firebase wiring (Auth, Firestore, Functions) | Not yet connected |
| AI (Cloud Functions) | Stubbed client (`AiService`) |
| Localization (en, es, …) | ARB templates only |

## Project structure

```
lib/
  main.dart                  # entry point (Firebase init = TODO)
  app.dart                   # root MaterialApp.router
  firebase_options_*.dart    # PLACEHOLDERS (run `flutterfire configure`)
  l10n/                      # app_en.arb, app_es.arb
  core/
    config/flavor_config.dart  # dev/prod flavors
    theme/app_theme.dart
    router/app_router.dart     # GoRouter route table
    services/                  # auth_service.dart, ai_service.dart (stubs)
    models/                    # user_profile, roadmap, scam_report, resource
    widgets/placeholder_screen.dart
  features/
    auth/ profile/ home/
    roadmap/ housing/ career/ english_resources/ education/
    healthcare/ community/ support_groups/ scamshield/ safety_guide/
```

## Getting started

### Just want to see the UI? (no Firebase needed)

```bash
flutter pub get
flutter create --platforms=android,ios,web .   # add native folders if missing
flutter run -d chrome                            # or any connected device
```

This boots the placeholder UI using `lib/main.dart`. Firebase/AI features won't
work yet (they're stubbed), but the screens render.

### Full setup with Firebase

```bash
flutter pub get

# 1. Sign in to Firebase (one time)
firebase login

# 2. CREATE the projects first — flutterfire configure does NOT create them.
#    Project ids must be 6-30 chars, lowercase letters/numbers/hyphens, and are
#    GLOBALLY UNIQUE (add a suffix like -yourname if taken).
firebase projects:create newroots-dev  --display-name "NewRoots Dev"
firebase projects:create newroots-prod --display-name "NewRoots"

# 3. Generate the Firebase config for each project/flavor
flutterfire configure --project=newroots-dev  --out=lib/firebase_options_dev.dart
flutterfire configure --project=newroots-prod --out=lib/firebase_options_prod.dart

# 4. Run
flutter run
```

> See `DEPLOY_PLAN.md` §0–§5 for the complete cloud setup (Firestore, Auth,
> Cloud Functions, App Check, etc.).

## Next steps

1. `flutter create --platforms=android,ios,web .` to generate native platform folders if not present (additive — won't touch your `lib/`).
2. `firebase projects:create ...` (dev + prod), then `flutterfire configure`.
3. Initialize Firebase + App Check in `main.dart`.
4. Implement `AuthService` and the auth flow.
5. Build the flagship features first: Integration Roadmap and ScamShield.
6. Run `flutter gen-l10n` and switch `app.dart` to use `AppLocalizations`.

## Disclaimer

NewRoots is a navigation tool, not a substitute for legal, medical, or
financial professionals.
