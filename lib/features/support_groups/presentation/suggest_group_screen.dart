import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/support_group.dart';
import '../../../core/services/support_group_service.dart';
import '../../../core/widgets/brand_scaffold.dart';
import '../../../l10n/app_localizations.dart';

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

  String _categoryLabel(AppLocalizations l10n, SupportGroupCategory category) {
    return switch (category) {
      SupportGroupCategory.parents => l10n.groupsCategoryParents,
      SupportGroupCategory.jobs => l10n.groupsCategoryJobs,
      SupportGroupCategory.language => l10n.groupsCategoryLanguage,
      SupportGroupCategory.networking => l10n.groupsCategoryCareers,
      SupportGroupCategory.culture => l10n.groupsCategoryCulture,
      SupportGroupCategory.housing => l10n.groupsCategoryHousing,
      SupportGroupCategory.other => l10n.groupsCategoryOther,
    };
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final l10n = AppLocalizations.of(context);
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = l10n.groupsSuggestNameRequired);
      return;
    }
    if (description.isEmpty) {
      setState(() => _error = l10n.groupsSuggestDescriptionRequired);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(supportGroupServiceProvider).suggestGroup(
            title: title,
            description: description,
            category: _category,
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).maybePop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.groupsSuggestSent)),
      );
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.groupsSuggestSendError);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BrandScaffold(
      title: l10n.groupsSuggestTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          Text(
            l10n.groupsSuggestIntro,
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
            decoration: InputDecoration(
              labelText: l10n.groupsSuggestNameLabel,
              hintText: l10n.groupsSuggestNameHint,
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.groupsSuggestCategory,
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SupportGroupCategory>(
                value: _category,
                isExpanded: true,
                items: [
                  for (final category in SupportGroupCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(_categoryLabel(l10n, category)),
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
            decoration: InputDecoration(
              labelText: l10n.groupsSuggestPurposeLabel,
              hintText: l10n.groupsSuggestPurposeHint,
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
                : Text(l10n.groupsSuggestSubmit),
          ),
        ],
      ),
    );
  }
}
