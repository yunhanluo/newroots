import 'package:flutter/material.dart';

/// Central theme. Accessibility-first: high contrast, large tap targets,
/// readable type scale (see DESIGN_PLAN.md §10).
class AppTheme {
  AppTheme._();

  // TODO: replace with finalized brand palette.
  static const Color _seed = Color(0xFF1B6B5A); // calm, trustworthy green

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: _seed);
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Large minimum tap target for accessibility.
      materialTapTargetSize: MaterialTapTargetSize.padded,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
    );
  }
}
