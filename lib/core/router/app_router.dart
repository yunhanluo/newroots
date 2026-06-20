import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_screen.dart';
import '../../features/career/presentation/career_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/education/presentation/education_screen.dart';
import '../../features/english_resources/presentation/english_resources_screen.dart';
import '../../features/healthcare/presentation/healthcare_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/housing/presentation/housing_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/roadmap/presentation/roadmap_screen.dart';
import '../../features/safety_guide/presentation/safety_guide_screen.dart';
import '../../features/scamshield/presentation/scamshield_screen.dart';
import '../../features/support_groups/presentation/support_groups_screen.dart';

/// Central route table. Names are referenced by screens via [context.goNamed].
abstract class Routes {
  static const auth = 'auth';
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
  // TODO: add redirect/guard based on authStateProvider once auth is wired.
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/auth',
        name: Routes.auth,
        builder: (context, state) => const AuthScreen(),
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
