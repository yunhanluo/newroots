import 'package:flutter/material.dart';

import '../../../../core/models/career.dart';
import '../../../../core/theme/brand_colors.dart';

class CareerPathCard extends StatelessWidget {
  const CareerPathCard({
    super.key,
    required this.path,
    required this.index,
    required this.onRegenerate,
    this.regenerating = false,
  });

  final CareerPath path;
  final int index;
  final VoidCallback onRegenerate;
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
      widgets.add(_CareerStepNode(step: steps[i]));
      if (i < steps.length - 1) {
        widgets.add(const _TimelineArrow());
      }
    }
    return widgets;
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
  const _CareerStepNode({required this.step});

  final CareerPathStep step;

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
            const SizedBox(height: 4),
            ...step.certifications.map(
              (cert) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(color: Colors.black87.withValues(alpha: 0.7)),
                    ),
                    Expanded(
                      child: Text(
                        cert,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
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
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: step.skills
                  .map(
                    (skill) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: kBrandGreen.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
