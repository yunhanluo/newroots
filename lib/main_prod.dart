import 'bootstrap.dart';
import 'core/config/flavor_config.dart';
import 'firebase_options_prod.dart';

/// Production entry point.
///
/// Build with: `flutter build appbundle --flavor prod -t lib/main_prod.dart`
/// (see DEPLOY_PLAN.md §8–§9).
Future<void> main() => bootstrap(
      flavor: Flavor.prod,
      options: DefaultFirebaseOptions.currentPlatform,
    );
