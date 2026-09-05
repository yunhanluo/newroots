import 'package:flutter/material.dart';

import '../../../../core/models/roadmap.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/ai_body_text.dart';
import '../../../../core/widgets/followup_panels.dart';
import '../../../../l10n/app_localizations.dart';

class RoadmapSectionCard extends StatelessWidget {
  const RoadmapSectionCard({
    super.key,
    required this.title,
    required this.section,
    this.qaHistory = const [],
    required this.onChecklistChanged,
    required this.onRegenerate,
    required this.qaController,
    required this.noteController,
    required this.qaLoading,
    required this.noteSubmitting,
    required this.onAskQuestion,
    required this.onSubmitNote,
    required this.onDeleteNote,
    this.deletingNoteId,
    this.regenerating = false,
  });

  final String title;
  final RoadmapSection section;
  final List<RoadmapQaExchange> qaHistory;
  final ValueChanged<RoadmapSection> onChecklistChanged;
  final VoidCallback onRegenerate;
  final TextEditingController qaController;
  final TextEditingController noteController;
  final bool qaLoading;
  final bool noteSubmitting;
  final VoidCallback onAskQuestion;
  final VoidCallback onSubmitNote;
  final ValueChanged<RoadmapNote> onDeleteNote;
  final String? deletingNoteId;
  final bool regenerating;

  @override
  Widget build(BuildContext context) {
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
                  title,
                  style: const TextStyle(
                    fontSize: 20,
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
          if (section.summary.isNotEmpty) ...[
            const SizedBox(height: 12),
            AiBodyText(
              section.summary,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87.withValues(alpha: 0.85),
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (section.checklist.isEmpty)
            Text(
              l10n.roadmapNoChecklist,
              style: TextStyle(
                color: Colors.black87.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...section.checklist.map(
              (item) => _ChecklistRow(
                item: item,
                onChanged: (updated) {
                  final next = section.checklist
                      .map(
                        (existing) =>
                            existing.id == updated.id ? updated : existing,
                      )
                      .toList();
                  onChecklistChanged(section.copyWith(checklist: next));
                },
              ),
            ),
          const SizedBox(height: 20),
          Divider(color: kBrandGreen.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          FollowupAskPanel(
            title: l10n.roadmapAskTitle,
            subtitle: l10n.roadmapAskSubtitle,
            hint: l10n.roadmapAskHint,
            controller: qaController,
            loading: qaLoading,
            history: [
              for (final item in qaHistory)
                FollowupQaTurn(question: item.question, answer: item.answer),
            ],
            onSubmit: onAskQuestion,
          ),
          const SizedBox(height: 20),
          Divider(color: kBrandGreen.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          FollowupNotesPanel(
            title: l10n.roadmapNotesTitle,
            subtitle: l10n.roadmapNotesSubtitle,
            hint: l10n.roadmapNotesHint,
            controller: noteController,
            submitting: noteSubmitting,
            deletingNoteId: deletingNoteId,
            notes: [
              for (final note in section.notes)
                FollowupNote(
                  id: note.id,
                  text: note.text,
                  createdAt: note.createdAt,
                ),
            ],
            onSubmit: onSubmitNote,
            onDelete: (item) {
              for (final note in section.notes) {
                if (note.id.isNotEmpty && note.id == item.id) {
                  onDeleteNote(note);
                  return;
                }
                if (note.text == item.text &&
                    note.createdAt == item.createdAt) {
                  onDeleteNote(note);
                  return;
                }
              }
            },
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

  final RoadmapChecklistItem item;
  final ValueChanged<RoadmapChecklistItem> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item.done,
            activeColor: kBrandGreen,
            onChanged: (value) => onChanged(item.copyWith(done: value ?? false)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                item.text,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87.withValues(
                    alpha: item.done ? 0.55 : 0.9,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
