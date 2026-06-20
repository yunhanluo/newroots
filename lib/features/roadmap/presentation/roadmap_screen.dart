import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_screen.dart';

/// Feature 1: Personalized Integration Roadmap (AI-generated).
/// PLACEHOLDER — will call AiService.generateRoadmap.
class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Integration Roadmap',
      icon: Icons.map_outlined,
      description: 'A personalized settlement plan: First Month, First 3 Months, First Year.',
    );
  }
}
