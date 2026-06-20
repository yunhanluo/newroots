import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';

/// Home dashboard: entry point to all navigators (see DESIGN_PLAN.md §4).
/// PLACEHOLDER: static grid of feature cards.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      appBar: AppBar(
        title: const Text('NewRoots'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
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
            Card(
              child: InkWell(
                onTap: () => context.goNamed(f.route),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(f.icon, size: 40),
                      const SizedBox(height: 12),
                      Text(f.label, textAlign: TextAlign.center),
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
