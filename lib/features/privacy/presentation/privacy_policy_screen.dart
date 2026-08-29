import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_locale.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../data/privacy_policy_copy.dart';

/// Simple privacy policy in the seven supported languages.
class PrivacyPolicyScreen extends ConsumerStatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  ConsumerState<PrivacyPolicyScreen> createState() =>
      _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends ConsumerState<PrivacyPolicyScreen> {
  String? _overrideCode;

  PrivacyPolicyCopy _copyFor(String code) {
    return kPrivacyPolicyCopies.firstWhere(
      (copy) => copy.code == code,
      orElse: () => kPrivacyPolicyCopies.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileCode =
        ref.watch(userProfileProvider).value?.languageCode.trim() ?? '';
    final appCode = ref.watch(appLocaleProvider).languageCode;
    final fallback = kPrivacyPolicyCopies.any((c) => c.code == profileCode)
        ? profileCode
        : appCode;
    final selected = _overrideCode ?? fallback;
    final copy = _copyFor(selected);
    final rtl = selected == 'ar';

    return Scaffold(
      backgroundColor: kBrandPageBg,
      appBar: AppBar(
        title: Text(copy.title),
      ),
      body: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in kPrivacyPolicyCopies)
                  ChoiceChip(
                    label: Text(item.nativeName),
                    selected: item.code == selected,
                    onSelected: (_) => setState(() => _overrideCode = item.code),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              copy.updated,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              copy.intro,
              style: const TextStyle(
                fontSize: 16,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 8),
            for (final section in copy.sections) ...[
              const SizedBox(height: 20),
              Text(
                section.heading,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                section.body,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
