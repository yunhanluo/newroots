import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/app_locale.dart';
import '../../../core/l10n/l10n_labels.dart';
import '../../../core/models/scam_report.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/scam_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_scaffold.dart';
import '../../../core/widgets/ai_body_text.dart';
import '../../../core/widgets/storage_image.dart';
import '../../../l10n/app_localizations.dart';
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

  String get _preferredLanguage =>
      ref.read(appLocaleProvider).languageCode;

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
      setState(() => _error = AppLocalizations.of(context).scamImageOpenError);
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
          title: Text(AppLocalizations.of(context).scamDeleteTitle),
          content: Text(AppLocalizations.of(context).scamDeleteBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context).actionCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(AppLocalizations.of(context).scamDelete),
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
      setState(() => _error = AppLocalizations.of(context).scamDeleteError);
    }
  }

  Future<void> _analyze() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _imageBytes == null) {
      setState(() {
        _error = AppLocalizations.of(context).scamNeedInput;
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

      final report = await ref
          .read(aiServiceProvider)
          .analyzeScam(
            text: text.isEmpty ? null : text,
            contentRef: contentRef,
            category: _category,
            language: _preferredLanguage,
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

    final priorThread = existing.threadDisplayText;
    final analysis = await ref
        .read(aiServiceProvider)
        .analyzeScam(
          text: trimmed.isEmpty ? null : trimmed,
          contentRef: contentRef,
          category: existing.category,
          language: _preferredLanguage,
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
                  title: Text(AppLocalizations.of(context).scamChooseGallery),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(AppLocalizations.of(context).scamTakePhoto),
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
    final l10n = AppLocalizations.of(context);
    return SelectionArea(
      child: BrandScaffold(
        title: l10n.featureScamShield,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              l10n.scamIntro,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black87.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.scamWhatChecking,
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
                  label: Text(localizedScamCategory(l10n, category)),
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
                labelText: l10n.scamPasteLabel,
                hintText: l10n.scamPasteHint,
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
                        label: Text(l10n.scamAddScreenshot),
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
                name: _imageName ?? l10n.scamScreenshot,
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
                  : Text(l10n.scamAnalyze),
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
              l10n.scamPastChecks,
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
                AppLocalizations.of(context).scamDropHint,
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
                AppLocalizations.of(context).scamBrowseHint,
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
              TextButton(
                onPressed: onReplace,
                child: Text(AppLocalizations.of(context).scamReplace),
              ),
              TextButton(
                onPressed: onClear,
                child: Text(AppLocalizations.of(context).scamRemove),
              ),
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
      error: (_, _) => Text(
        AppLocalizations.of(context).scamPastLoadError,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black87.withValues(alpha: 0.6),
        ),
      ),
      data: (reports) {
        if (reports.isEmpty) {
          return Text(
            AppLocalizations.of(context).scamPastEmpty,
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
    final l10n = AppLocalizations.of(context);
    final accent = _riskAccent(report.riskLevel);
    final when = report.createdAt;
    final whenLabel = when == null ? '' : formatScamRelativeDate(l10n, when);

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
                              localizedScamRisk(l10n, report.riskLevel),
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
                              localizedScamCategory(l10n, report.category),
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
                        AiBodyText(
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
                          l10n.scamScreenshotCheck,
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
                  tooltip: l10n.scamDelete,
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
  late bool _submittedCollapsed = !widget.report.hasScreenshot;
  bool _addingMessage = false;
  bool _reevaluating = false;
  Uint8List? _followUpBytes;
  String? _followUpName;
  String? _followUpContentType;
  String? _followUpExt;
  String? _followUpError;

  ScamReport get report => widget.report;

  Color get _accent => _riskAccent(report.riskLevel);

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

  String _submittedPreview(AppLocalizations l10n) {
    final thread = report.thread;
    if (thread.length > 1) {
      return l10n.scamThreadCount(thread.length);
    }
    final text = report.threadDisplayText.trim();
    if (text.isNotEmpty && report.hasScreenshot) {
      return '$text  ·  ${l10n.scamScreenshotAttached}';
    }
    if (text.isNotEmpty) return text;
    if (report.hasScreenshot) return l10n.scamScreenshotAttached;
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
      setState(() => _followUpError = AppLocalizations.of(context).scamFollowUpImageError);
    }
  }

  Future<void> _submitFollowUp() async {
    final text = _followUpController.text.trim();
    if (text.isEmpty && _followUpBytes == null) {
      setState(() {
        _followUpError = AppLocalizations.of(context).scamFollowUpNeedInput;
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
    final l10n = AppLocalizations.of(context);
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
                  localizedScamRisk(l10n, report.riskLevel),
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
              l10n.scamUpdatedFrom(localizedScamRisk(l10n, report.previousRiskLevel!)),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87.withValues(alpha: 0.65),
              ),
            ),
          ],
          if (report.summary.isNotEmpty) ...[
            const SizedBox(height: 12),
            AiBodyText(
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
                            l10n.scamWhatYouSubmitted,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          tooltip: _submittedCollapsed
                              ? l10n.scamExpand
                              : l10n.scamCollapse,
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
                        _submittedPreview(l10n),
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
                                  ? l10n.scamMessage
                                  : l10n.scamMessageNumber(i + 1),
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
                              StorageImage(
                                path: thread[i].contentRef!,
                                height: 180,
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
              l10n.scamWhyRisky,
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
                      child: AiBodyText(
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
              l10n.scamWhatYouCanDo,
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
                      child: AiBodyText(
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
              label: Text(l10n.scamAddMessage),
              style: OutlinedButton.styleFrom(
                foregroundColor: kBrandGreen,
                side: BorderSide(color: kBrandGreen.withValues(alpha: 0.45)),
              ),
            )
          else ...[
            Text(
              l10n.scamFollowUpTitle,
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
                hintText: l10n.scamFollowUpHint,
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
                label: Text(l10n.scamAddScreenshot),
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
                      _followUpName ?? l10n.scamScreenshot,
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
                    child: Text(l10n.scamRemove),
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
                      : Text(l10n.scamReevaluate),
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
                  child: Text(l10n.actionCancel),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
