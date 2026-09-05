import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_locale.dart';
import '../../../core/models/career.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/career_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/career_path_card.dart';

/// AI-powered career pathway mapping from prior experience to US roles.
class CareerScreen extends ConsumerStatefulWidget {
  const CareerScreen({super.key});

  @override
  ConsumerState<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends ConsumerState<CareerScreen> {
  final _notesController = TextEditingController();
  late final List<TextEditingController> _qaControllers;
  late final List<TextEditingController> _noteControllers;
  final _sessionQa = <int, List<CareerQaExchange>>{};
  bool _generatingAll = false;
  int? _regeneratingPathIndex;
  int? _qaLoadingPathIndex;
  int? _noteSubmittingPathIndex;
  String? _deletingNoteId;
  bool _notesSynced = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _qaControllers = List.generate(
      CareerBridgeData.pathSlotCount,
      (_) => TextEditingController(),
    );
    _noteControllers = List.generate(
      CareerBridgeData.pathSlotCount,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (final controller in _qaControllers) {
      controller.dispose();
    }
    for (final controller in _noteControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncNotesFromCareer(CareerBridgeData career) {
    if (_notesSynced) return;
    if (career.additionalNotes.isNotEmpty) {
      _notesController.text = career.additionalNotes;
    }
    _notesSynced = true;
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
    final career = ref.watch(careerProvider).value ?? CareerBridgeData.empty();
    _syncNotesFromCareer(career);

    final pathSlots = career.pathSlots;
    final hasAnyPath = pathSlots.any((path) => path != null);
    final hasPriorJob = profile?.employmentBackground.isNotEmpty ?? false;
    final canGenerate = profile != null &&
        (hasPriorJob || _notesController.text.trim().isNotEmpty);
    final l10n = AppLocalizations.of(context);

    return BrandScaffold(
      title: l10n.featureCareer,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (profile == null) ...[
              _InfoCard(
                icon: Icons.person_outline,
                message: l10n.careerSignIn,
              ),
            ] else ...[
              if (hasPriorJob) ...[
                _PriorJobCard(background: profile.employmentBackground),
                const SizedBox(height: 16),
              ] else ...[
                _InfoCard(
                  icon: Icons.info_outline,
                  message: l10n.careerAddPriorJob,
                  actionLabel: l10n.careerGoToProfile,
                  onAction: () => context.pushNamed(Routes.profile),
                ),
                const SizedBox(height: 16),
              ],
              _NotesInputCard(
                controller: _notesController,
                enabled: !_generatingAll && _regeneratingPathIndex == null,
                onChanged: (_) => setState(() {}),
                generateLabel: hasAnyPath
                    ? l10n.careerRegenerateAll
                    : l10n.careerGenerateAll,
                generating: _generatingAll,
                onGenerate: canGenerate &&
                        !_generatingAll &&
                        _regeneratingPathIndex == null
                    ? () => _generatePaths(profile)
                    : null,
              ),
              const SizedBox(height: 28),
              if (_generatingAll) ...[
                const _GeneratingCard(),
              ] else ...[
                ...List.generate(
                  CareerBridgeData.pathSlotCount,
                  (index) => CareerPathCard(
                    path: pathSlots[index],
                    index: index,
                    regenerating: _regeneratingPathIndex == index,
                    qaController: _qaControllers[index],
                    noteController: _noteControllers[index],
                    qaHistory: _sessionQa[index] ?? const [],
                    qaLoading: _qaLoadingPathIndex == index,
                    noteSubmitting: _noteSubmittingPathIndex == index,
                    deletingNoteId: _deletingNoteId,
                    onRegenerate: () => _confirmRegeneratePath(
                      profile,
                      career,
                      index,
                    ),
                    onToggleChecklist: ({
                      required String stepId,
                      required bool isSkill,
                      required int itemIndex,
                      required bool done,
                    }) =>
                        _toggleChecklistItem(
                      pathIndex: index,
                      stepId: stepId,
                      isSkill: isSkill,
                      itemIndex: itemIndex,
                      done: done,
                    ),
                    onToggleStepComplete: ({
                      required String stepId,
                      required bool complete,
                    }) =>
                        _toggleStepComplete(
                      pathIndex: index,
                      stepId: stepId,
                      complete: complete,
                    ),
                    onAskQuestion: () => _askQuestion(
                      profile,
                      career,
                      index,
                    ),
                    onSubmitNote: () => _submitNote(index),
                    onDeleteNote: (note) => _deleteNote(index, note),
                  ),
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
          ],
        ),
      ),
    );
  }

  Future<void> _toggleChecklistItem({
    required int pathIndex,
    required String stepId,
    required bool isSkill,
    required int itemIndex,
    required bool done,
  }) async {
    try {
      await ref.read(careerServiceProvider).setChecklistItemDone(
            pathIndex: pathIndex,
            stepId: stepId,
            isSkill: isSkill,
            itemIndex: itemIndex,
            done: done,
          );
    } catch (error) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).careerCouldNotSaveChecklist);
      }
    }
  }

  Future<void> _toggleStepComplete({
    required int pathIndex,
    required String stepId,
    required bool complete,
  }) async {
    try {
      await ref.read(careerServiceProvider).setStepComplete(
            pathIndex: pathIndex,
            stepId: stepId,
            complete: complete,
          );
    } on CareerStepOrderException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              error.issue == CareerStepOrderIssue.finishAbove
                  ? AppLocalizations.of(context).careerFinishStepAbove
                  : AppLocalizations.of(context).careerUndoLaterStep,
            ),
          ),
        );
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).careerCouldNotSaveStep);
      }
    }
  }

  Future<void> _askQuestion(
    UserProfileData profile,
    CareerBridgeData career,
    int pathIndex,
  ) async {
    final question = _qaControllers[pathIndex].text.trim();
    if (question.isEmpty) return;
    final path = pathIndex < career.pathSlots.length
        ? career.pathSlots[pathIndex]
        : null;
    if (path == null) return;

    setState(() {
      _qaLoadingPathIndex = pathIndex;
      _error = null;
    });

    try {
      final answer = await ref.read(aiServiceProvider).askCareerQuestion(
            profile: profile,
            additionalNotes: _notesController.text.trim(),
            path: path,
            qaHistory: _sessionQa[pathIndex] ?? const [],
            existingPaths: career.pathSlots,
            question: question,
            language: ref.read(appLocaleProvider).languageCode,
          );
      _qaControllers[pathIndex].clear();
      if (!mounted) return;
      setState(() {
        _sessionQa[pathIndex] = [
          ..._sessionQa[pathIndex] ?? const [],
          CareerQaExchange(
            question: question,
            answer: answer,
            askedAt: DateTime.now(),
          ),
        ];
      });
    } catch (error) {
      if (mounted) setState(() => _error = describeAiServiceError(error));
    } finally {
      if (mounted) setState(() => _qaLoadingPathIndex = null);
    }
  }

  Future<void> _submitNote(int pathIndex) async {
    final text = _noteControllers[pathIndex].text.trim();
    if (text.isEmpty) return;

    setState(() => _noteSubmittingPathIndex = pathIndex);
    try {
      await ref.read(careerServiceProvider).addNote(pathIndex, text);
      _noteControllers[pathIndex].clear();
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context).careerCouldNotSaveNote);
    } finally {
      if (mounted) setState(() => _noteSubmittingPathIndex = null);
    }
  }

  Future<void> _deleteNote(int pathIndex, CareerNote note) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.careerDeleteNoteTitle),
        content: Text(l10n.careerDeleteNoteBody),
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
      await ref.read(careerServiceProvider).deleteNote(pathIndex, note);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = AppLocalizations.of(context).careerCouldNotDeleteNote,
        );
      }
    } finally {
      if (mounted) setState(() => _deletingNoteId = null);
    }
  }

  Future<void> _confirmRegeneratePath(
    UserProfileData profile,
    CareerBridgeData career,
    int pathIndex,
  ) async {
    final l10n = AppLocalizations.of(context);
    final path = pathIndex < career.pathSlots.length
        ? career.pathSlots[pathIndex]
        : null;
    final isEmpty = path == null;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEmpty ? l10n.careerGeneratePathTitle : l10n.careerRegeneratePathTitle,
        ),
        content: Text(
          isEmpty
              ? l10n.careerGeneratePathBody(pathIndex + 1)
              : l10n.careerRegeneratePathBody(path.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: kBrandGreen),
            child: Text(isEmpty ? l10n.careerGenerate : l10n.careerRegenerate),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _regeneratePath(profile, career, pathIndex);
    }
  }

  Future<void> _regeneratePath(
    UserProfileData profile,
    CareerBridgeData career,
    int pathIndex,
  ) async {
    final notes = _notesController.text.trim();
    if (profile.employmentBackground.isEmpty && notes.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).careerNeedBackground);
      return;
    }

    setState(() {
      _regeneratingPathIndex = pathIndex;
      _sessionQa.remove(pathIndex);
      _error = null;
    });

    try {
      await ref.read(careerServiceProvider).saveAdditionalNotes(notes);
      final path = await ref.read(aiServiceProvider).regenerateCareerPath(
            profile: profile,
            additionalNotes: notes,
            existingPaths: career.pathSlots,
            pathIndex: pathIndex,
            language: ref.read(appLocaleProvider).languageCode,
          );
      await ref.read(careerServiceProvider).replacePath(pathIndex, path);
    } catch (error) {
      if (mounted) setState(() => _error = describeAiServiceError(error));
    } finally {
      if (mounted) setState(() => _regeneratingPathIndex = null);
    }
  }

  Future<void> _generatePaths(UserProfileData profile) async {
    final notes = _notesController.text.trim();
    if (profile.employmentBackground.isEmpty && notes.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).careerNeedBackground);
      return;
    }

    setState(() {
      _generatingAll = true;
      _sessionQa.clear();
      _error = null;
    });

    try {
      await ref.read(careerServiceProvider).saveAdditionalNotes(notes);
      final existing =
          ref.read(careerProvider).value ?? CareerBridgeData.empty();
      final paths = await ref.read(aiServiceProvider).generateCareerPaths(
            profile: profile,
            additionalNotes: notes,
            language: ref.read(appLocaleProvider).languageCode,
          );
      if (paths.isEmpty) {
        throw StateError('No career paths returned.');
      }
      final padded = List<CareerPath>.generate(
        CareerBridgeData.pathSlotCount,
        (index) {
          final generated = index < paths.length && paths[index].hasContent
              ? paths[index]
              : CareerPath.emptySlot(index);
          if (!generated.hasContent) return generated;
          final oldNotes = index < existing.paths.length
              ? existing.paths[index].notes
              : const <CareerNote>[];
          return generated.copyWith(notes: oldNotes);
        },
      );
      await ref.read(careerServiceProvider).saveCareer(
            CareerBridgeData(
              paths: padded,
              additionalNotes: notes,
              generatedAt: DateTime.now(),
            ),
          );
    } catch (error) {
      if (mounted) setState(() => _error = describeAiServiceError(error));
    } finally {
      if (mounted) setState(() => _generatingAll = false);
    }
  }
}

class _PriorJobCard extends StatelessWidget {
  const _PriorJobCard({required this.background});

  final String background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBrandGreen.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).careerPriorEmployment,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            background,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesInputCard extends StatelessWidget {
  const _NotesInputCard({
    required this.controller,
    required this.enabled,
    required this.onChanged,
    required this.generateLabel,
    required this.generating,
    required this.onGenerate,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final String generateLabel;
  final bool generating;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBrandGreen.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.careerAdditionalBackground,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.careerAdditionalBackgroundHelp,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87.withValues(alpha: 0.6),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            enabled: enabled,
            minLines: 3,
            maxLines: 6,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: l10n.careerAdditionalBackgroundHint,
              filled: true,
              fillColor: kBrandPageBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: onGenerate,
              style: FilledButton.styleFrom(backgroundColor: kBrandGreen),
              child: generating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(generateLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratingCard extends StatelessWidget {
  const _GeneratingCard();

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
            AppLocalizations.of(context).careerGenerating,
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBrandGreen.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: kBrandGreen),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87.withValues(alpha: 0.75),
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(backgroundColor: kBrandGreen),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
