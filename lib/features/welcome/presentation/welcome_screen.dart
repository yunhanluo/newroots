import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../l10n/app_localizations.dart';

/// True only for the session right after account creation.
class JustSignedUp extends Notifier<bool> {
  @override
  bool build() => false;

  void mark() => state = true;

  void clear() => state = false;
}

final justSignedUpProvider = NotifierProvider<JustSignedUp, bool>(
  JustSignedUp.new,
);

/// How-to card shown after sign-up (and from Profile → Help).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key, this.openGuide = false});

  /// From Profile → Help: Done returns to Profile instead of onboarding.
  final bool openGuide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: openGuide,
      child: Scaffold(
        backgroundColor: kBrandGreen,
        body: Column(
          children: [
            Expanded(
              child: _WelcomeGuideCard(
                purpose: l10n.welcomePurpose,
                features: _welcomeFeatures(l10n),
                buttonLabel: openGuide
                    ? l10n.welcomeDone
                    : l10n.welcomeGetStarted,
                onContinue: () {
                  if (openGuide) {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed(Routes.profile);
                    }
                    return;
                  }
                  ref.read(justSignedUpProvider.notifier).clear();
                  context.goNamed(Routes.onboarding);
                },
              ),
            ),
            const SafeArea(top: false, child: SizedBox(height: 8)),
          ],
        ),
      ),
    );
  }
}

List<_WelcomeFeature> _welcomeFeatures(AppLocalizations l10n) => [
  _WelcomeFeature(
    Icons.map_outlined,
    l10n.featureRoadmap,
    l10n.welcomeFeatureRoadmap,
  ),
  _WelcomeFeature(
    Icons.work_outline,
    l10n.featureCareer,
    l10n.welcomeFeatureCareer,
  ),
  _WelcomeFeature(
    Icons.home_outlined,
    l10n.featureHousing,
    l10n.welcomeFeatureHousing,
  ),
  _WelcomeFeature(
    Icons.local_hospital_outlined,
    l10n.featureHealthcare,
    l10n.welcomeFeatureHealthcare,
  ),
  _WelcomeFeature(
    Icons.emergency_outlined,
    l10n.featureSafety,
    l10n.welcomeFeatureSafety,
  ),
  _WelcomeFeature(
    Icons.shield_outlined,
    l10n.featureScamShield,
    l10n.welcomeFeatureScamShield,
  ),
  _WelcomeFeature(
    Icons.translate_outlined,
    l10n.featureEnglish,
    l10n.welcomeFeatureEnglish,
  ),
  _WelcomeFeature(
    Icons.school_outlined,
    l10n.featureEducation,
    l10n.welcomeFeatureEducation,
  ),
  _WelcomeFeature(
    Icons.diversity_3_outlined,
    l10n.featureSupportGroups,
    l10n.welcomeFeatureSupportGroups,
  ),
];

class _WelcomeGuideCard extends StatelessWidget {
  const _WelcomeGuideCard({
    required this.purpose,
    required this.features,
    required this.buttonLabel,
    required this.onContinue,
  });

  final String purpose;
  final List<_WelcomeFeature> features;
  final String buttonLabel;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: kBrandGreen,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: kBrandGreen, width: 3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          purpose,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 8),
                            itemCount: features.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final feature = features[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    feature.icon,
                                    size: 26,
                                    color: kBrandGreen,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          feature.title,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          feature.description,
                                          style: TextStyle(
                                            fontSize: 14,
                                            height: 1.35,
                                            color: Colors.black87.withValues(
                                              alpha: 0.72,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: onContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kBrandGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeFeature {
  const _WelcomeFeature(this.icon, this.title, this.description);

  final IconData icon;
  final String title;
  final String description;
}
