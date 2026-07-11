import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/career.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/career_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_scaffold.dart';
import 'widgets/career_path_card.dart';

/// AI-powered career pathway mapping from prior experience to US roles.
class CareerScreen extends ConsumerStatefulWidget {
  const CareerScreen({super.key});

  @override
  ConsumerState<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends ConsumerState<CareerScreen> {
  final _notesController = TextEditingController();
  bool _generatingAll = false;
  int? _regeneratingPathIndex;
  bool _notesSynced = false;
  String? _error;

  @override
  void dispose() {
    _notesController.dispose();
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

    final hasPaths = !career.isEmpty;
    final hasPriorJob = profile?.employmentBackground.isNotEmpty ?? false;
    final canGenerate = profile != null &&
        (hasPriorJob || _notesController.text.trim().isNotEmpty);

    return BrandScaffold(
      title: 'Career Bridge',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (profile == null) ...[
              const _InfoCard(
                icon: Icons.person_outline,
                message: 'Sign in to explore career pathways.',
              ),
            ] else ...[
              if (hasPriorJob) ...[
                _PriorJobCard(background: profile.employmentBackground),
                const SizedBox(height: 16),
              ] else ...[
                _InfoCard(
                  icon: Icons.info_outline,
                  message:
                      'Add your prior job in your profile survey, or describe your background in the notes below.',
                  actionLabel: 'Go to profile',
                  onAction: () => context.pushNamed(Routes.profile),
                ),
                const SizedBox(height: 16),
              ],
              _NotesInputCard(
                controller: _notesController,
                enabled: !_generatingAll && _regeneratingPathIndex == null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              if (_generatingAll) ...[
                const _GeneratingCard(),
              ] else if (hasPaths) ...[
                Text(
                  'Possible career paths based on your background.',
                  style: TextStyle(
                    color: Colors.black87.withValues(alpha: 0.7),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                ...career.paths.asMap().entries.map(
                  (entry) => CareerPathCard(
                    path: entry.value,
                    index: entry.key,
                    regenerating: _regeneratingPathIndex == entry.key,
                    onRegenerate: () => _confirmRegeneratePath(
                      profile,
                      career,
                      entry.key,
                    ),
                  ),
                ),
              ] else ...[
                _EmptyStateCard(
                  canGenerate: canGenerate ||
                      _notesController.text.trim().isNotEmpty,
                  onGenerate: () => _generatePaths(profile),
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

  Future<void> _confirmRegeneratePath(
    UserProfileData profile,
    CareerBridgeData career,
    int pathIndex,
  ) async {
    final path = career.paths[pathIndex];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate this path?'),
        content: Text(
          'Replace "${path.title}" with a new AI-generated career path. '
          'Your other paths and notes are kept.',
        ),
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
      setState(() => _error = 'Add notes about your skills or education first.');
      return;
    }

    setState(() {
      _regeneratingPathIndex = pathIndex;
      _error = null;
    });

    try {
      await ref.read(careerServiceProvider).saveAdditionalNotes(notes);
      final path = await ref.read(aiServiceProvider).regenerateCareerPath(
            profile: profile,
            additionalNotes: notes,
            existingPaths: career.paths,
            pathIndex: pathIndex,
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
      setState(() => _error = 'Add notes about your skills or education first.');
      return;
    }

    setState(() {
      _generatingAll = true;
      _error = null;
    });

    try {
      await ref.read(careerServiceProvider).saveAdditionalNotes(notes);
      final paths = await ref.read(aiServiceProvider).generateCareerPaths(
            profile: profile,
            additionalNotes: notes,
          );
      if (paths.isEmpty) {
        throw StateError('No career paths returned.');
      }
      await ref.read(careerServiceProvider).saveCareer(
            CareerBridgeData(
              paths: paths,
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
            'Prior employment (from your survey)',
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
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Additional background',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Skills, education, certifications, languages, or career goals '
            'that will help the AI suggest better paths.',
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
              hintText:
                  'e.g. 5 years as an electrician, vocational diploma, '
                  'interested in solar installation…',
              filled: true,
              fillColor: kBrandPageBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.canGenerate,
    required this.onGenerate,
  });

  final bool canGenerate;
  final VoidCallback onGenerate;

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
          const Icon(Icons.work_outline, size: 48, color: kBrandGreen),
          const SizedBox(height: 16),
          Text(
            'No career paths yet. Add notes above, then generate pathways '
            'tailored to your experience.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87.withValues(alpha: 0.75),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: canGenerate ? onGenerate : null,
            style: FilledButton.styleFrom(backgroundColor: kBrandGreen),
            child: const Text('Generate career paths'),
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
      child: const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Mapping career pathways…',
            style: TextStyle(
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
