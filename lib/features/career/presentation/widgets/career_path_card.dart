import 'package:flutter/material.dart';

import '../../../../core/models/career.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/ai_body_text.dart';
import '../../../../core/widgets/followup_panels.dart';
import '../../../../l10n/app_localizations.dart';

typedef CareerChecklistToggle = void Function({
  required String stepId,
  required bool isSkill,
  required int itemIndex,
  required bool done,
});

typedef CareerStepCompleteToggle = void Function({
  required String stepId,
  required bool complete,
});

class CareerPathCard extends StatelessWidget {
  const CareerPathCard({
    super.key,
    required this.index,
    required this.onRegenerate,
    this.path,
    this.regenerating = false,
    this.onToggleChecklist,
    this.onToggleStepComplete,
    this.qaController,
    this.noteController,
    this.qaHistory = const [],
    this.qaLoading = false,
    this.noteSubmitting = false,
    this.deletingNoteId,
    this.onAskQuestion,
    this.onSubmitNote,
    this.onDeleteNote,
  });

  final CareerPath? path;
  final int index;
  final VoidCallback onRegenerate;
  final bool regenerating;
  final CareerChecklistToggle? onToggleChecklist;
  final CareerStepCompleteToggle? onToggleStepComplete;
  final TextEditingController? qaController;
  final TextEditingController? noteController;
  final List<CareerQaExchange> qaHistory;
  final bool qaLoading;
  final bool noteSubmitting;
  final String? deletingNoteId;
  final VoidCallback? onAskQuestion;
  final VoidCallback? onSubmitNote;
  final ValueChanged<CareerNote>? onDeleteNote;

  bool get _isPlaceholder => path == null || !path!.hasContent;

  @override
  Widget build(BuildContext context) {
    if (_isPlaceholder) {
      return _PlaceholderPathCard(
        index: index,
        regenerating: regenerating,
        onGenerate: onRegenerate,
      );
    }

    final path = this.path!;
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBrandGreen.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.careerPathHeading(index + 1, path.title),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (regenerating)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                TextButton.icon(
                  onPressed: onRegenerate,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.careerRegenerate),
                  style: TextButton.styleFrom(foregroundColor: kBrandGreen),
                ),
            ],
          ),
          if (path.summary.isNotEmpty) ...[
            const SizedBox(height: 8),
            AiBodyText(
              path.summary,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87.withValues(alpha: 0.75),
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ..._buildTimeline(path.steps),
          if (qaController != null &&
              noteController != null &&
              onAskQuestion != null &&
              onSubmitNote != null &&
              onDeleteNote != null) ...[
            const SizedBox(height: 20),
            Divider(color: kBrandGreen.withValues(alpha: 0.15)),
            const SizedBox(height: 16),
            FollowupAskPanel(
              title: l10n.careerAskTitle,
              subtitle: l10n.careerAskSubtitle,
              hint: l10n.careerAskHint,
              controller: qaController!,
              loading: qaLoading,
              history: [
                for (final item in qaHistory)
                  FollowupQaTurn(
                    question: item.question,
                    answer: item.answer,
                  ),
              ],
              onSubmit: onAskQuestion!,
            ),
            const SizedBox(height: 20),
            Divider(color: kBrandGreen.withValues(alpha: 0.15)),
            const SizedBox(height: 16),
            FollowupNotesPanel(
              title: l10n.careerNotesTitle,
              subtitle: l10n.careerNotesSubtitle,
              hint: l10n.careerNotesHint,
              controller: noteController!,
              submitting: noteSubmitting,
              deletingNoteId: deletingNoteId,
              notes: [
                for (final note in path.notes)
                  FollowupNote(
                    id: note.id,
                    text: note.text,
                    createdAt: note.createdAt,
                  ),
              ],
              onSubmit: onSubmitNote!,
              onDelete: (item) {
                for (final note in path.notes) {
                  if (note.id.isNotEmpty && note.id == item.id) {
                    onDeleteNote!(note);
                    return;
                  }
                  if (note.text == item.text &&
                      note.createdAt == item.createdAt) {
                    onDeleteNote!(note);
                    return;
                  }
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildTimeline(List<CareerPathStep> steps) {
    final nowIndex = steps.indexWhere((step) => !step.isComplete);
    final widgets = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      widgets.add(
        _CareerStepNode(
          step: steps[i],
          isNow: nowIndex == i,
          onToggleChecklist: onToggleChecklist,
          onToggleStepComplete: onToggleStepComplete,
        ),
      );
      if (i < steps.length - 1) {
        widgets.add(const _TimelineArrow());
      }
    }
    return widgets;
  }
}

class _PlaceholderPathCard extends StatelessWidget {
  const _PlaceholderPathCard({
    required this.index,
    required this.regenerating,
    required this.onGenerate,
  });

  final int index;
  final bool regenerating;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = Colors.black87.withValues(alpha: 0.45);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBrandGreen.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.careerPathNumber(index + 1),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87.withValues(alpha: 0.55),
                  ),
                ),
              ),
              if (regenerating)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                TextButton.icon(
                  onPressed: onGenerate,
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: Text(l10n.careerGenerate),
                  style: TextButton.styleFrom(foregroundColor: kBrandGreen),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.careerPlaceholderBody,
            style: TextStyle(fontSize: 14, color: muted, height: 1.4),
          ),
          const SizedBox(height: 16),
          _PlaceholderStep(
            title: l10n.careerPlaceholderStartTitle,
            body: l10n.careerPlaceholderStartBody,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(width: 18),
                Icon(Icons.arrow_downward, size: 22, color: Color(0x66808F88)),
              ],
            ),
          ),
          _PlaceholderStep(
            title: l10n.careerPlaceholderCredsTitle,
            body: l10n.careerPlaceholderCredsBody,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(width: 18),
                Icon(Icons.arrow_downward, size: 22, color: Color(0x66808F88)),
              ],
            ),
          ),
          _PlaceholderStep(
            title: l10n.careerPlaceholderTargetTitle,
            body: l10n.careerPlaceholderTargetBody,
          ),
        ],
      ),
    );
  }
}

