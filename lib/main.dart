import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/flavor_config.dart';

/// Default entry point. For flavored builds use:
///   flutter run -t lib/main_dev.dart  (TODO: add main_dev.dart / main_prod.dart)
///
/// PLACEHOLDER: Firebase initialization is intentionally NOT called yet.
/// Once `flutterfire configure` has generated the options files, initialize
/// Firebase here before runApp (see DEPLOY_PLAN.md §3).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig.init(Flavor.dev);

  // TODO: initialize Firebase + App Check + Crashlytics, e.g.
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptionsDev.currentPlatform,
  // );
  // await FirebaseAppCheck.instance.activate(...);

  runApp(const ProviderScope(child: NewRootsApp()));
}
