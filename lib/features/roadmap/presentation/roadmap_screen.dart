import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/roadmap.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/roadmap_ai_local.dart';
import '../../../core/services/roadmap_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_scaffold.dart';
import 'widgets/roadmap_section_card.dart';

/// Personalized integration roadmap generated from onboarding survey data.
class RoadmapScreen extends ConsumerStatefulWidget {
  const RoadmapScreen({super.key});

  @override
  ConsumerState<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends ConsumerState<RoadmapScreen> {
  late final Map<RoadmapSectionKey, TextEditingController> _qaControllers;
  late final Map<RoadmapSectionKey, TextEditingController> _noteControllers;
  final _clarificationController = TextEditingController();

  bool _generating = false;
  RoadmapSectionKey? _qaLoadingSection;
  RoadmapSectionKey? _noteSubmittingSection;
  RoadmapSectionKey? _regeneratingSection;
  List<String> _pendingQuestions = [];
  int _clarificationQueueTotal = 0;
  String? _error;
  RoadmapAiDebugStatus? _debugStatus;

  @override
  void initState() {
    super.initState();
    _qaControllers = {
      for (final key in RoadmapSectionKey.values) key: TextEditingController(),
    };
    _noteControllers = {
      for (final key in RoadmapSectionKey.values) key: TextEditingController(),
    };
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _runDebugStatusCheck();
      });
    }
  }

  Future<void> _runDebugStatusCheck() async {
    final status = await ref.read(aiServiceProvider).fetchDebugStatus();
    if (mounted) setState(() => _debugStatus = status);
  }

  @override
  void dispose() {
    for (final controller in _qaControllers.values) {
      controller.dispose();
    }
    for (final controller in _noteControllers.values) {
      controller.dispose();
    }
    _clarificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
    final roadmap =
        ref.watch(roadmapProvider).value ?? IntegrationRoadmap.empty();

    final hasRoadmap = !roadmap.isEmpty;
    final hasPendingClarifications = _pendingQuestions.isNotEmpty;
    final clarificationIndex =
        _clarificationQueueTotal - _pendingQuestions.length + 1;

    return BrandScaffold(
      title: 'Integration Roadmap',
      actions: [
        if (hasRoadmap)
          IconButton(
            tooltip: 'Regenerate all',
            onPressed: _generating || profile == null
                ? null
                : () => _confirmRegenerate(
                    title: 'Regenerate entire roadmap?',
                    message:
                        'This replaces all three sections with a fresh AI plan. Your section notes and Q&A are kept.',
                    onConfirm: () => _regenerateAll(profile!, roadmap),
                  ),
            icon: const Icon(Icons.refresh),
          ),
      ],
      body: Stack(
        children: [
          Column(
            children: [
              if (kDebugMode && (_debugStatus?.hasProblem ?? false))
                _DebugApiKeyBanner(status: _debugStatus!),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (profile == null || !profile.hasSurveyData) ...[
                        _EmptySurveyCard(
                          onTakeSurvey: () =>
                              context.pushNamed(Routes.onboarding),
                        ),
                      ] else if (_generating && !hasRoadmap) ...[
                        const _GeneratingCard(
                          message: 'Creating your personalized roadmap…',
                        ),
                      ] else if (hasPendingClarifications && !hasRoadmap) ...[
                        const _GeneratingCard(
                          message:
                              'Answer the questions below so we can finish your roadmap.',
                        ),
                      ] else if (hasRoadmap) ...[
                        Text(
                          'Your settlement plan based on your survey answers.',
                          style: TextStyle(
                            color: Colors.black87.withValues(alpha: 0.7),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...RoadmapSectionKey.values.map(
                          (key) => RoadmapSectionCard(
                            title: key.label,
                            section: roadmap.sectionFor(key),
                            regenerating: _regeneratingSection == key,
                            qaController: _qaControllers[key]!,
                            noteController: _noteControllers[key]!,
                            qaLoading: _qaLoadingSection == key,
                            noteSubmitting: _noteSubmittingSection == key,
                            onRegenerate: () => _confirmRegenerate(
                              title: 'Regenerate ${key.label}?',
                              message:
                                  'This section will be replaced with a new AI-generated plan. Notes and Q&A for this section are kept.',
                              onConfirm: () => _regenerateSection(
                                profile!,
                                roadmap,
                                key,
                              ),
                            ),
                            onChecklistChanged: (section) =>
                                _saveSection(key, section),
                            onAskQuestion: () =>
                                _askQuestion(profile!, roadmap, key),
                            onSubmitNote: () => _submitNote(key),
                          ),
                        ),
                      ] else if (!_generating) ...[
                        _EmptySurveyCard(
                          message:
                              'No roadmap yet. Tap below to generate one from your survey.',
                          actionLabel: 'Generate Roadmap',
                          onTakeSurvey: () =>
                              _generateRoadmap(profile!, roadmap),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (hasPendingClarifications)
                _ClarificationBar(
                  question: _pendingQuestions.first,
                  currentIndex: clarificationIndex,
                  totalCount: _clarificationQueueTotal,
                  upcomingQuestions: _pendingQuestions.length > 1
                      ? _pendingQuestions.sublist(1)
                      : const [],
                  controller: _clarificationController,
                  onSubmit: profile == null
                      ? null
                      : () => _submitClarification(profile, roadmap),
                ),
            ],
          ),
          if (_generating && hasRoadmap && !hasPendingClarifications)
            Container(
              color: Colors.black.withValues(alpha: 0.08),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Updating your roadmap…'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmRegenerate({
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: kBrandGreen),
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );
    if (confirmed == true) await onConfirm();
  }

  Future<void> _generateRoadmap(
    UserProfileData profile,
    IntegrationRoadmap existing,
  ) async {
    setState(() {
      _generating = true;
      _error = null;
    });

    try {
      final response = await ref
          .read(aiServiceProvider)
          .generateRoadmap(
            profile: profile,
            clarifications: existing.clarifications,
            existing: existing.isEmpty ? null : existing,
          );
      await _handleAiResponse(response, profile, existing);
    } catch (error) {
      if (mounted) {
        setState(() => _error = describeRoadmapAiError(error));
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _submitClarification(
    UserProfileData profile,
    IntegrationRoadmap existing,
  ) async {
    final answer = _clarificationController.text.trim();
    if (answer.isEmpty || _pendingQuestions.isEmpty) return;

    final question = _pendingQuestions.first;
    final remainingAfterAnswer = _pendingQuestions.sublist(1);

    setState(() {
      _generating = true;
      _error = null;
      _pendingQuestions = remainingAfterAnswer;
    });
    _clarificationController.clear();

    try {
      await ref
          .read(roadmapServiceProvider)
          .addClarification(
            ClarificationExchange(
              question: question,
              answer: answer,
              answeredAt: DateTime.now(),
            ),
          );

      if (remainingAfterAnswer.isNotEmpty) {
        return;
      }

      final updated = await ref.read(roadmapServiceProvider).getRoadmap();
      final response = await ref
          .read(aiServiceProvider)
          .submitClarification(
            profile: profile,
            clarifications: updated.clarifications,
            question: question,
            answer: answer,
            existing: updated.isEmpty ? null : updated,
          );
      await _handleAiResponse(response, profile, updated);
    } catch (error) {
      if (mounted) setState(() => _error = describeRoadmapAiError(error));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  void _setClarificationQueue(List<String> questions) {
    if (questions.isEmpty) {
      _pendingQuestions = [];
      _clarificationQueueTotal = 0;
      return;
    }
    _pendingQuestions = List<String>.from(questions);
    _clarificationQueueTotal = questions.length;
  }

  Future<void> _handleAiResponse(
    RoadmapAiResponse response,
    UserProfileData profile,
    IntegrationRoadmap existing,
  ) async {
    if (response.status == RoadmapAiStatus.needsClarification) {
      setState(() => _setClarificationQueue(response.clarificationQueue));
      return;
    }

    if (response.status == RoadmapAiStatus.error) {
      setState(() {
        _setClarificationQueue(const []);
        _error = response.errorMessage ?? 'AI service is unavailable.';
      });
      return;
    }

    setState(() => _setClarificationQueue(const []));

    if (response.status == RoadmapAiStatus.complete &&
        response.roadmap != null) {
      final merged = response.roadmap!.copyWith(
        clarifications: existing.clarifications.isNotEmpty
            ? existing.clarifications
            : response.roadmap!.clarifications,
        firstMonth: response.roadmap!.firstMonth.copyWith(
          notes: existing.firstMonth.notes,
          qaHistory: existing.firstMonth.qaHistory,
        ),
        firstThreeMonths: response.roadmap!.firstThreeMonths.copyWith(
          notes: existing.firstThreeMonths.notes,
          qaHistory: existing.firstThreeMonths.qaHistory,
        ),
        firstYear: response.roadmap!.firstYear.copyWith(
          notes: existing.firstYear.notes,
          qaHistory: existing.firstYear.qaHistory,
        ),
        generatedAt: DateTime.now(),
      );
      await ref.read(roadmapServiceProvider).saveRoadmap(merged);
      return;
    }

    if (response.status == RoadmapAiStatus.complete &&
        response.sectionData != null &&
        response.section != null) {
      final key = response.section!;
      final current = await ref.read(roadmapServiceProvider).getRoadmap();
      final existingSection = current.sectionFor(key);
      final regenerated = response.sectionData!.copyWith(
        notes: existingSection.notes,
        qaHistory: existingSection.qaHistory,
      );
      final updated = current.withSection(key, regenerated);
      await ref.read(roadmapServiceProvider).saveRoadmap(updated);
    }
  }

  Future<void> _regenerateAll(
    UserProfileData profile,
    IntegrationRoadmap existing,
  ) async {
    setState(() {
      _generating = true;
      _error = null;
      _setClarificationQueue(const []);
    });

    try {
      final response = await ref
          .read(aiServiceProvider)
          .regenerateRoadmap(
            profile: profile,
            clarifications: existing.clarifications,
            existing: existing,
          );
      await _handleAiResponse(response, profile, existing);
    } catch (error) {
      if (mounted) setState(() => _error = describeRoadmapAiError(error));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _regenerateSection(
    UserProfileData profile,
    IntegrationRoadmap existing,
    RoadmapSectionKey section,
  ) async {
    setState(() {
      _regeneratingSection = section;
      _error = null;
    });

    try {
      final response = await ref
          .read(aiServiceProvider)
          .regenerateSection(
            profile: profile,
            section: section,
            clarifications: existing.clarifications,
            existing: existing,
          );
      await _handleAiResponse(response, profile, existing);
    } catch (error) {
      if (mounted) setState(() => _error = describeRoadmapAiError(error));
    } finally {
      if (mounted) setState(() => _regeneratingSection = null);
    }
  }

  Future<void> _saveSection(
    RoadmapSectionKey key,
    RoadmapSection section,
  ) async {
    await ref.read(roadmapServiceProvider).updateSection(key, section);
  }

  Future<void> _askQuestion(
    UserProfileData profile,
    IntegrationRoadmap roadmap,
    RoadmapSectionKey section,
  ) async {
    final question = _qaControllers[section]!.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _qaLoadingSection = section;
      _error = null;
    });

    try {
      final response = await ref
          .read(aiServiceProvider)
          .askRoadmapQuestion(
            profile: profile,
            roadmap: roadmap,
            section: section,
            question: question,
          );
      if (response.status == RoadmapAiStatus.answer &&
          response.answer != null) {
        await ref.read(roadmapServiceProvider).addQaExchange(
              section,
              RoadmapQaExchange(
                question: question,
                answer: response.answer!,
                askedAt: DateTime.now(),
              ),
            );
        _qaControllers[section]!.clear();
      } else if (response.status == RoadmapAiStatus.error) {
        if (mounted) {
          setState(
            () => _error = response.errorMessage ?? 'AI could not answer.',
          );
        }
      }
    } catch (error) {
      if (mounted) setState(() => _error = describeRoadmapAiError(error));
    } finally {
      if (mounted) setState(() => _qaLoadingSection = null);
    }
  }

  Future<void> _submitNote(RoadmapSectionKey section) async {
    final text = _noteControllers[section]!.text.trim();
    if (text.isEmpty) return;

    setState(() => _noteSubmittingSection = section);
    try {
      await ref.read(roadmapServiceProvider).addNote(section, text);
      _noteControllers[section]!.clear();
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not save note.');
    } finally {
      if (mounted) setState(() => _noteSubmittingSection = null);
    }
  }
}

class _DebugApiKeyBanner extends StatelessWidget {
  const _DebugApiKeyBanner({required this.status});

  final RoadmapAiDebugStatus status;

  @override
  Widget build(BuildContext context) {
    final message = !status.apiKeyConfigured
        ? 'DEBUG: OPENAI_API_KEY is not set on the server. '
            'Run: firebase functions:secrets:set OPENAI_API_KEY'
        : 'DEBUG: OpenAI is not reachable. ${status.detail ?? ''}';

    return Material(
      color: const Color(0xFFFFF3E0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.bug_report, size: 18, color: Colors.orange.shade800),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange.shade900,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratingCard extends StatelessWidget {
  const _GeneratingCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBrandGreen.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySurveyCard extends StatelessWidget {
  const _EmptySurveyCard({
    required this.onTakeSurvey,
    this.message =
        'Take the onboarding survey so we can build a personalized roadmap.',
    this.actionLabel = 'Take survey',
  });

  final VoidCallback onTakeSurvey;
  final String message;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBrandGreen.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          const Icon(Icons.map_outlined, size: 48, color: kBrandGreen),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87.withValues(alpha: 0.75),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onTakeSurvey,
            style: FilledButton.styleFrom(backgroundColor: kBrandGreen),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _ClarificationBar extends StatelessWidget {
  const _ClarificationBar({
    required this.question,
    required this.currentIndex,
    required this.totalCount,
    required this.upcomingQuestions,
    required this.controller,
    required this.onSubmit,
  });

  final String question;
  final int currentIndex;
  final int totalCount;
  final List<String> upcomingQuestions;
  final TextEditingController controller;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.help_outline, color: kBrandGreen, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      totalCount > 1
                          ? 'Question $currentIndex of $totalCount'
                          : 'One quick question',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (totalCount > 1)
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: currentIndex / totalCount,
                        color: kBrandGreen,
                        backgroundColor: kBrandGreen.withValues(alpha: 0.15),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                question,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
              if (upcomingQuestions.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Up next: ${upcomingQuestions.first}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Your answer',
                        filled: true,
                        fillColor: kBrandPageBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: kBrandGreen.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                      onSubmitted: (_) => onSubmit?.call(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: onSubmit,
                    style: FilledButton.styleFrom(
                      backgroundColor: kBrandGreen,
                      minimumSize: const Size(72, 48),
                    ),
                    child: Text(
                      totalCount > 1 && currentIndex < totalCount
                          ? 'Next'
                          : 'Send',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
