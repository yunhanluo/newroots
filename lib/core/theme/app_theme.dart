import 'package:flutter/material.dart';

import 'brand_colors.dart';

/// Central theme. Accessibility-first: high contrast, large tap targets,
/// readable type scale (see DESIGN_PLAN.md §10).
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: kBrandGreen,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme.copyWith(primary: kBrandGreen),
      scaffoldBackgroundColor: kBrandPageBg,
      appBarTheme: kBrandAppBarTheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          backgroundColor: kBrandGreen,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kBrandGreen,
          side: BorderSide(color: kBrandGreen.withValues(alpha: 0.35)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    // Keep dark theme available but align primary brand color.
    final scheme = ColorScheme.fromSeed(
      seedColor: kBrandGreen,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
    );
  }
}
