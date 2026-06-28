import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../auth/presentation/widgets/auth_widgets.dart';

/// Home dashboard: entry point to all navigators (see DESIGN_PLAN.md §4).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _cardBg = Colors.white;
  static const _pageBg = Color(0xFFF4F8F6);

  static const _features = <_FeatureEntry>[
    _FeatureEntry('Integration Roadmap', Icons.map_outlined, Routes.roadmap),
    _FeatureEntry('Housing', Icons.home_outlined, Routes.housing),
    _FeatureEntry('Career Bridge', Icons.work_outline, Routes.career),
    _FeatureEntry('English Learning', Icons.translate_outlined, Routes.english),
    _FeatureEntry('Education', Icons.school_outlined, Routes.education),
    _FeatureEntry('Healthcare', Icons.local_hospital_outlined, Routes.healthcare),
    _FeatureEntry('Community', Icons.groups_outlined, Routes.community),
    _FeatureEntry('Support Groups', Icons.diversity_3_outlined, Routes.supportGroups),
    _FeatureEntry('ScamShield', Icons.shield_outlined, Routes.scamShield),
    _FeatureEntry('Safety Guide', Icons.emergency_outlined, Routes.safety),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B6B5A),
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
      body: GridView.count(
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
    );
  }
}

class _FeatureEntry {
  const _FeatureEntry(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}
