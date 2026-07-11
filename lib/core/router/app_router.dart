import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../../features/about/presentation/about_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/career/presentation/career_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/education/presentation/education_screen.dart';
import '../../features/english_resources/presentation/english_resources_screen.dart';
import '../../features/healthcare/presentation/healthcare_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/housing/presentation/housing_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/roadmap/presentation/roadmap_screen.dart';
import '../../features/safety_guide/presentation/safety_guide_screen.dart';
import '../../features/scamshield/presentation/scamshield_screen.dart';
import '../../features/support_groups/presentation/support_groups_screen.dart';

/// Central route table. Names are referenced by screens via [context.goNamed].
abstract class Routes {
  static const auth = 'auth';
  static const signup = 'signup';
  static const about = 'about';
  static const onboarding = 'onboarding';
  static const home = 'home';
  static const profile = 'profile';
  static const roadmap = 'roadmap';
  static const housing = 'housing';
  static const career = 'career';
  static const english = 'english';
  static const education = 'education';
  static const healthcare = 'healthcare';
  static const community = 'community';
  static const supportGroups = 'support-groups';
  static const scamShield = 'scamshield';
  static const safety = 'safety';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _GoRouterRefreshStream(authService.authStateChanges()),
    redirect: (context, state) {
      final loggedIn = authService.currentUser != null;
      final atPublicRoute = state.matchedLocation == '/auth' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/about';

      if (!loggedIn) return atPublicRoute ? null : '/auth';
      if (loggedIn &&
          (state.matchedLocation == '/auth' ||
              state.matchedLocation == '/signup')) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        name: Routes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: Routes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/about',
        name: Routes.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/',
        name: Routes.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            name: Routes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'roadmap',
            name: Routes.roadmap,
            builder: (context, state) => const RoadmapScreen(),
          ),
          GoRoute(
            path: 'housing',
            name: Routes.housing,
            builder: (context, state) => const HousingScreen(),
          ),
          GoRoute(
            path: 'career',
            name: Routes.career,
            builder: (context, state) => const CareerScreen(),
          ),
          GoRoute(
            path: 'english',
            name: Routes.english,
            builder: (context, state) => const EnglishResourcesScreen(),
          ),
          GoRoute(
            path: 'education',
            name: Routes.education,
            builder: (context, state) => const EducationScreen(),
          ),
          GoRoute(
            path: 'healthcare',
            name: Routes.healthcare,
            builder: (context, state) => const HealthcareScreen(),
          ),
          GoRoute(
            path: 'community',
            name: Routes.community,
            builder: (context, state) => const CommunityScreen(),
          ),
          GoRoute(
            path: 'support-groups',
            name: Routes.supportGroups,
            builder: (context, state) => const SupportGroupsScreen(),
          ),
          GoRoute(
            path: 'scamshield',
            name: Routes.scamShield,
            builder: (context, state) => const ScamShieldScreen(),
          ),
          GoRoute(
            path: 'safety',
            name: Routes.safety,
            builder: (context, state) => const SafetyGuideScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
});

/// Bridges a [Stream] (auth state) to a [Listenable] so GoRouter re-runs its
/// redirect logic whenever the user logs in or out.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
