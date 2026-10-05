import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/widgets/auth_widgets.dart';
import '../../../../core/l10n/app_languages.dart';
import '../../../../core/l10n/app_locale.dart';
import '../../../../core/l10n/l10n_labels.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/user_profile_service.dart';
import '../../../../core/widgets/children_ages_editor.dart';
import '../../../../l10n/app_localizations.dart';

/// Intro + survey flow shown right after account creation.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _locationController = TextEditingController();
  final _employmentController = TextEditingController();
  final _otherPriorityController = TextEditingController();
  final _childrenAges = ChildrenAgesDraft();

  String? _languageCode;
  int? _familySize;
  final Set<String> _selectedPriorities = {};
  bool _otherPrioritySelected = false;

  bool _saving = false;
  String? _error;
  int _step = 0; // 0 = intro, 1..6 = questions
  final Set<int> _skippedQuestions = {};

  static const _totalQuestions = 6;

  @override
  void initState() {
    super.initState();
    _prefillFromExistingProfile();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _employmentController.dispose();
    _otherPriorityController.dispose();
    _childrenAges.dispose();
    super.dispose();
  }

  Future<void> _showSkipSurveyDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).onboardingSkipTitle),
        content: Text(AppLocalizations.of(context).onboardingSkipBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).actionContinueSurvey),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(minimumSize: const Size(120, 44)),
            child: Text(AppLocalizations.of(context).actionSkipForNow),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final later = AppLocalizations.of(context).onboardingSurveyLater;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(later)),
      );
      context.go('/');
    }
  }

  Future<void> _prefillFromExistingProfile() async {
    final profile = await ref
        .read(userProfileServiceProvider)
        .getCurrentUserProfile();
    if (!mounted) return;
    final override = ref.read(localeOverrideProvider);
    final fallbackLanguage = isSupportedAppLanguage(override)
        ? override!.trim()
        : ref.read(appLocaleProvider).languageCode;
    if (profile == null) {
      setState(() => _languageCode = fallbackLanguage);
      return;
    }
    setState(() {
      _skippedQuestions
        ..clear()
        ..addAll(profile.skippedQuestions);
      _languageCode = _skippedQuestions.contains(1)
          ? null
          : (profile.languageCode.isEmpty
              ? fallbackLanguage
              : profile.languageCode);
      _locationController.text =
          _skippedQuestions.contains(2) ? '' : profile.location;
      _familySize =
          _skippedQuestions.contains(3) ? null : profile.familySize;
      _syncChildrenAgeFields(
        ages: _skippedQuestions.contains(6) ? '' : profile.childrenInfo,
      );
      if (_skippedQuestions.contains(4)) {
        _selectedPriorities.clear();
        _otherPrioritySelected = false;
        _otherPriorityController.clear();
      } else {
        _applySavedTopPriorities(profile.topPriorities);
      }
      _employmentController.text = _skippedQuestions.contains(5)
          ? ''
          : profile.employmentBackground;
    });
  }

  int get _childCountFromFamilySize => surveyChildCount(
        _skippedQuestions.contains(3) ? null : _familySize,
      );

  void _syncChildrenAgeFields({String? ages}) {
    if (ages != null) {
      _childrenAges.loadFrom(ages, count: _childCountFromFamilySize);
    } else {
      _childrenAges.setCount(_childCountFromFamilySize);
    }
  }

  void _nextQuestion() {
    if (_step >= _totalQuestions) return;
    setState(() {
      if (_step == 5) _syncChildrenAgeFields();
      _step += 1;
    });
  }

  void _previousQuestion() {
    if (_step <= 1) return;
    setState(() => _step -= 1);
  }

  void _skipCurrentQuestion({required bool isLast}) {
    if (_step > 0) {
      setState(() {
        _clearQuestionValue(_step);
        _skippedQuestions.add(_step);
      });
    }
    if (isLast) {
      _saveAndContinue();
    } else {
      _nextQuestion();
    }
  }

  Future<void> _saveAndContinue() async {
    if (_step == 6 && !_skippedQuestions.contains(6)) {
      final agesError = _childrenAges.validationError();
      if (agesError != null) {
        setState(() => _error = agesError);
        return;
      }
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      if (FirebaseAuth.instance.currentUser == null) {
        throw StateError('No signed-in user.');
      }

      await ref
          .read(userProfileServiceProvider)
          .saveOnboarding(
            languageCode: _languageCode ?? '',
            location: _locationController.text,
            familySize: _familySize ?? 0,
            topPriorities: _resolvedTopPriorities,
            employmentBackground: _employmentController.text,
            childrenInfo: _skippedQuestions.contains(6)
                ? ''
                : _childrenAges.toStorage(),
            skippedQuestions: _skippedQuestions.toList()..sort(),
          );
    } on FirebaseException catch (e) {
      debugPrint('Onboarding save failed: ${e.code} ${e.message}');
      if (mounted) {
        setState(() => _error = _saveErrorMessage(e));
      }
      return;
    } on StateError catch (e) {
      debugPrint('Onboarding save failed: $e');
      if (mounted) {
        setState(
          () => _error = 'Please sign in again before saving your answers.',
        );
      }
      return;
    } catch (e, stack) {
      debugPrint('Onboarding save failed: $e\n$stack');
      if (mounted) {
        setState(
          () => _error = 'Could not save your answers. Please try again.',
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _saving = false);
    }

    if (mounted) context.goNamed(Routes.profile);
  }

  String _saveErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Could not save your answers. Please sign in again.';
      case 'unavailable':
        return 'Could not reach the server. Check your connection and try again.';
      default:
        return 'Could not save your answers. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (_step == 0) {
      return Scaffold(
        backgroundColor: kBrandGreen,
        body: SafeArea(child: _buildIntroPage(theme, l10n)),
      );
    }

    return _buildQuestionScaffold(
      questionNumber: _step,
      title: _questionTitle(_step, l10n),
      isLast: _step == _totalQuestions,
      child: _questionField(_step, l10n),
    );
  }

  Widget _buildIntroPage(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.onboardingTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.onboardingIntro,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 36),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: kBrandGreen,
                  minimumSize: const Size(180, 50),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                onPressed: _nextQuestion,
                child: Text(l10n.actionStartSurvey),
              ),
              const SizedBox(height: 16),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                onPressed: _showSkipSurveyDialog,
                child: Text(l10n.actionSkipForNow),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _questionTitle(int step, AppLocalizations l10n) {
    switch (step) {
      case 1:
        return l10n.onboardingQuestionLanguage;
      case 2:
        return l10n.onboardingQuestionLocation;
      case 3:
        return l10n.onboardingQuestionChildren;
      case 4:
        return l10n.onboardingQuestionPriorities;
      case 5:
        return l10n.onboardingQuestionEmployment;
      default:
        return l10n.onboardingQuestionAges;
    }
  }

  Widget _questionField(int step, AppLocalizations l10n) {
    if (_skippedQuestions.contains(step)) {
      return _skippedField(step);
    }

    switch (step) {
      case 1:
        return DropdownButtonFormField<String>(
          value: _languageCode,
          style: _dropdownValueStyle,
          dropdownColor: Colors.white,
          decoration: _inputDecoration(l10n.selectLanguage),
          hint: Text(l10n.selectLanguage),
          items: [
            for (final language in kAppLanguages)
              DropdownMenuItem(
                value: language.code,
                child: Text(language.nativeName),
              ),
          ],
          onChanged: (v) => setState(() {
            _skippedQuestions.remove(step);
            _languageCode = v;
            if (v != null) {
              ref.read(localeOverrideProvider.notifier).setCode(v);
            }
          }),
        );
      case 2:
        return TextField(
          controller: _locationController,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: kBrandGreen,
          onChanged: (_) => setState(() => _skippedQuestions.remove(step)),
          decoration: _inputDecoration(l10n.onboardingCityOrZip),
        );
      case 3:
        return DropdownButtonFormField<int>(
          value: _familySize,
          style: _dropdownValueStyle,
          dropdownColor: Colors.white,
          decoration: _inputDecoration(l10n.onboardingSelectChildren),
          hint: Text(l10n.onboardingSelectChildren),
          items: List.generate(
            9,
            (i) => DropdownMenuItem(
              value: i,
              child: Text('${i}${i == 8 ? '+' : ''}'),
            ),
          ),
          onChanged: (v) => setState(() {
            _skippedQuestions.remove(step);
            _familySize = v;
            _syncChildrenAgeFields();
          }),
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (value, _) in surveyPriorityOptions)
              CheckboxListTile(
                value: _selectedPriorities.contains(value),
                onChanged: (checked) => setState(() {
                  _skippedQuestions.remove(step);
                  if (checked ?? false) {
                    _selectedPriorities.add(value);
                  } else {
                    _selectedPriorities.remove(value);
                  }
                }),
                title: Text(
                  localizedPriorityLabel(l10n, value),
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                ),
                activeColor: kBrandGreen,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            CheckboxListTile(
              value: _otherPrioritySelected,
              onChanged: (checked) => setState(() {
                _skippedQuestions.remove(step);
                _otherPrioritySelected = checked ?? false;
                if (!_otherPrioritySelected) {
                  _otherPriorityController.clear();
                }
              }),
              title: Text(
                l10n.priorityOther,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              ),
              activeColor: kBrandGreen,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            if (_otherPrioritySelected) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _otherPriorityController,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: kBrandGreen,
                onChanged: (_) =>
                    setState(() => _skippedQuestions.remove(step)),
                decoration: _inputDecoration(l10n.priorityOtherHint),
              ),
            ],
          ],
        );
      case 5:
        return TextField(
          controller: _employmentController,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: kBrandGreen,
          onChanged: (_) => setState(() => _skippedQuestions.remove(step)),
          decoration: _inputDecoration('Your background'),
        );
      default:
        return ChildrenAgesEditor(
          draft: _childrenAges,
          emptyMessage: _skippedQuestions.contains(3) || _familySize == null
              ? 'Answer how many children you have first, or skip this question.'
              : 'No children’s ages to add.',
          onChanged: () => setState(() {
            _skippedQuestions.remove(step);
            _error = null;
          }),
        );
    }
  }

  Widget _skippedField(int step) {
    return InkWell(
      onTap: () => setState(() => _skippedQuestions.remove(step)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD9E2DE)),
        ),
        child: const Text(
          'Skipped',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  void _clearQuestionValue(int step) {
    switch (step) {
      case 1:
        _languageCode = null;
        break;
      case 2:
        _locationController.clear();
        break;
      case 3:
        _familySize = null;
        _syncChildrenAgeFields();
        break;
      case 4:
        _selectedPriorities.clear();
        _otherPrioritySelected = false;
        _otherPriorityController.clear();
        break;
      case 5:
        _employmentController.clear();
        break;
      case 6:
        _childrenAges.setCount(0);
        break;
    }
  }

  Widget _buildQuestionScaffold({
    required int questionNumber,
    required String title,
    required Widget child,
    bool isLast = false,
  }) {
    final l10n = AppLocalizations.of(context);
    final progress = questionNumber / _totalQuestions;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: _showSkipSurveyDialog,
                    child: Text(l10n.actionSkipSurvey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 20),
                              child,
                              if (_error != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: questionNumber > 1
                                ? OutlinedButton(
                                    onPressed: _previousQuestion,
                                    child: Text(l10n.actionPrevious),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: TextButton(
                              onPressed: () =>
                                  _skipCurrentQuestion(isLast: isLast),
                              child: Text(l10n.actionSkipQuestion),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton(
                              onPressed: _saving
                                  ? null
                                  : (isLast ? _saveAndContinue : _nextQuestion),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(110, 44),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                              ),
                              child: Text(isLast ? l10n.actionFinish : l10n.actionNext),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TweenAnimationBuilder<double>(
                      key: ValueKey(questionNumber),
                      tween: Tween<double>(
                        begin: (questionNumber - 1) / _totalQuestions,
                        end: progress,
                      ),
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(999),
                        backgroundColor: Colors.black12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          kBrandGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Question $questionNumber of $_totalQuestions',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> get _resolvedTopPriorities {
    final priorities = <String>[
      for (final (value, _) in surveyPriorityOptions)
        if (_selectedPriorities.contains(value)) value,
    ];
    if (_otherPrioritySelected) {
      final custom = _otherPriorityController.text.trim();
      if (custom.isNotEmpty) {
        priorities.add('Other ($custom)');
      }
    }
    return priorities;
  }

  void _applySavedTopPriorities(List<String> saved) {
    _selectedPriorities.clear();
    _otherPrioritySelected = false;
    _otherPriorityController.clear();
    for (final item in saved) {
      if (surveyPriorityPresets.contains(item)) {
        _selectedPriorities.add(item);
        continue;
      }
      if (item.startsWith('Other (') && item.endsWith(')')) {
        _otherPrioritySelected = true;
        _otherPriorityController.text = item.substring(7, item.length - 1);
        continue;
      }
      if (item.startsWith('Other ')) {
        _otherPrioritySelected = true;
        _otherPriorityController.text = item.substring(6);
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD9E2DE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBrandGreen, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.black87),
    );
  }

  TextStyle get _dropdownValueStyle =>
      const TextStyle(color: Colors.black87, fontSize: 16);
}
