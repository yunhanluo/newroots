import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/support_group_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../../support_groups/presentation/widgets/deleted_group_notice.dart';
import '../../support_groups/presentation/widgets/suggestion_review_notice.dart';

/// Home dashboard: entry point to all navigators (see DESIGN_PLAN.md §4).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _cardBg = Colors.white;

  static const _features = <_FeatureEntry>[
    _FeatureEntry('Integration Roadmap', Icons.map_outlined, Routes.roadmap),
    _FeatureEntry('Career Bridge', Icons.work_outline, Routes.career),
    _FeatureEntry('Housing', Icons.home_outlined, Routes.housing),
    _FeatureEntry('Healthcare', Icons.local_hospital_outlined, Routes.healthcare),
    _FeatureEntry('Safety Guide', Icons.emergency_outlined, Routes.safety),
    _FeatureEntry('ScamShield', Icons.shield_outlined, Routes.scamShield),
    _FeatureEntry('English Learning', Icons.translate_outlined, Routes.english),
    _FeatureEntry('Education', Icons.school_outlined, Routes.education),
    _FeatureEntry('Support Groups', Icons.diversity_3_outlined, Routes.supportGroups),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(unseenSuggestionReviewsProvider);
    final deletedNotices = ref.watch(deletedGroupNoticesProvider);

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
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => context.goNamed(Routes.profile),
          ),
        ],
      ),
      body: Column(
        children: [
          if (reviews.isNotEmpty || deletedNotices.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  for (final suggestion in reviews) ...[
                    SuggestionReviewNotice(suggestion: suggestion),
                    const SizedBox(height: 8),
                  ],
                  for (final group in deletedNotices) ...[
                    DeletedGroupNotice(group: group),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                for (final f in _features)
                  Material(
                    color: _cardBg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: kBrandGreen.withValues(alpha: 0.18)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.goNamed(f.route),
                      splashColor: kBrandGreen.withValues(alpha: 0.08),
                      highlightColor: kBrandGreen.withValues(alpha: 0.04),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(f.icon, size: 36, color: kBrandGreen),
                            const SizedBox(height: 12),
                            Text(
                              f.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureEntry {
  const _FeatureEntry(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}
