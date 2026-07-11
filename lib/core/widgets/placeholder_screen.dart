import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';
import 'brand_scaffold.dart';

/// Reusable placeholder for screens that are scaffolded but not yet built.
///
/// Remove usages as each feature is implemented.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.icon = Icons.construction_outlined,
    this.description,
  });

  final String title;
  final IconData icon;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return BrandScaffold(
      title: title,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: kBrandGreen),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description ?? 'Coming soon',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
