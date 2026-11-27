import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../router/app_router.dart';
import '../theme/brand_colors.dart';

/// Friendly page shown when a route doesn't exist.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: kBrandPageBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.explore_off_outlined,
                    size: 64,
                    color: kBrandGreen,
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.notFoundTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.notFoundBody,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.goNamed(Routes.home),
                    style: FilledButton.styleFrom(backgroundColor: kBrandGreen),
                    icon: const Icon(Icons.home_outlined),
                    label: Text(l10n.notFoundGoHome),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
