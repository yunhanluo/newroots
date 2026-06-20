import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_screen.dart';

/// Feature 3: Career Bridge (AI maps prior experience to US pathways).
/// PLACEHOLDER — will call AiService.mapCareer.
class CareerScreen extends StatelessWidget {
  const CareerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Career Bridge',
      icon: Icons.work_outline,
      description: 'Translate prior experience into U.S. career pathways.',
    );
  }
}
