import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/flavor_config.dart';
import 'core/services/static_guide_service.dart';

/// Shared startup logic for every flavor (see DEPLOY_PLAN.md §3).
///
/// Each entry point (`main.dart` = dev, `main_prod.dart` = prod) passes its own
/// flavor and the matching generated [FirebaseOptions].
Future<void> bootstrap({
  required Flavor flavor,
  required FirebaseOptions options,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig.init(flavor);

  await Firebase.initializeApp(options: options);

  _enableFirestorePersistence();
  unawaited(_prefetchStaticGuides());

  await _activateAppCheck(flavor);

  runApp(const ProviderScope(child: NewRootsApp()));
}

/// Offline cache for Firestore docs (including `guides/{id}` after first fetch).
void _enableFirestorePersistence() {
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (error, stack) {
    debugPrint('Firestore persistence setup failed: $error\n$stack');
  }
}

/// Warm bundled + disk cache so safety/education/healthcare/housing open offline.
Future<void> _prefetchStaticGuides() async {
  try {
    await StaticGuideService(FirebaseFirestore.instance).prefetchAll();
  } catch (error, stack) {
    debugPrint('Static guide prefetch failed: $error\n$stack');
  }
}

/// App Check blocks abuse so only the real app can call Firebase/Functions.
///
/// Dev uses debug providers (so emulators/simulators work). Prod uses the
/// hardened attestation providers.
Future<void> _activateAppCheck(Flavor flavor) async {
  if (kIsWeb) {
    // TODO: web App Check needs a reCAPTCHA v3 site key. Once you have one:
    //   await FirebaseAppCheck.instance.activate(
    //     webProvider: ReCaptchaV3Provider('your-site-key'),
    //   );
    return;
  }

  await FirebaseAppCheck.instance.activate(
    providerAndroid: flavor == Flavor.prod
        ? const AndroidPlayIntegrityProvider()
        : const AndroidDebugProvider(),
    providerApple: flavor == Flavor.prod
        ? const AppleAppAttestProvider()
        : const AppleDebugProvider(),
  );
}
