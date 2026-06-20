# NewRoots California

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

```bash
flutter pub get

# Generate Firebase config (creates a real project first — see DEPLOY_PLAN.md)
flutterfire configure --project=newroots-dev  --out=lib/firebase_options_dev.dart
flutterfire configure --project=newroots-prod --out=lib/firebase_options_prod.dart

flutter run
```

## Next steps

1. `flutter create .` to generate native platform folders (android/ios) if not present.
2. Create Firebase projects (dev + prod) and run `flutterfire configure`.
3. Initialize Firebase + App Check in `main.dart`.
4. Implement `AuthService` and the auth flow.
5. Build the flagship features first: Integration Roadmap and ScamShield.
6. Run `flutter gen-l10n` and switch `app.dart` to use `AppLocalizations`.

## Disclaimer

NewRoots is a navigation tool, not a substitute for legal, medical, or
financial professionals.
