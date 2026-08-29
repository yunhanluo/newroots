import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../l10n/app_languages.dart';
import '../l10n/app_locale.dart';

/// Compact language menu for auth and other public screens.
class LanguageMenuButton extends ConsumerWidget {
  const LanguageMenuButton({super.key, this.iconColor = Colors.white});

  final Color iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(appLocaleProvider).languageCode;

    return PopupMenuButton<String>(
      tooltip: l10n.selectLanguage,
      icon: Icon(Icons.language, color: iconColor),
      onSelected: (code) {
        ref.read(localeOverrideProvider.notifier).setCode(code);
      },
      itemBuilder: (context) => [
        for (final language in kAppLanguages)
          PopupMenuItem<String>(
            value: language.code,
            child: Row(
              children: [
                Expanded(child: Text(language.nativeName)),
                if (language.code == current)
                  Icon(
                    Icons.check,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
