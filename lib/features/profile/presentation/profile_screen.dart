import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_screen.dart';

/// User profile + settings (language, family, location). Feeds the roadmap.
/// PLACEHOLDER.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Profile',
      icon: Icons.person_outline,
      description: 'Language, family, location, and employment background.',
    );
  }
}
