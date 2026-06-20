import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_screen.dart';

/// Feature 9: ScamShield — AI-powered fraud prevention (flagship).
/// PLACEHOLDER — will upload to Cloud Storage + call AiService.analyzeScam.
class ScamShieldScreen extends StatelessWidget {
  const ScamShieldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'ScamShield',
      icon: Icons.shield_outlined,
      description: 'Check suspicious messages, emails, job offers, and rentals for fraud risk.',
    );
  }
}
