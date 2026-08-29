import 'package:flutter/material.dart';

import '../../../core/models/static_guide.dart';
import '../../../core/widgets/static_guide_pager.dart';

/// Healthcare basics tutorial (no AI ask bar).
class HealthcareTutorialScreen extends StatelessWidget {
  const HealthcareTutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticGuidePager(
      guideId: StaticGuideIds.healthcare,
      landingStyle: GuideLandingStyle.compact,
    );
  }
}
