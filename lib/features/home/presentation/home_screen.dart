import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/support_group_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../support_groups/presentation/widgets/deleted_group_notice.dart';
import '../../support_groups/presentation/widgets/deleted_post_notice.dart';
import '../../support_groups/presentation/widgets/suggestion_review_notice.dart';

/// Home dashboard: entry point to all navigators (see DESIGN_PLAN.md §4).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static List<_FeatureEntry> _features(AppLocalizations l10n) => [
    _FeatureEntry(
      l10n.featureRoadmap,
      l10n.welcomeFeatureRoadmap,
      Icons.map_outlined,
      Routes.roadmap,
    ),
    _FeatureEntry(
      l10n.featureCareer,
      l10n.welcomeFeatureCareer,
      Icons.work_outline,
      Routes.career,
    ),
    _FeatureEntry(
      l10n.featureHousing,
      l10n.welcomeFeatureHousing,
      Icons.home_outlined,
      Routes.housing,
    ),
    _FeatureEntry(
      l10n.featureHealthcare,
      l10n.welcomeFeatureHealthcare,
      Icons.local_hospital_outlined,
      Routes.healthcare,
    ),
    _FeatureEntry(
      l10n.featureSafety,
      l10n.welcomeFeatureSafety,
      Icons.emergency_outlined,
      Routes.safety,
    ),
    _FeatureEntry(
      l10n.featureScamShield,
      l10n.welcomeFeatureScamShield,
      Icons.shield_outlined,
      Routes.scamShield,
    ),
    _FeatureEntry(
      l10n.featureEnglish,
      l10n.welcomeFeatureEnglish,
      Icons.translate_outlined,
      Routes.english,
    ),
    _FeatureEntry(
      l10n.featureEducation,
      l10n.welcomeFeatureEducation,
      Icons.school_outlined,
      Routes.education,
    ),
    _FeatureEntry(
      l10n.featureSupportGroups,
      l10n.welcomeFeatureSupportGroups,
      Icons.diversity_3_outlined,
      Routes.supportGroups,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reviews = ref.watch(unseenSuggestionReviewsProvider);
    final deletedNotices = ref.watch(deletedGroupNoticesProvider);
    final deletedPosts =
        ref.watch(unseenPostDeletionNoticesProvider).value ?? const [];
    final profileAsync = ref.watch(userProfileProvider);
    final showFinishProfile =
        profileAsync.hasValue && !(profileAsync.value?.hasSurveyData ?? false);

    return Scaffold(
      backgroundColor: kBrandPageBg,
      appBar: AppBar(
        backgroundColor: kBrandGreen,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Image.asset(
          'assets/images/logo_white.png',
          height: 28,
          fit: BoxFit.contain,
          semanticLabel: 'NewRoots',
        ),
        actions: [
          IconButton(
            tooltip: l10n.homeProfileTooltip,
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => context.goNamed(Routes.profile),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 720 ? 3 : 2;
          final features = _features(l10n);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.homeGreeting,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.homeGreetingSubtitle,
                style: const TextStyle(color: Colors.black54, fontSize: 15),
              ),
              const SizedBox(height: 16),
              for (final suggestion in reviews) ...[
                SuggestionReviewNotice(suggestion: suggestion),
                const SizedBox(height: 8),
              ],
              for (final group in deletedNotices) ...[
                DeletedGroupNotice(group: group),
                const SizedBox(height: 8),
              ],
              for (final notice in deletedPosts) ...[
                DeletedPostNotice(notice: notice),
                const SizedBox(height: 8),
              ],
              if (showFinishProfile) ...[
                const _FinishProfileCard(),
                const SizedBox(height: 16),
              ],
              for (var i = 0; i < features.length; i += columns) ...[
                if (i > 0) const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var j = i; j < i + columns; j++) ...[
                        if (j > i) const SizedBox(width: 12),
                        Expanded(
                          child: j < features.length
                              ? _FeatureCard(entry: features[j])
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _FinishProfileCard extends StatelessWidget {
  const _FinishProfileCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: kBrandGreen.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kBrandGreen.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_add_alt_1_outlined, color: kBrandGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.homeFinishProfileTitle,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.homeFinishProfileBody,
              style: const TextStyle(color: Colors.black54, height: 1.35),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton(
                onPressed: () => context.pushNamed(Routes.onboarding),
                style: FilledButton.styleFrom(
                  backgroundColor: kBrandGreen,
                  minimumSize: const Size(0, 44),
                ),
                child: Text(l10n.actionStartSurvey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.entry});

  final _FeatureEntry entry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kBrandGreen.withValues(alpha: 0.18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.goNamed(entry.route),
        splashColor: kBrandGreen.withValues(alpha: 0.08),
        highlightColor: kBrandGreen.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Column(
            children: [
              Icon(entry.icon, size: 34, color: kBrandGreen),
              const SizedBox(height: 10),
              Text(
                entry.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureEntry {
  const _FeatureEntry(this.label, this.description, this.icon, this.route);
  final String label;
  final String description;
  final IconData icon;
  final String route;
}
