import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../../features/about/presentation/about_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/career/presentation/career_screen.dart';
import '../../features/education/presentation/education_screen.dart';
import '../../features/education/presentation/education_tutorial_screen.dart';
import '../../features/education/presentation/find_education_resources_screen.dart';
import '../../features/english_resources/presentation/english_resources_screen.dart';
import '../../features/healthcare/presentation/find_clinics_screen.dart';
import '../../features/healthcare/presentation/healthcare_screen.dart';
import '../../features/healthcare/presentation/healthcare_tutorial_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/housing/presentation/housing_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/privacy/presentation/privacy_policy_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/roadmap/presentation/roadmap_screen.dart';
import '../../features/safety_guide/presentation/safety_guide_screen.dart';
import '../../features/scamshield/presentation/scamshield_screen.dart';
import '../../features/support_groups/presentation/group_admin_screen.dart';
import '../../features/support_groups/presentation/group_chat_screen.dart';
import '../../features/support_groups/presentation/group_compose_screen.dart';
import '../../features/support_groups/presentation/group_post_screen.dart';
import '../../features/support_groups/presentation/suggest_group_screen.dart';
import '../../features/support_groups/presentation/support_groups_screen.dart';
import '../models/support_group.dart';

/// Central route table. Names are referenced by screens via [context.goNamed].
abstract class Routes {
  static const auth = 'auth';
  static const signup = 'signup';
  static const about = 'about';
  static const privacy = 'privacy';
  static const onboarding = 'onboarding';
  static const home = 'home';
  static const profile = 'profile';
  static const roadmap = 'roadmap';
  static const housing = 'housing';
  static const career = 'career';
  static const english = 'english';
  static const education = 'education';
  static const educationTutorial = 'education-tutorial';
  static const educationResources = 'education-resources';
  static const healthcare = 'healthcare';
  static const healthcareTutorial = 'healthcare-tutorial';
  static const healthcareClinics = 'healthcare-clinics';
  static const supportGroups = 'support-groups';
  static const supportGroupDetail = 'support-group-detail';
  static const supportGroupCompose = 'support-group-compose';
  static const supportGroupPost = 'support-group-post';
  static const suggestGroup = 'suggest-group';
  static const groupAdmin = 'group-admin';
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
          state.matchedLocation == '/about' ||
          state.matchedLocation == '/privacy';

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
        path: '/privacy',
        name: Routes.privacy,
        builder: (context, state) => const PrivacyPolicyScreen(),
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
            routes: [
              GoRoute(
                path: 'tutorial',
                name: Routes.educationTutorial,
                builder: (context, state) => const EducationTutorialScreen(),
              ),
              GoRoute(
                path: 'resources',
                name: Routes.educationResources,
                builder: (context, state) =>
                    const FindEducationResourcesScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'healthcare',
            name: Routes.healthcare,
            builder: (context, state) => const HealthcareScreen(),
            routes: [
              GoRoute(
                path: 'tutorial',
                name: Routes.healthcareTutorial,
                builder: (context, state) => const HealthcareTutorialScreen(),
              ),
              GoRoute(
                path: 'clinics',
                name: Routes.healthcareClinics,
                builder: (context, state) => const FindClinicsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'support-groups',
            name: Routes.supportGroups,
            builder: (context, state) => const SupportGroupsScreen(),
            routes: [
              GoRoute(
                path: 'suggest',
                name: Routes.suggestGroup,
                builder: (context, state) => const SuggestGroupScreen(),
              ),
              GoRoute(
                path: 'admin',
                name: Routes.groupAdmin,
                builder: (context, state) => const GroupAdminScreen(),
              ),
              GoRoute(
                path: ':groupId',
                name: Routes.supportGroupDetail,
                builder: (context, state) => GroupChatScreen(
                  groupId: state.pathParameters['groupId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: Routes.supportGroupCompose,
                    builder: (context, state) => GroupComposeScreen(
                      groupId: state.pathParameters['groupId']!,
                      initialKind: GroupPostKindX.parse(
                        state.uri.queryParameters['kind'],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'posts/:postId',
                    name: Routes.supportGroupPost,
                    builder: (context, state) => GroupPostScreen(
                      groupId: state.pathParameters['groupId']!,
                      postId: state.pathParameters['postId']!,
                    ),
                  ),
                ],
              ),
            ],
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
