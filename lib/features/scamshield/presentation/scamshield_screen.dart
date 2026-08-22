import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/scam_report.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/scam_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_scaffold.dart';
import 'widgets/screenshot_drop_zone.dart';

/// Feature 9: ScamShield — AI-powered fraud prevention.
class ScamShieldScreen extends ConsumerStatefulWidget {
  const ScamShieldScreen({super.key});

  @override
  ConsumerState<ScamShieldScreen> createState() => _ScamShieldScreenState();
}

class _ScamShieldScreenState extends ConsumerState<ScamShieldScreen> {
  final _textController = TextEditingController();
  final _picker = ImagePicker();

  ScamCategory _category = ScamCategory.sms;
  Uint8List? _imageBytes;
  String? _imageName;
  String? _imageContentType;
  String? _imageExt;
  bool _analyzing = false;
  String? _error;
  ScamReport? _report;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      _applyScreenshot(bytes: bytes, name: file.name);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Could not open that image. Try another photo.');
    }
  }

  void _applyScreenshot({
    required Uint8List bytes,
    required String name,
    String? contentType,
    String? extension,
  }) {
    final lower = name.toLowerCase();
    var ext = extension ?? 'jpg';
    var type = contentType ?? 'image/jpeg';
    if (extension == null || contentType == null) {
      if (lower.endsWith('.png')) {
        ext = 'png';
        type = 'image/png';
      } else if (lower.endsWith('.webp')) {
        ext = 'webp';
        type = 'image/webp';
      } else if (lower.endsWith('.gif')) {
        ext = 'gif';
        type = 'image/gif';
      }
    }
    setState(() {
      _imageBytes = bytes;
      _imageName = name;
      _imageContentType = type;
      _imageExt = ext;
      _error = null;
      // Keep an open past report visible unless starting a brand-new check
      // via Analyze; clearing happens in _analyze().
    });
  }

  void _clearImage() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
      _imageContentType = null;
      _imageExt = null;
    });
  }

  Future<void> _togglePastReport(ScamReport report) async {
    if (_report?.id == report.id) {
      setState(() {
        _report = null;
        _error = null;
      });
      return;
    }

    setState(() {
      _report = report;
      _error = null;
    });
  }

  Future<void> _deletePastReport(ScamReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => SelectionArea(
        child: AlertDialog(
          title: const Text('Delete this check?'),
          content: const Text(
            'This removes the saved report from your past checks.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(scamServiceProvider).deleteReport(report);
      if (!mounted) return;
      setState(() {
        if (_report?.id == report.id) {
          _report = null;
        }
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not delete that check. Try again.');
    }
  }

  Future<void> _analyze() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _imageBytes == null) {
      setState(() {
        _error = 'Paste a message or add a screenshot to analyze.';
      });
      return;
    }

    setState(() {
      _analyzing = true;
      _error = null;
      _report = null;
    });

    try {
      String? contentRef;
      if (_imageBytes != null) {
        contentRef = await ref
            .read(scamServiceProvider)
            .uploadScreenshot(
              bytes: _imageBytes!,
              contentType: _imageContentType ?? 'image/jpeg',
              extension: _imageExt ?? 'jpg',
            );
      }

      final profile = ref.read(userProfileProvider).value;
      final language = profile?.languageCode.trim().isNotEmpty == true
          ? profile!.languageCode
          : 'en';

      final report = await ref
          .read(aiServiceProvider)
          .analyzeScam(
            text: text.isEmpty ? null : text,
            contentRef: contentRef,
            category: _category,
            language: language,
          );

      final now = DateTime.now();
      final firstMessage = ScamThreadMessage(
        text: text,
        contentRef: contentRef,
        createdAt: now,
      );
      final saved = await ref
          .read(scamServiceProvider)
          .saveReport(
            report.copyWith(
              inputText: text,
              contentRef: contentRef ?? report.contentRef,
              category: _category,
              messages: [firstMessage],
              createdAt: now,
              clearPreviousRiskLevel: true,
            ),
          );

      if (!mounted) return;
      setState(() {
        _report = saved;
        _textController.clear();
        _imageBytes = null;
        _imageName = null;
        _imageContentType = null;
        _imageExt = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = describeAiServiceError(error));
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  Future<ScamReport> _continueReport({
    required ScamReport existing,
    required String text,
    Uint8List? imageBytes,
    String? imageName,
    String? imageContentType,
    String? imageExt,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && imageBytes == null) {
      throw StateError('Add a follow-up message or screenshot.');
    }

    String? contentRef;
    if (imageBytes != null) {
      contentRef = await ref
          .read(scamServiceProvider)
          .uploadScreenshot(
            bytes: imageBytes,
            contentType: imageContentType ?? 'image/jpeg',
            extension: imageExt ?? 'jpg',
          );
    }

    final profile = ref.read(userProfileProvider).value;
    final language = profile?.languageCode.trim().isNotEmpty == true
        ? profile!.languageCode
        : 'en';

    final priorThread = existing.threadDisplayText;
    final analysis = await ref
        .read(aiServiceProvider)
        .analyzeScam(
          text: trimmed.isEmpty ? null : trimmed,
          contentRef: contentRef,
          category: existing.category,
          language: language,
          priorThread: priorThread,
          priorRiskLevel: existing.riskLevel,
          reportId: existing.id,
        );

    final followUp = ScamThreadMessage(
      text: trimmed,
      contentRef: contentRef,
      createdAt: DateTime.now(),
    );
    final messages = [...existing.thread, followUp];
    final flatText = messages
        .map((m) => m.text.trim())
        .where((t) => t.isNotEmpty)
        .join('\n\n');

    final saved = await ref
        .read(scamServiceProvider)
        .saveReport(
          analysis.copyWith(
            id: existing.id,
            category: existing.category,
            inputText: flatText,
            messages: messages,
            contentRef: existing.contentRef ?? contentRef,
            previousRiskLevel: existing.riskLevel,
            createdAt: existing.createdAt ?? DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

    if (mounted) {
      setState(() {
        _report = saved;
        _error = null;
      });
    }
    return saved;
  }

  Future<void> _showImageSourceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SelectionArea(
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: BrandScaffold(
        title: 'ScamShield',
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              'Check suspicious messages, emails, job offers, rental ads, and '
              'government-related content. ScamShield explains why something '
              'may be risky so you can decide what to do next.',
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black87.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'What are you checking?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ScamCategory.values.map((category) {
                final selected = _category == category;
                return ChoiceChip(
                  label: Text(category.label),
                  selected: selected,
                  onSelected: _analyzing
                      ? null
                      : (_) => setState(() {
                          _category = category;
                          _report = null;
                        }),
                  selectedColor: kBrandGreen.withValues(alpha: 0.18),
                  labelStyle: TextStyle(
                    color: selected ? kBrandGreen : Colors.black87,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: selected
                        ? kBrandGreen
                        : kBrandGreen.withValues(alpha: 0.25),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textController,
              minLines: 5,
              maxLines: 10,
              enabled: !_analyzing,
              onChanged: (_) {
                if (_report != null || _error != null) {
                  setState(() {
                    _report = null;
                    _error = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Paste the message or listing',
                hintText: 'Paste the full text here…',
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_imageBytes == null)
              ScreenshotDropZone(
                enabled: !_analyzing,
                onImageDropped: (bytes, name, contentType, extension) {
                  if (_analyzing) return;
                  _applyScreenshot(
                    bytes: bytes,
                    name: name,
                    contentType: contentType,
                    extension: extension,
                  );
                },
                child: kIsWeb
                    ? _WebScreenshotDropButton(
                        enabled: !_analyzing,
                        onBrowse: () => _pickImage(ImageSource.gallery),
                      )
                    : OutlinedButton.icon(
                        onPressed: _analyzing ? null : _showImageSourceSheet,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('Add screenshot'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kBrandGreen,
                          side: BorderSide(
                            color: kBrandGreen.withValues(alpha: 0.45),
                          ),
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
              )
            else
              _ScreenshotPreview(
                bytes: _imageBytes!,
                name: _imageName ?? 'Screenshot',
                onClear: _analyzing ? null : _clearImage,
                onReplace: _analyzing
                    ? null
                    : () => kIsWeb
                          ? _pickImage(ImageSource.gallery)
                          : _showImageSourceSheet(),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _analyzing ? null : _analyze,
              style: FilledButton.styleFrom(backgroundColor: kBrandGreen),
              child: _analyzing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Analyze for scam risk'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
            if (_report != null) ...[
              const SizedBox(height: 20),
              _RiskResultCard(
                key: ValueKey(_report!.id),
                report: _report!,
                onContinue:
                    ({
                      required String text,
                      Uint8List? imageBytes,
                      String? imageName,
                      String? imageContentType,
                      String? imageExt,
                    }) {
                      return _continueReport(
                        existing: _report!,
                        text: text,
                        imageBytes: imageBytes,
                        imageName: imageName,
                        imageContentType: imageContentType,
                        imageExt: imageExt,
                      );
                    },
              ),
            ],
            const SizedBox(height: 28),
            Text(
              'Past checks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _PastChecksList(
              selectedId: _report?.id,
              onSelect: (report) => _togglePastReport(report),
              onDelete: (report) => _deletePastReport(report),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebScreenshotDropButton extends StatelessWidget {
  const _WebScreenshotDropButton({
    required this.enabled,
    required this.onBrowse,
  });

  final bool enabled;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onBrowse : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: kBrandGreen.withValues(alpha: 0.35),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 28,
                color: enabled
                    ? kBrandGreen
                    : Colors.black87.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 10),
              Text(
                'Drag and drop a screenshot here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? Colors.black87
                      : Colors.black87.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'or click to browse',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: enabled
                      ? kBrandGreen
                      : Colors.black87.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScreenshotPreview extends StatelessWidget {
  const _ScreenshotPreview({
    required this.bytes,
    required this.name,
    required this.onClear,
    required this.onReplace,
  });

  final Uint8List bytes;
  final String name;
  final VoidCallback? onClear;
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBrandGreen.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(bytes, height: 180, fit: BoxFit.cover),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(onPressed: onReplace, child: const Text('Replace')),
              TextButton(onPressed: onClear, child: const Text('Remove')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PastChecksList extends ConsumerWidget {
  const _PastChecksList({
    required this.selectedId,
    required this.onSelect,
    required this.onDelete,
  });

  final String? selectedId;
  final ValueChanged<ScamReport> onSelect;
  final ValueChanged<ScamReport> onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncReports = ref.watch(recentScamReportsProvider);

    return asyncReports.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => Text(
        'Could not load past checks right now.',
        style: TextStyle(
          fontSize: 14,
          color: Colors.black87.withValues(alpha: 0.6),
        ),
      ),
      data: (reports) {
        if (reports.isEmpty) {
          return Text(
            'No past checks yet. Analyze a message to save one here.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black87.withValues(alpha: 0.6),
            ),
          );
        }
        return Column(
          children: [
            for (final report in reports)
              _PastCheckTile(
                report: report,
                selected: report.id == selectedId,
                onTap: () => onSelect(report),
                onDelete: () => onDelete(report),
              ),
          ],
        );
      },
    );
  }
}

class _PastCheckTile extends StatelessWidget {
  const _PastCheckTile({
    required this.report,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  final ScamReport report;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final accent = _riskAccent(report.riskLevel);
    final when = report.createdAt;
    final whenLabel = when == null ? '' : _formatRelativeDate(when);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 4, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? accent.withValues(alpha: 0.55)
                    : kBrandGreen.withValues(alpha: 0.18),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _riskLabel(report.riskLevel),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              report.category.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          if (whenLabel.isNotEmpty)
                            Text(
                              whenLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87.withValues(alpha: 0.5),
                              ),
                            ),
                        ],
                      ),
                      if (report.summary.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          report.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: Colors.black87.withValues(alpha: 0.8),
                          ),
                        ),
                      ] else if (report.inputText.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          report.inputText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: Colors.black87.withValues(alpha: 0.8),
                          ),
                        ),
                      ] else if (report.hasScreenshot) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Screenshot check',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.black87.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _riskAccent(RiskLevel level) {
  switch (level) {
    case RiskLevel.low:
      return const Color(0xFF2E7D32);
    case RiskLevel.moderate:
      return const Color(0xFFEF6C00);
    case RiskLevel.high:
      return const Color(0xFFC62828);
  }
}

String _riskLabel(RiskLevel level) {
  switch (level) {
    case RiskLevel.low:
      return 'Low Risk';
    case RiskLevel.moderate:
      return 'Moderate Risk';
    case RiskLevel.high:
      return 'High Risk';
  }
}

String _formatRelativeDate(DateTime when) {
  final local = when.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final diffDays = today.difference(day).inDays;
  if (diffDays == 0) {
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }
  if (diffDays == 1) return 'Yesterday';
  if (diffDays < 7) return '$diffDays days ago';
  return '${local.month}/${local.day}/${local.year}';
}

class _RiskResultCard extends StatefulWidget {
  const _RiskResultCard({
    super.key,
    required this.report,
    required this.onContinue,
  });

  final ScamReport report;
  final Future<ScamReport> Function({
    required String text,
    Uint8List? imageBytes,
    String? imageName,
    String? imageContentType,
    String? imageExt,
  })
  onContinue;

  @override
  State<_RiskResultCard> createState() => _RiskResultCardState();
}

class _RiskResultCardState extends State<_RiskResultCard> {
  final _followUpController = TextEditingController();
  final _picker = ImagePicker();
  bool _submittedCollapsed = true;
  bool _addingMessage = false;
  bool _reevaluating = false;
  Uint8List? _followUpBytes;
  String? _followUpName;
  String? _followUpContentType;
  String? _followUpExt;
  String? _followUpError;

  ScamReport get report => widget.report;

  Color get _accent => _riskAccent(report.riskLevel);

  String get _label => _riskLabel(report.riskLevel);

  IconData get _icon {
    switch (report.riskLevel) {
      case RiskLevel.low:
        return Icons.verified_user_outlined;
      case RiskLevel.moderate:
        return Icons.warning_amber_rounded;
      case RiskLevel.high:
        return Icons.gpp_bad_outlined;
    }
  }

  String get _submittedPreview {
    final thread = report.thread;
    if (thread.length > 1) {
      return '${thread.length} messages in this thread';
    }
    final text = report.threadDisplayText.trim();
    if (text.isNotEmpty && report.hasScreenshot) {
      return '$text  ·  Screenshot attached';
    }
    if (text.isNotEmpty) return text;
    if (report.hasScreenshot) return 'Screenshot attached';
    return '';
  }

  @override
  void dispose() {
    _followUpController.dispose();
    super.dispose();
  }

  Future<void> _pickFollowUpImage() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final name = file.name;
      final lower = name.toLowerCase();
      var ext = 'jpg';
      var contentType = 'image/jpeg';
      if (lower.endsWith('.png')) {
        ext = 'png';
        contentType = 'image/png';
      } else if (lower.endsWith('.webp')) {
        ext = 'webp';
        contentType = 'image/webp';
      }
      if (!mounted) return;
      setState(() {
        _followUpBytes = bytes;
        _followUpName = name;
        _followUpContentType = contentType;
        _followUpExt = ext;
        _followUpError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _followUpError = 'Could not open that image.');
    }
  }

  Future<void> _submitFollowUp() async {
    final text = _followUpController.text.trim();
    if (text.isEmpty && _followUpBytes == null) {
      setState(() {
        _followUpError = 'Paste a follow-up message or add a screenshot.';
      });
      return;
    }

    setState(() {
      _reevaluating = true;
      _followUpError = null;
    });

    try {
      await widget.onContinue(
        text: text,
        imageBytes: _followUpBytes,
        imageName: _followUpName,
        imageContentType: _followUpContentType,
        imageExt: _followUpExt,
      );
      if (!mounted) return;
      setState(() {
        _addingMessage = false;
        _followUpController.clear();
        _followUpBytes = null;
        _followUpName = null;
        _followUpContentType = null;
        _followUpExt = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _followUpError = describeAiServiceError(error));
    } finally {
      if (mounted) setState(() => _reevaluating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final thread = report.thread;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, color: _accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),
          if (report.riskChanged) ...[
            const SizedBox(height: 8),
            Text(
              'Updated from ${_riskLabel(report.previousRiskLevel!)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87.withValues(alpha: 0.65),
              ),
            ),
          ],
          if (report.summary.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              report.summary,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ],
          if (thread.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: kBrandPageBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBrandGreen.withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 2, 2, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'What you submitted',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          tooltip: _submittedCollapsed ? 'Expand' : 'Collapse',
                          onPressed: () => setState(
                            () => _submittedCollapsed = !_submittedCollapsed,
                          ),
                          icon: Icon(
                            _submittedCollapsed
                                ? Icons.expand_more
                                : Icons.expand_less,
                            color: Colors.black87.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_submittedCollapsed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Text(
                        _submittedPreview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          color: Colors.black87.withValues(alpha: 0.65),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < thread.length; i++) ...[
                            if (i > 0) const SizedBox(height: 12),
                            Text(
                              thread.length == 1
                                  ? 'Message'
                                  : 'Message ${i + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87.withValues(alpha: 0.55),
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (thread[i].text.trim().isNotEmpty)
                              Text(
                                thread[i].text,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: Colors.black87.withValues(alpha: 0.85),
                                ),
                              ),
                            if (thread[i].hasScreenshot) ...[
                              if (thread[i].text.trim().isNotEmpty)
                                const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 18,
                                    color: Colors.black87.withValues(
                                      alpha: 0.55,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Included a screenshot',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87.withValues(
                                        alpha: 0.65,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (report.reasons.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Why this may be risky',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...report.reasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 6, color: _accent),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reason,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.black87.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (report.recommendedActions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'What you can do',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...report.recommendedActions.map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, size: 18, color: _accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        action,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.black87.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (!_addingMessage)
            OutlinedButton.icon(
              onPressed: _reevaluating
                  ? null
                  : () => setState(() {
                      _addingMessage = true;
                      _followUpError = null;
                    }),
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('Add message'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kBrandGreen,
                side: BorderSide(color: kBrandGreen.withValues(alpha: 0.45)),
              ),
            )
          else ...[
            Text(
              'Add a follow-up from the conversation',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _followUpController,
              minLines: 3,
              maxLines: 6,
              enabled: !_reevaluating,
              decoration: InputDecoration(
                hintText: 'Paste the next text or email…',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_followUpBytes == null)
              TextButton.icon(
                onPressed: _reevaluating ? null : _pickFollowUpImage,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Add screenshot'),
              )
            else
              Row(
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 18,
                    color: Colors.black87.withValues(alpha: 0.55),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _followUpName ?? 'Screenshot',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _reevaluating
                        ? null
                        : () => setState(() {
                            _followUpBytes = null;
                            _followUpName = null;
                          }),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            if (_followUpError != null) ...[
              const SizedBox(height: 6),
              Text(
                _followUpError!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton(
                  onPressed: _reevaluating ? null : _submitFollowUp,
                  style: FilledButton.styleFrom(
                    backgroundColor: kBrandGreen,
                    minimumSize: const Size(0, 48),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: _reevaluating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Reevaluate'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _reevaluating
                      ? null
                      : () => setState(() {
                          _addingMessage = false;
                          _followUpError = null;
                          _followUpController.clear();
                          _followUpBytes = null;
                        }),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
