import 'package:flutter/material.dart';

import '../../../../core/models/career.dart';
import '../../../../core/theme/brand_colors.dart';

typedef CareerChecklistToggle = void Function({
  required String stepId,
  required bool isSkill,
  required int itemIndex,
  required bool done,
});

class CareerPathCard extends StatelessWidget {
  const CareerPathCard({
    super.key,
    required this.index,
    required this.onRegenerate,
    this.path,
    this.regenerating = false,
    this.onToggleChecklist,
  });

  final CareerPath? path;
  final int index;
  final VoidCallback onRegenerate;
  final bool regenerating;
  final CareerChecklistToggle? onToggleChecklist;

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
                  'Path ${index + 1}: ${path.title}',
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
                  label: const Text('Regenerate'),
                  style: TextButton.styleFrom(foregroundColor: kBrandGreen),
                ),
            ],
          ),
          if (path.summary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
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
        ],
      ),
    );
  }

  List<Widget> _buildTimeline(List<CareerPathStep> steps) {
    final widgets = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      widgets.add(
        _CareerStepNode(
          step: steps[i],
          onToggleChecklist: onToggleChecklist,
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
                  'Path ${index + 1}',
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
                  label: const Text('Generate'),
                  style: TextButton.styleFrom(foregroundColor: kBrandGreen),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'A career pathway will appear here once generated.',
            style: TextStyle(fontSize: 14, color: muted, height: 1.4),
          ),
          const SizedBox(height: 16),
          const _PlaceholderStep(
            title: 'Starting point',
            body: 'Your current experience and background.',
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
          const _PlaceholderStep(
            title: 'Build credentials',
            body: 'Licenses, training, and skills to develop.',
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
          const _PlaceholderStep(
            title: 'Target role',
            body: 'Your future career goal in the US.',
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
    this.onToggleChecklist,
  });

  final CareerPathStep step;
  final CareerChecklistToggle? onToggleChecklist;

  @override
  Widget build(BuildContext context) {
    final isCurrent = step.isCurrent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent
            ? kBrandGreen.withValues(alpha: 0.08)
            : kBrandPageBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? kBrandGreen.withValues(alpha: 0.35)
              : kBrandGreen.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: kBrandGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Current',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          if (step.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
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
              'Certifications & licenses',
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
              'Skills to develop',
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
          Row(
            children: [
              Icon(
                Icons.hourglass_empty,
                size: 16,
                color: kBrandGreen.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  step.timeEstimate.isNotEmpty
                      ? step.timeEstimate
                      : 'Time estimate pending',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87.withValues(
                      alpha: step.timeEstimate.isNotEmpty ? 0.75 : 0.45,
                    ),
                  ),
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
