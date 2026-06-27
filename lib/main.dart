import 'bootstrap.dart';
import 'core/config/flavor_config.dart';
import 'firebase_options_dev.dart';

/// Default / development entry point.
///
/// Run with: `flutter run` (or `flutter run --flavor dev -t lib/main.dart`
/// once native flavors are configured).
/// For production builds use `lib/main_prod.dart`.
Future<void> main() => bootstrap(
      flavor: Flavor.dev,
      options: DefaultFirebaseOptions.currentPlatform,
    );
