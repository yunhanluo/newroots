/// App build flavors (see DEPLOY_PLAN.md §1).
///
/// Each flavor points at a different Firebase project so test data never
/// touches production.
enum Flavor { dev, prod }

class FlavorConfig {
  FlavorConfig._({
    required this.flavor,
    required this.appTitle,
    required this.firebaseProjectId,
  });

  final Flavor flavor;
  final String appTitle;
  final String firebaseProjectId;

  static FlavorConfig? _instance;

  static FlavorConfig get instance {
    final value = _instance;
    if (value == null) {
      throw StateError('FlavorConfig not initialized. Call FlavorConfig.init().');
    }
    return value;
  }

  static FlavorConfig init(Flavor flavor) {
    // TODO: wire real project ids once Firebase projects are created.
    _instance = FlavorConfig._(
      flavor: flavor,
      appTitle: flavor == Flavor.prod ? 'NewRoots' : 'NewRoots (dev)',
      firebaseProjectId:
          flavor == Flavor.prod ? 'newroots-prod' : 'newroots-dev',
    );
    return _instance!;
  }

  bool get isProd => flavor == Flavor.prod;
}
