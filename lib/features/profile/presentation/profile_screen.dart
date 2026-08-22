import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/brand_colors.dart';

/// User profile + settings (language, family, location). Feeds the roadmap.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(userProfileProvider).value;
    final hasSurvey = profile?.hasSurveyData ?? false;
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      backgroundColor: kBrandPageBg,
      appBar: AppBar(
        backgroundColor: kBrandGreen,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Profile'),
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
                      user?.email ?? 'Signed in',
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
                        child: const Text('Review group suggestions'),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (hasSurvey) ...[
                      _ProfileFieldRow(
                        label: 'Language',
                        value: _fieldValue(
                          profile!,
                          step: 1,
                          value: _languageLabel(profile.languageCode),
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
                        label: 'Location',
                        value: _fieldValue(
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
                          title: 'Location',
                          initialValue: profile.location,
                        ),
                      ),
                      _ProfileFieldRow(
                        label: 'Family size',
                        value: _fieldValue(
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
                          title: 'Family size',
                          initialValue: profile.skippedQuestions.contains(3)
                              ? ''
                              : '${profile.familySize}',
                          numeric: true,
                        ),
                      ),
                      _ProfileFieldRow(
                        label: 'Top priorities',
                        value: _fieldValue(
                          profile,
                          step: 4,
                          value: formatSurveyPriorities(profile.topPriorities),
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
                        label: 'Employment background',
                        value: _fieldValue(
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
                          title: 'Employment background',
                          initialValue: profile.employmentBackground,
                        ),
                      ),
                      _ProfileFieldRow(
                        label: 'Children ages',
                        value: _fieldValue(
                          profile,
                          step: 6,
                          value: profile.childrenInfo,
                        ),
                        skipped: _isSkippedField(
                          profile,
                          6,
                          empty: profile.childrenInfo.isEmpty,
                        ),
                        onEdit: () => _editTextField(
                          context,
                          ref,
                          key: 'childrenInfo',
                          title: 'Children ages',
                          initialValue: profile.childrenInfo,
                        ),
                      ),
                    ] else
                      Text(
                        'No survey data yet.',
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
                      child: Text(hasSurvey ? 'Retake Survey' : 'Take Survey'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => ref.read(authServiceProvider).signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
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
    UserProfileData profile, {
    required int step,
    required String value,
  }) {
    if (value.isEmpty && profile.skippedQuestions.contains(step)) {
      return 'Skipped';
    }
    if (value.isEmpty) return '-';
    return value;
  }

  static String _languageLabel(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'zh':
        return 'Chinese';
      case 'vi':
        return 'Vietnamese';
      case 'ko':
        return 'Korean';
      case 'hi':
        return 'Hindi';
      case 'ar':
        return 'Arabic';
      default:
        return code;
    }
  }

  static const _languageOptions = [
    ('en', 'English'),
    ('es', 'Spanish'),
    ('zh', 'Chinese'),
    ('vi', 'Vietnamese'),
    ('ko', 'Korean'),
    ('hi', 'Hindi'),
    ('ar', 'Arabic'),
  ];

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
    final knownCodes = _languageOptions.map((e) => e.$1).toSet();
    var selected = knownCodes.contains(initialCode) ? initialCode : 'en';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Theme(
        data: _editDialogTheme,
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Edit Preferred language'),
            content: DropdownButtonFormField<String>(
              value: selected,
              dropdownColor: Colors.white,
              decoration: const InputDecoration(labelText: 'Preferred language'),
              items: [
                for (final (code, label) in _languageOptions)
                  DropdownMenuItem(value: code, child: Text(label)),
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
  }

  static Future<void> _editPriorities(
    BuildContext context,
    WidgetRef ref, {
    required List<String> initialPriorities,
  }) async {
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
            title: const Text('Edit Top priorities'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (value, label) in surveyPriorityOptions)
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
                      title: Text(label),
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
                    title: const Text('Other'),
                    activeColor: kBrandGreen,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  if (otherSelected) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: otherController,
                      decoration: const InputDecoration(
                        labelText: 'Describe your priority',
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
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: onSave,
        style: FilledButton.styleFrom(
          backgroundColor: kBrandGreen,
          foregroundColor: Colors.white,
        ),
        child: const Text('Save'),
      ),
    ];
  }

  static Future<void> _editTextField(
    BuildContext context,
    WidgetRef ref, {
    required String key,
    required String title,
    required String initialValue,
    bool numeric = false,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Theme(
        data: _editDialogTheme,
        child: AlertDialog(
          title: Text('Edit $title'),
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
          tooltip: 'Edit $label',
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
      child: const Text(
        'Admin',
        style: TextStyle(
          color: kBrandGreen,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}
