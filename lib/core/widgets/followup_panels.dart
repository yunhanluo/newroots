import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/brand_colors.dart';
import '../../l10n/app_localizations.dart';
import 'ai_body_text.dart';

class FollowupQaTurn {
  const FollowupQaTurn({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}

class FollowupNote {
  const FollowupNote({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String text;
  final DateTime createdAt;
}

class FollowupAskPanel extends StatelessWidget {
  const FollowupAskPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.controller,
    required this.loading,
    required this.history,
    required this.onSubmit,
  });

  final String title;
  final String subtitle;
  final String hint;
  final TextEditingController controller;
  final bool loading;
  final List<FollowupQaTurn> history;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black87.withValues(alpha: 0.6),
          ),
        ),
        if (history.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (var i = history.length - 1; i >= 0; i--) ...[
            if (i < history.length - 1) const Divider(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.followupQuestion(history[i].question),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                AiBodyText(
                  history[i].answer,
                  style: TextStyle(
                    color: Colors.black87.withValues(alpha: 0.85),
                    height: 1.4,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
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
                  child: Text(l10n.followupAsk),
                ),
        ),
      ],
    );
  }
}

class FollowupNotesPanel extends StatelessWidget {
  const FollowupNotesPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.controller,
    required this.submitting,
    required this.notes,
    required this.onSubmit,
    required this.onDelete,
    this.deletingNoteId,
  });

  final String title;
  final String subtitle;
  final String hint;
  final TextEditingController controller;
  final bool submitting;
  final List<FollowupNote> notes;
  final VoidCallback onSubmit;
  final ValueChanged<FollowupNote> onDelete;
  final String? deletingNoteId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat.yMMMd(locale).add_jm();
    final sorted = [...notes]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black87.withValues(alpha: 0.6),
          ),
        ),
        if (sorted.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (var i = 0; i < sorted.length; i++) ...[
            if (i > 0) const Divider(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        dateFormat.format(sorted[i].createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    if (deletingNoteId != null &&
                        deletingNoteId == sorted[i].id)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      IconButton(
                        tooltip: l10n.followupDeleteNote,
                        onPressed: submitting ? null : () => onDelete(sorted[i]),
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.black87.withValues(alpha: 0.45),
                        ),
                      ),
                  ],
                ),
                Text(
                  sorted[i].text,
                  style: TextStyle(
                    color: Colors.black87.withValues(alpha: 0.9),
                    height: 1.4,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          minLines: 2,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
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
                : Text(l10n.followupSaveNote),
          ),
        ),
      ],
    );
  }
}
