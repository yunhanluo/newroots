import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/support_group.dart';
import '../../../core/services/support_group_service.dart';
import '../../../core/widgets/brand_scaffold.dart';

/// Form for proposing a new mutual support group. An admin must approve it.
class SuggestGroupScreen extends ConsumerStatefulWidget {
  const SuggestGroupScreen({super.key});

  @override
  ConsumerState<SuggestGroupScreen> createState() => _SuggestGroupScreenState();
}

class _SuggestGroupScreenState extends ConsumerState<SuggestGroupScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  SupportGroupCategory _category = SupportGroupCategory.culture;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(supportGroupServiceProvider).suggestGroup(
            title: _titleController.text,
            description: _descriptionController.text,
            category: _category,
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).maybePop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Suggestion sent. An admin will review it before the group appears.',
          ),
        ),
      );
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not send that suggestion. Try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BrandScaffold(
      title: 'Suggest a group',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          Text(
            'Propose a group for other newcomers in California. An admin reviews every '
            'suggestion before it is opened for people to join.',
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Colors.black87.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 80,
            decoration: const InputDecoration(
              labelText: 'Group name',
              hintText: 'e.g. Newcomers in Fresno',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Category',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SupportGroupCategory>(
                value: _category,
                isExpanded: true,
                items: [
                  for (final category in SupportGroupCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _category = value);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 600,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'What is this group for?',
              hintText:
                  'Who should join, and what will people talk about?',
              filled: true,
              fillColor: Colors.white,
              alignLabelWithHint: true,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Submit for review'),
          ),
        ],
      ),
    );
  }
}