class _PlaceholderStep extends StatelessWidget {
  const _PlaceholderStep({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBrandPageBg.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBrandGreen.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87.withValues(alpha: 0.35),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineArrow extends StatelessWidget {
  const _TimelineArrow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Icon(
            Icons.arrow_downward,
            size: 22,
            color: kBrandGreen.withValues(alpha: 0.55),
          ),
        ],
      ),
    );
  }
}

class _CareerStepNode extends StatelessWidget {
  const _CareerStepNode({
    required this.step,
    required this.isNow,
    this.onToggleChecklist,
    this.onToggleStepComplete,
  });

  final CareerPathStep step;
  final bool isNow;
  final CareerChecklistToggle? onToggleChecklist;
  final CareerStepCompleteToggle? onToggleStepComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isComplete = step.isComplete;
    final duration = step.durationLabel;
    final timeLabel = isComplete
        ? l10n.careerStepCompleted
        : isNow
            ? (duration.isEmpty
                ? l10n.careerStepNow
                : l10n.careerStepNowWithDuration(duration))
            : (duration.isEmpty ? l10n.careerTimePending : duration);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isComplete
            ? kBrandGreen.withValues(alpha: 0.06)
            : isNow
            ? kBrandGreen.withValues(alpha: 0.08)
            : kBrandPageBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isComplete
              ? kBrandGreen.withValues(alpha: 0.45)
              : isNow
              ? kBrandGreen.withValues(alpha: 0.35)
              : kBrandGreen.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87.withValues(
                alpha: isComplete ? 0.55 : 1,
              ),
            ),
          ),
          if (step.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            AiBodyText(
              step.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ],
          if (step.certifications.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              l10n.careerCertifications,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kBrandGreen.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 2),
            ...step.certifications.asMap().entries.map(
              (entry) => _ChecklistRow(
                item: entry.value,
                onChanged: onToggleChecklist == null
                    ? null
                    : (done) => onToggleChecklist!(
                          stepId: step.id,
                          isSkill: false,
                          itemIndex: entry.key,
                          done: done,
                        ),
              ),
            ),
          ],
          if (step.skills.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.careerSkills,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kBrandGreen.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 2),
            ...step.skills.asMap().entries.map(
              (entry) => _ChecklistRow(
                item: entry.value,
                onChanged: onToggleChecklist == null
                    ? null
                    : (done) => onToggleChecklist!(
                          stepId: step.id,
                          isSkill: true,
                          itemIndex: entry.key,
                          done: done,
                        ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            l10n.careerTimeEstimate,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kBrandGreen.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                isComplete ? Icons.check_circle : Icons.hourglass_empty,
                size: 16,
                color: kBrandGreen.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  timeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87.withValues(alpha: 0.75),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onToggleStepComplete == null
                    ? null
                    : () => onToggleStepComplete!(
                          stepId: step.id,
                          complete: !step.isComplete,
                        ),
                icon: Icon(
                  step.isComplete
                      ? Icons.undo
                      : Icons.check_circle_outline,
                  size: 20,
                ),
                label: Text(
                  step.isComplete ? l10n.careerUndo : l10n.careerMarkComplete,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: kBrandGreen,
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.item,
    required this.onChanged,
  });

  final CareerChecklistItem item;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!item.done),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Checkbox(
                value: item.done,
                onChanged: onChanged == null
                    ? null
                    : (value) => onChanged!(value ?? false),
                activeColor: kBrandGreen,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Colors.black87.withValues(
                      alpha: item.done ? 0.55 : 0.85,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
