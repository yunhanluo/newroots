import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/widgets/auth_widgets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/user_profile_service.dart';

/// Intro + survey flow shown right after account creation.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _locationController = TextEditingController();
  final _employmentController = TextEditingController();
  final _childrenController = TextEditingController();
  final _otherPriorityController = TextEditingController();

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
    _childrenController.dispose();
    _otherPriorityController.dispose();
    super.dispose();
  }

  Future<void> _showSkipSurveyDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip onboarding survey?'),
        content: const Text(
          'Taking the survey lets us understand your situation and design '
          'solutions (individual questions can be skipped).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue survey'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(minimumSize: const Size(120, 44)),
            child: const Text('Skip for now'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The survey can be taken at any time on the profile page.',
          ),
        ),
      );
      context.go('/');
    }
  }

  Future<void> _prefillFromExistingProfile() async {
    final profile = await ref
        .read(userProfileServiceProvider)
        .getCurrentUserProfile();
    if (!mounted || profile == null) return;
    setState(() {
      _skippedQuestions
        ..clear()
        ..addAll(profile.skippedQuestions);
      _languageCode = _skippedQuestions.contains(1)
          ? null
          : (profile.languageCode.isEmpty ? null : profile.languageCode);
      _locationController.text =
          _skippedQuestions.contains(2) ? '' : profile.location;
      _familySize =
          _skippedQuestions.contains(3) ? null : profile.familySize;
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
      _childrenController.text =
          _skippedQuestions.contains(6) ? '' : profile.childrenInfo;
    });
  }

  void _nextQuestion() {
    if (_step >= _totalQuestions) return;
    setState(() => _step += 1);
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
            childrenInfo: _childrenController.text,
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

    if (_step == 0) {
      return Scaffold(
        backgroundColor: kBrandGreen,
        body: SafeArea(child: _buildIntroPage(theme)),
      );
    }

    return _buildQuestionScaffold(
      questionNumber: _step,
      title: _questionTitle(_step),
      isLast: _step == _totalQuestions,
      child: _questionField(_step),
    );
  }

  Widget _buildIntroPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Onboarding Survey',
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Take a quick survey for personalization.',
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
                child: const Text('Start Survey'),
              ),
              const SizedBox(height: 16),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                onPressed: _showSkipSurveyDialog,
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _questionTitle(int step) {
    switch (step) {
      case 1:
        return 'Preferred language';
      case 2:
        return 'Where are you located?';
      case 3:
        return 'Family size';
      case 4:
        return 'Top priorities right now';
      case 5:
        return 'Employment background';
      default:
        return 'Children ages';
    }
  }

  Widget _questionField(int step) {
    if (_skippedQuestions.contains(step)) {
      return _skippedField(step);
    }

    switch (step) {
      case 1:
        return DropdownButtonFormField<String>(
          value: _languageCode,
          style: _dropdownValueStyle,
          dropdownColor: Colors.white,
          decoration: _inputDecoration('Select language'),
          hint: const Text('Select language'),
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'es', child: Text('Spanish')),
            DropdownMenuItem(value: 'zh', child: Text('Chinese')),
            DropdownMenuItem(value: 'vi', child: Text('Vietnamese')),
            DropdownMenuItem(value: 'ko', child: Text('Korean')),
            DropdownMenuItem(value: 'hi', child: Text('Hindi')),
            DropdownMenuItem(value: 'ar', child: Text('Arabic')),
          ],
          onChanged: (v) => setState(() {
            _skippedQuestions.remove(step);
            _languageCode = v;
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
          decoration: _inputDecoration('City or ZIP code'),
        );
      case 3:
        return DropdownButtonFormField<int>(
          value: _familySize,
          style: _dropdownValueStyle,
          dropdownColor: Colors.white,
          decoration: _inputDecoration('Select family size'),
          hint: const Text('Select family size'),
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
          }),
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (value, label) in surveyPriorityOptions)
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
                  label,
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
              title: const Text(
                'Other',
                style: TextStyle(color: Colors.black87, fontSize: 16),
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
                decoration: _inputDecoration('Describe your priority'),
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
        return TextField(
          controller: _childrenController,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: kBrandGreen,
          onChanged: (_) => setState(() => _skippedQuestions.remove(step)),
          decoration: _inputDecoration('e.g. 6, 10'),
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
        _childrenController.clear();
        break;
    }
  }

  Widget _buildQuestionScaffold({
    required int questionNumber,
    required String title,
    required Widget child,
    bool isLast = false,
  }) {
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
                    child: const Text('Skip Survey'),
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
                                    child: const Text('Previous'),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: TextButton(
                              onPressed: () =>
                                  _skipCurrentQuestion(isLast: isLast),
                              child: const Text('Skip question'),
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
                              child: Text(isLast ? 'Finish' : 'Next'),
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
