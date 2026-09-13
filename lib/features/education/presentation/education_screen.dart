import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_scaffold.dart';
import '../../../l10n/app_localizations.dart';

/// Feature 5: Education Navigator hub.
class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BrandScaffold(
      title: l10n.educationNavigatorTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          Text(
            l10n.educationHubIntro,
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Colors.black87.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 20),
          _HubCard(
            icon: Icons.menu_book_outlined,
            title: l10n.educationBasicsTitle,
            subtitle: l10n.educationBasicsSubtitle,
            onTap: () => context.goNamed(Routes.educationTutorial),
          ),
          const SizedBox(height: 12),
          _HubCard(
            icon: Icons.school_outlined,
            title: l10n.educationFindTitle,
            subtitle: l10n.educationFindSubtitle,
            onTap: () => context.goNamed(Routes.educationResources),
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
