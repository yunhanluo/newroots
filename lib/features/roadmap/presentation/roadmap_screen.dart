import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_locale.dart';
import '../../../core/models/roadmap.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/roadmap_ai_local.dart';
import '../../../core/services/roadmap_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_scaffold.dart';
import '../../../l10n/app_localizations.dart';
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
  String? _deletingNoteId;
  RoadmapSectionKey? _regeneratingSection;
  final _sessionQa = <RoadmapSectionKey, List<RoadmapQaExchange>>{};
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
    final l10n = AppLocalizations.of(context);

    return BrandScaffold(
      title: l10n.featureRoadmap,
      actions: [
        if (hasRoadmap)
          IconButton(
            tooltip: l10n.roadmapRegenerateAll,
            onPressed: _generating || profile == null
                ? null
                : () => _confirmRegenerate(
                    title: l10n.roadmapRegenerateAllTitle,
                    message: l10n.roadmapRegenerateAllBody,
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
                          message: l10n.roadmapEmptySurvey,
                          actionLabel: l10n.actionTakeSurvey,
                          onTakeSurvey: () =>
                              context.pushNamed(Routes.onboarding),
                        ),
                      ] else if (_generating && !hasRoadmap) ...[
                        _GeneratingCard(
                          message: l10n.roadmapCreating,
                        ),
                      ] else if (hasPendingClarifications && !hasRoadmap) ...[
                        _GeneratingCard(
                          message: l10n.roadmapAnswerQuestions,
                        ),
                      ] else if (hasRoadmap) ...[
                        Text(
                          l10n.roadmapSettlementPlan,
                          style: TextStyle(
                            color: Colors.black87.withValues(alpha: 0.7),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...RoadmapSectionKey.values.map(
                          (key) => RoadmapSectionCard(
                            title: _roadmapSectionTitle(l10n, key),
                            section: roadmap.sectionFor(key),
                            qaHistory: _sessionQa[key] ?? const [],
                            regenerating: _regeneratingSection == key,
                            qaController: _qaControllers[key]!,
                            noteController: _noteControllers[key]!,
                            qaLoading: _qaLoadingSection == key,
                            noteSubmitting: _noteSubmittingSection == key,
                            onRegenerate: () => _confirmRegenerate(
                              title: l10n.roadmapRegenerateSectionTitle(
                                _roadmapSectionTitle(l10n, key),
                              ),
                              message: l10n.roadmapRegenerateSectionBody,
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
                            onDeleteNote: (note) => _deleteNote(key, note),
                            deletingNoteId: _deletingNoteId,
                          ),
                        ),
                      ] else if (!_generating) ...[
                        _EmptySurveyCard(
                          message: l10n.roadmapNoRoadmap,
                          actionLabel: l10n.roadmapGenerate,
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
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(l10n.roadmapUpdating),
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
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: kBrandGreen),
            child: Text(AppLocalizations.of(context).careerRegenerate),
          ),
        ],
      ),
    );
    if (confirmed == true) await onConfirm();
  }

  String _roadmapSectionTitle(AppLocalizations l10n, RoadmapSectionKey key) {
    return switch (key) {
      RoadmapSectionKey.firstMonth => l10n.roadmapSectionFirstMonth,
      RoadmapSectionKey.firstThreeMonths => l10n.roadmapSectionFirstThreeMonths,
      RoadmapSectionKey.firstYear => l10n.roadmapSectionFirstYear,
    };
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
            language: ref.read(appLocaleProvider).languageCode,
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
            language: ref.read(appLocaleProvider).languageCode,
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
        _error = response.errorMessage ??
            AppLocalizations.of(context).roadmapAiUnavailable;
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
          qaHistory: const [],
        ),
        firstThreeMonths: response.roadmap!.firstThreeMonths.copyWith(
          notes: existing.firstThreeMonths.notes,
          qaHistory: const [],
        ),
        firstYear: response.roadmap!.firstYear.copyWith(
          notes: existing.firstYear.notes,
          qaHistory: const [],
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
        qaHistory: const [],
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
      _sessionQa.clear();
      _setClarificationQueue(const []);
    });

    try {
      final response = await ref
          .read(aiServiceProvider)
          .regenerateRoadmap(
            profile: profile,
            clarifications: existing.clarifications,
            existing: existing,
            language: ref.read(appLocaleProvider).languageCode,
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
      _sessionQa.remove(section);
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
            language: ref.read(appLocaleProvider).languageCode,
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
    await ref.read(roadmapServiceProvider).updateSection(
          key,
          section.copyWith(qaHistory: const []),
        );
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
            roadmap: _withSessionQa(roadmap),
            section: section,
            question: question,
            language: ref.read(appLocaleProvider).languageCode,
          );
      if (response.status == RoadmapAiStatus.answer &&
          response.answer != null) {
        final exchange = RoadmapQaExchange(
          question: question,
          answer: response.answer!,
          askedAt: DateTime.now(),
        );
        _qaControllers[section]!.clear();
        if (mounted) {
          setState(() {
            _sessionQa[section] = [
              ..._sessionQa[section] ?? const [],
              exchange,
            ];
          });
        }
      } else if (response.status == RoadmapAiStatus.error) {
        if (mounted) {
          setState(
            () => _error = response.errorMessage ??
                AppLocalizations.of(context).roadmapAiCouldNotAnswer,
          );
        }
      }
    } catch (error) {
      if (mounted) setState(() => _error = describeRoadmapAiError(error));
    } finally {
      if (mounted) setState(() => _qaLoadingSection = null);
    }
  }

  IntegrationRoadmap _withSessionQa(IntegrationRoadmap roadmap) {
    var next = roadmap;
    for (final key in RoadmapSectionKey.values) {
      next = next.withSection(
        key,
        next.sectionFor(key).copyWith(
          qaHistory: _sessionQa[key] ?? const [],
        ),
      );
    }
    return next;
  }

  Future<void> _submitNote(RoadmapSectionKey section) async {
    final text = _noteControllers[section]!.text.trim();
    if (text.isEmpty) return;

    setState(() => _noteSubmittingSection = section);
    try {
      await ref.read(roadmapServiceProvider).addNote(section, text);
      _noteControllers[section]!.clear();
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = AppLocalizations.of(context).roadmapCouldNotSaveNote,
        );
      }
    } finally {
      if (mounted) setState(() => _noteSubmittingSection = null);
    }
  }

  Future<void> _deleteNote(RoadmapSectionKey section, RoadmapNote note) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.roadmapDeleteNoteTitle),
        content: Text(l10n.roadmapDeleteNoteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _deletingNoteId = note.id;
      _error = null;
    });
    try {
      await ref.read(roadmapServiceProvider).deleteNote(section, note);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = AppLocalizations.of(context).roadmapCouldNotDeleteNote,
        );
      }
    } finally {
      if (mounted) setState(() => _deletingNoteId = null);
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
    required this.message,
    required this.actionLabel,
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
    final l10n = AppLocalizations.of(context);
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
                          ? l10n.roadmapQuestionOf(currentIndex, totalCount)
                          : l10n.roadmapOneQuestion,
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
                  l10n.roadmapUpNext(upcomingQuestions.first),
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
                        hintText: l10n.roadmapYourAnswer,
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
                          ? l10n.actionNext
                          : l10n.actionSend,
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
