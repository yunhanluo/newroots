import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/brand_colors.dart';

/// Short intro to NewRoots — kept minimal for now.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: kBrandPageBg,
      appBar: AppBar(
        backgroundColor: kBrandGreen,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('About'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 60),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 640;

                      final textColumn = Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'America brims with opportunities. \n\n'
                              'It is an economic powerhouse. It boasts a constitution so strong and effective that it has set the standard for dozens of other countries. It is a land of many unique cultures. \n\n'
                              'But it\'s hard to find your footing in a new country - especially in America.\n\n'
                              'NewRoots is here to solve these problems. We\'ll help you find your place. \n'
                              'We\'ll help you make new connections. We\'ll help you steer clear of traps.'
                              ' We\'ll help you take advantage of resources near you.\n'
                              'Let us show you what America is all about. \n \n'
                              'Find your new roots.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 24),
                            Text(
                              'NewRoots is not a substitute '
                              'for legal, medical, or financial professionals.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      );

                      final imageColumn = Image.asset(
                        'assets/images/golden_gate.png',
                        fit: BoxFit.cover,
                        height: wide ? null : 220,
                        width: double.infinity,
                      );

                      if (wide) {
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(flex: 3, child: textColumn),
                              Expanded(flex: 2, child: imageColumn),
                            ],
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [textColumn, imageColumn],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
