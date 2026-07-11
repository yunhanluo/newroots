import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/roadmap.dart';
import '../../../../core/theme/brand_colors.dart';

class RoadmapSectionCard extends StatelessWidget {
  const RoadmapSectionCard({
    super.key,
    required this.title,
    required this.section,
    required this.onChecklistChanged,
    required this.onRegenerate,
    required this.qaController,
    required this.noteController,
    required this.qaLoading,
    required this.noteSubmitting,
    required this.onAskQuestion,
    required this.onSubmitNote,
    this.regenerating = false,
  });

  final String title;
  final RoadmapSection section;
  final ValueChanged<RoadmapSection> onChecklistChanged;
  final VoidCallback onRegenerate;
  final TextEditingController qaController;
  final TextEditingController noteController;
  final bool qaLoading;
  final bool noteSubmitting;
  final VoidCallback onAskQuestion;
  final VoidCallback onSubmitNote;
  final bool regenerating;

  @override
  Widget build(BuildContext context) {
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
                  label: const Text('Regenerate'),
                  style: TextButton.styleFrom(foregroundColor: kBrandGreen),
                ),
            ],
          ),
          if (section.summary.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
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
              'No checklist items yet.',
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
          _SectionQaPanel(
            controller: qaController,
            loading: qaLoading,
            history: section.qaHistory,
            onSubmit: onAskQuestion,
          ),
          const SizedBox(height: 20),
          Divider(color: kBrandGreen.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          _SectionNotesPanel(
            controller: noteController,
            submitting: noteSubmitting,
            notes: section.notes,
            onSubmit: onSubmitNote,
          ),
        ],
      ),
    );
  }
}

class _SectionQaPanel extends StatelessWidget {
  const _SectionQaPanel({
    required this.controller,
    required this.loading,
    required this.history,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool loading;
  final List<RoadmapQaExchange> history;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Ask about this section',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Questions use this section\'s checklist, notes, and your survey.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black87.withValues(alpha: 0.6),
          ),
        ),
        if (history.isNotEmpty) ...[
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 160),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (_, _) => const Divider(height: 14),
              itemBuilder: (context, index) {
                final item = history[history.length - 1 - index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q: ${item.question}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.answer,
                      style: TextStyle(
                        color: Colors.black87.withValues(alpha: 0.85),
                        height: 1.4,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Ask about a step in this section…',
            filled: true,
            fillColor: kBrandPageBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : FilledButton(
                  onPressed: onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: kBrandGreen,
                    minimumSize: const Size(72, 44),
                  ),
                  child: const Text('Ask'),
                ),
        ),
      ],
    );
  }
}

class _SectionNotesPanel extends StatelessWidget {
  const _SectionNotesPanel({
    required this.controller,
    required this.submitting,
    required this.notes,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool submitting;
  final List<RoadmapNote> notes;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y • h:mm a');
    final sorted = [...notes]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Notes for this section',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Track progress on these steps. Saved and shared with the AI.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black87.withValues(alpha: 0.6),
          ),
        ),
        if (sorted.isNotEmpty) ...[
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 160),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const Divider(height: 14),
              itemBuilder: (context, index) {
                final note = sorted[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(note.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note.text,
                      style: TextStyle(
                        color: Colors.black87.withValues(alpha: 0.9),
                        height: 1.4,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          minLines: 2,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'What have you done for this section?',
            filled: true,
            fillColor: kBrandPageBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: submitting ? null : onSubmit,
            style: FilledButton.styleFrom(backgroundColor: kBrandGreen),
            child: submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save note'),
          ),
        ),
      ],
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
                  color: Colors.black87.withValues(alpha: 0.9),
                  decoration: item.done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
