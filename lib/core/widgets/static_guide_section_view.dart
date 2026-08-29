import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/static_guide.dart';
import '../theme/brand_colors.dart';

/// Renders one guide section: title, intro/body, and topic cards with
/// optional phone and URL actions.
class StaticGuideSectionView extends StatelessWidget {
  const StaticGuideSectionView({
    super.key,
    required this.section,
    this.welcomeCentered = true,
  });

  final StaticGuideSection section;
  final bool welcomeCentered;

  @override
  Widget build(BuildContext context) {
    if (section.topics.isEmpty && welcomeCentered) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              section.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  child: _IntroBody(section: section),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          if (section.intro.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              section.intro,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black,
              ),
            ),
          ],
          if (section.body.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              section.body,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black,
              ),
            ),
          ],
          for (final topic in section.topics) ...[
            const SizedBox(height: 24),
            Text(
              topic.heading,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              topic.paragraph,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black,
              ),
            ),
            if (topic.phone != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: () => _callPhone(topic.phone!),
                  style: FilledButton.styleFrom(
                    backgroundColor: kBrandGreen,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.call, size: 18),
                  label: Text(topic.phoneLabel ?? 'Call ${topic.phone}'),
                ),
              ),
            ],
            if (topic.url != null) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => _openUrl(topic.url!),
                  style: TextButton.styleFrom(
                    foregroundColor: kBrandGreen,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    topic.url!,
                    style: const TextStyle(
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _IntroBody extends StatelessWidget {
  const _IntroBody({required this.section});

  final StaticGuideSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (section.intro.isNotEmpty)
          Text(
            section.intro,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black,
            ),
          ),
        if (section.body.isNotEmpty) ...[
          if (section.intro.isNotEmpty) const SizedBox(height: 16),
          Text(
            section.body,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black,
            ),
          ),
        ],
      ],
    );
  }
}

Future<void> _openUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> _callPhone(String phone) async {
  final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.isEmpty) return;
  final uri = Uri(scheme: 'tel', path: digits);
  await launchUrl(uri);
}
