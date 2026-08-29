import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_languages.dart';
import '../../../core/l10n/app_locale.dart';
import '../../../core/l10n/l10n_labels.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/children_ages_editor.dart';
import '../../../l10n/app_localizations.dart';

/// User profile + settings (language, family, location). Feeds the roadmap.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(userProfileProvider).value;
    final hasSurvey = profile?.hasSurveyData ?? false;
    final isAdmin = ref.watch(isAdminProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: kBrandPageBg,
      appBar: AppBar(
        backgroundColor: kBrandGreen,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(l10n.profileTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        height: 72,
                        width: 72,
                        decoration: const BoxDecoration(
                          color: kBrandGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.email ?? l10n.profileSignedIn,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 10),
                      const Center(child: _AdminBadge()),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            context.pushNamed(Routes.groupAdmin),
                        child: Text(l10n.profileReviewSuggestions),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (hasSurvey) ...[
                      _ProfileFieldRow(
                        label: l10n.language,
                        value: _fieldValue(
                          l10n,
                          profile!,
                          step: 1,
                          value: appLanguageNativeName(profile.languageCode),
                        ),
                        skipped: _isSkippedField(
                          profile,
                          1,
                          empty: profile.languageCode.isEmpty,
                        ),
                        onEdit: () => _editLanguage(
                          context,
                          ref,
                          initialCode: profile.languageCode,
                        ),
                      ),
                      _ProfileFieldRow(
                        label: l10n.profileLocation,
                        value: _fieldValue(
                          l10n,
                          profile,
                          step: 2,
                          value: profile.location,
                        ),
                        skipped: _isSkippedField(
                          profile,
                          2,
                          empty: profile.location.isEmpty,
                        ),
                        onEdit: () => _editTextField(
                          context,
                          ref,
                          key: 'location',
                          title: l10n.profileLocation,
                          initialValue: profile.location,
                        ),
                      ),
                      _ProfileFieldRow(
                        label: l10n.profileChildrenCount,
                        value: _fieldValue(
                          l10n,
                          profile,
                          step: 3,
                          value: profile.skippedQuestions.contains(3)
                              ? ''
                              : '${profile.familySize}',
                        ),
                        skipped: _isSkippedField(
                          profile,
                          3,
                          empty: profile.skippedQuestions.contains(3),
                        ),
                        onEdit: () => _editTextField(
                          context,
                          ref,
                          key: 'familySize',
                          title: l10n.profileChildrenCount,
                          initialValue: profile.skippedQuestions.contains(3)
                              ? ''
                              : '${profile.familySize}',
                          numeric: true,
                        ),
                      ),
                      _ProfileFieldRow(
                        label: l10n.profilePriorities,
                        value: _fieldValue(
                          l10n,
                          profile,
                          step: 4,
                          value: formatLocalizedPriorities(
                            l10n,
                            profile.topPriorities,
                          ),
                        ),
                        skipped: _isSkippedField(
                          profile,
                          4,
                          empty: profile.topPriorities.isEmpty,
                        ),
                        onEdit: () => _editPriorities(
                          context,
                          ref,
                          initialPriorities: profile.topPriorities,
                        ),
                      ),
                      _ProfileFieldRow(
                        label: l10n.profileEmployment,
                        value: _fieldValue(
                          l10n,
                          profile,
                          step: 5,
                          value: profile.employmentBackground,
                        ),
                        skipped: _isSkippedField(
                          profile,
                          5,
                          empty: profile.employmentBackground.isEmpty,
                        ),
                        onEdit: () => _editTextField(
                          context,
                          ref,
                          key: 'employmentBackground',
                          title: l10n.profileEmployment,
                          initialValue: profile.employmentBackground,
                        ),
                      ),
                      _ProfileFieldRow(
                        label: l10n.profileChildrenAges,
                        value: _fieldValue(
                          l10n,
                          profile,
                          step: 6,
                          value: profile.childrenInfo,
                        ),
                        skipped: _isSkippedField(
                          profile,
                          6,
                          empty: profile.childrenInfo.isEmpty,
                        ),
                        onEdit: () => _editChildrenAges(
                          context,
                          ref,
                          familySize: profile.skippedQuestions.contains(3)
                              ? 0
                              : profile.familySize,
                          initialValue: profile.childrenInfo,
                        ),
                      ),
                    ] else
                      Text(
                        l10n.profileNoSurvey,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black87.withValues(alpha: 0.6),
                          fontSize: 15,
                        ),
                      ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () => context.pushNamed(Routes.onboarding),
                      style: _outlinedButtonStyle,
                      child: Text(
                        hasSurvey
                            ? l10n.actionRetakeSurvey
                            : l10n.actionTakeSurvey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.pushNamed(Routes.privacy),
                      child: Text(l10n.authPrivacyPolicy),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => ref.read(authServiceProvider).signOut(),
              icon: const Icon(Icons.logout),
              label: Text(l10n.actionSignOut),
              style: _outlinedButtonStyle,
            ),
          ],
        ),
      ),
    );
  }

  static ButtonStyle get _outlinedButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: kBrandGreen,
        side: BorderSide(color: kBrandGreen.withValues(alpha: 0.35)),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  static bool _isSkippedField(
    UserProfileData profile,
    int step, {
    required bool empty,
  }) {
    return empty && profile.skippedQuestions.contains(step);
  }

  static String _fieldValue(
    AppLocalizations l10n,
    UserProfileData profile, {
    required int step,
    required String value,
  }) {
    if (value.isEmpty && profile.skippedQuestions.contains(step)) {
      return l10n.profileSkipped;
    }
    if (value.isEmpty) return '-';
    return value;
  }

  static ThemeData get _editDialogTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: kBrandGreen),
      );

  static Future<void> _editLanguage(
    BuildContext context,
    WidgetRef ref, {
    required String initialCode,
  }) async {
    final l10n = AppLocalizations.of(context);
    final knownCodes = {for (final language in kAppLanguages) language.code};
    var selected = knownCodes.contains(initialCode) ? initialCode : 'en';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Theme(
        data: _editDialogTheme,
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(l10n.editPreferredLanguage),
            content: DropdownButtonFormField<String>(
              value: selected,
              dropdownColor: Colors.white,
              decoration: InputDecoration(labelText: l10n.preferredLanguage),
              items: [
                for (final language in kAppLanguages)
                  DropdownMenuItem(
                    value: language.code,
                    child: Text(language.nativeName),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setDialogState(() => selected = value);
              },
            ),
            actions: _editDialogActions(
              dialogContext,
              onSave: () => Navigator.of(dialogContext).pop(selected),
            ),
          ),
        ),
      ),
    );

    if (result == null) return;
    await ref.read(userProfileServiceProvider).updateField('languageCode', result);
    ref.read(localeOverrideProvider.notifier).setCode(result);
  }

  static Future<void> _editPriorities(
    BuildContext context,
    WidgetRef ref, {
    required List<String> initialPriorities,
  }) async {
    final l10n = AppLocalizations.of(context);
    final selected = <String>{
      for (final item in initialPriorities)
        if (surveyPriorityPresets.contains(item)) item,
    };
    var otherSelected = initialPriorities.any(
      (item) => item.startsWith('Other (') || item.startsWith('Other '),
    );
    final otherController = TextEditingController(
      text: _otherPriorityText(initialPriorities),
    );

    final result = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => Theme(
        data: _editDialogTheme,
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(l10n.actionEdit(l10n.profilePriorities)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (value, _) in surveyPriorityOptions)
                    CheckboxListTile(
                      value: selected.contains(value),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked ?? false) {
                            selected.add(value);
                          } else {
                            selected.remove(value);
                          }
                        });
                      },
                      title: Text(localizedPriorityLabel(l10n, value)),
                      activeColor: kBrandGreen,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  CheckboxListTile(
                    value: otherSelected,
                    onChanged: (checked) {
                      setDialogState(() {
                        otherSelected = checked ?? false;
                        if (!otherSelected) otherController.clear();
                      });
                    },
                    title: Text(l10n.priorityOther),
                    activeColor: kBrandGreen,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  if (otherSelected) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: otherController,
                      decoration: InputDecoration(
                        labelText: l10n.priorityOtherHint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: _editDialogActions(
              dialogContext,
              onSave: () {
                final priorities = <String>[
                  for (final (value, _) in surveyPriorityOptions)
                    if (selected.contains(value)) value,
                ];
                if (otherSelected) {
                  final custom = otherController.text.trim();
                  if (custom.isNotEmpty) {
                    priorities.add('Other ($custom)');
                  }
                }
                Navigator.of(dialogContext).pop(priorities);
              },
            ),
          ),
        ),
      ),
    );
    otherController.dispose();

    if (result == null) return;
    await ref
        .read(userProfileServiceProvider)
        .updateField('topPriorities', result);
  }

  static String _otherPriorityText(List<String> priorities) {
    for (final item in priorities) {
      if (item.startsWith('Other (') && item.endsWith(')')) {
        return item.substring(7, item.length - 1);
      }
      if (item.startsWith('Other ')) {
        return item.substring(6);
      }
    }
    return '';
  }

  static List<Widget> _editDialogActions(
    BuildContext context, {
    required VoidCallback onSave,
  }) {
    final l10n = AppLocalizations.of(context);
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(l10n.actionCancel),
      ),
      FilledButton(
        onPressed: onSave,
        style: FilledButton.styleFrom(
          backgroundColor: kBrandGreen,
          foregroundColor: Colors.white,
        ),
        child: Text(l10n.actionSave),
      ),
    ];
  }

  static Future<void> _editChildrenAges(
    BuildContext context,
    WidgetRef ref, {
    required int familySize,
    required String initialValue,
  }) async {
    final count = surveyChildCount(familySize);
    final draft = ChildrenAgesDraft()
      ..loadFrom(initialValue, count: count);
    String? error;
    final l10n = AppLocalizations.of(context);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Theme(
        data: _editDialogTheme,
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(l10n.actionEdit(l10n.profileChildrenAges)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ChildrenAgesEditor(
                    draft: draft,
                    emptyMessage: count == 0
                        ? 'Change how many children you have first, then add ages here.'
                        : 'No children’s ages to add.',
                    onChanged: () => setDialogState(() => error = null),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: _editDialogActions(
              dialogContext,
              onSave: () {
                final agesError = draft.validationError();
                if (agesError != null) {
                  setDialogState(() => error = agesError);
                  return;
                }
                Navigator.of(dialogContext).pop(draft.toStorage());
              },
            ),
          ),
        ),
      ),
    );
    draft.dispose();
    if (result == null) return;
    await ref.read(userProfileServiceProvider).updateField('childrenInfo', result);
  }

  static Future<void> _editTextField(
    BuildContext context,
    WidgetRef ref, {
    required String key,
    required String title,
    required String initialValue,
    bool numeric = false,
  }) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Theme(
        data: _editDialogTheme,
        child: AlertDialog(
          title: Text(l10n.actionEdit(title)),
          content: TextField(
            controller: controller,
            keyboardType: numeric ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(labelText: title),
            autofocus: true,
          ),
          actions: _editDialogActions(
            dialogContext,
            onSave: () => Navigator.of(dialogContext).pop(controller.text.trim()),
          ),
        ),
      ),
    );
    controller.dispose();

    if (result == null) return;
    if (numeric) {
      final value = int.tryParse(result);
      if (value != null) {
        await ref.read(userProfileServiceProvider).updateField(key, value);
      }
      return;
    }
    await ref.read(userProfileServiceProvider).updateField(key, result);
  }
}

class _ProfileFieldRow extends StatelessWidget {
  const _ProfileFieldRow({
    required this.label,
    required this.value,
    required this.onEdit,
    this.skipped = false,
  });

  final String label;
  final String value;
  final VoidCallback onEdit;
  final bool skipped;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: skipped
                  ? Colors.black54
                  : Colors.black87.withValues(alpha: 0.85),
              fontSize: 14,
              fontStyle: skipped ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          color: kBrandGreen,
          tooltip: AppLocalizations.of(context).actionEdit(label),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        ],
      ),
    );
  }
}

class _AdminBadge extends StatelessWidget {
  const _AdminBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: kBrandGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
        child: Text(
          AppLocalizations.of(context).profileAdmin,
        style: TextStyle(
          color: kBrandGreen,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}
