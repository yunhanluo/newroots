import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_scaffold.dart';

/// Feature 6: Healthcare Navigator hub.
class HealthcareScreen extends StatelessWidget {
  const HealthcareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BrandScaffold(
      title: 'Healthcare Navigator',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          Text(
            'Learn how care works in California, then find trusted community '
            'health centers near you.',
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Colors.black87.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 20),
          _HubCard(
            icon: Icons.menu_book_outlined,
            title: 'Healthcare basics',
            subtitle:
                'Insurance, how visits work, community health centers, and language help.',
            onTap: () => context.goNamed(Routes.healthcareTutorial),
          ),
          const SizedBox(height: 12),
          _HubCard(
            icon: Icons.local_hospital_outlined,
            title: 'Find a clinic',
            subtitle:
                'Map and list of nearby HRSA community health centers by city or ZIP.',
            onTap: () => context.goNamed(Routes.healthcareClinics),
          ),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

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
        onTap: onTap,
        splashColor: kBrandGreen.withValues(alpha: 0.08),
        highlightColor: kBrandGreen.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: kBrandGreen),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.black87.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: kBrandGreen.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
