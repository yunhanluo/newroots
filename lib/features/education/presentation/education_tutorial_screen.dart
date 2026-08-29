import 'package:flutter/material.dart';

import '../../../core/models/static_guide.dart';
import '../../../core/widgets/static_guide_pager.dart';

/// Education basics tutorial (no AI ask bar).
class EducationTutorialScreen extends StatelessWidget {
  const EducationTutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticGuidePager(
      guideId: StaticGuideIds.education,
      landingStyle: GuideLandingStyle.compact,
    );
  }
}
