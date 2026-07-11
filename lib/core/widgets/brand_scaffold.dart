import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';

/// Standard app shell matching home and profile styling.
class BrandScaffold extends StatelessWidget {
  const BrandScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBrandPageBg,
      appBar: AppBar(
        backgroundColor: kBrandGreen,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(title),
        actions: actions,
      ),
      body: body,
    );
  }
}
