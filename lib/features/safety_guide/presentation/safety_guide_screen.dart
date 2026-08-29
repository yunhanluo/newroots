import 'package:flutter/material.dart';

import '../../../core/models/static_guide.dart';
import '../../../core/widgets/static_guide_pager.dart';

/// Feature 10: Community Safety Guide.
class SafetyGuideScreen extends StatelessWidget {
  const SafetyGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticGuidePager(
      guideId: StaticGuideIds.safety,
      landingStyle: GuideLandingStyle.hero,
    );
  }
}
