import 'bootstrap.dart';
import 'core/config/flavor_config.dart';
import 'firebase_options_dev.dart';

/// Production entry point. Uses the newroots-dev Firebase project, which
/// serves both dev and prod.
///
/// Build with: `flutter build appbundle --flavor prod -t lib/main_prod.dart`
/// (see DEPLOY_PLAN.md §8–§9).
Future<void> main() => bootstrap(
      flavor: Flavor.prod,
      options: DefaultFirebaseOptions.currentPlatform,
    );
