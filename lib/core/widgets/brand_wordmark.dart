import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';

/// Text-based "NewRoots" wordmark used in place of a logo image.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    this.color = kBrandGreen,
    this.fontSize = 28,
  });

  /// White variant for use on green backgrounds (e.g. app bars).
  const BrandWordmark.white({super.key, this.fontSize = 22})
    : color = Colors.white;

  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      'NewRoots',
      maxLines: 1,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        height: 1.1,
      ),
    );
  }
}
