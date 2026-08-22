import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/support_group.dart';
import '../../../core/services/support_group_service.dart';
import '../../../core/widgets/brand_scaffold.dart';

class _DraftPhoto {
  const _DraftPhoto({
    required this.bytes,
    required this.contentType,
    required this.extension,
  });

  final Uint8List bytes;
  final String contentType;
  final String extension;
}

/// Write a new post or question in a support group.
class GroupComposeScreen extends ConsumerStatefulWidget {
  const GroupComposeScreen({
    super.key,
    required this.groupId,
    this.initialKind = GroupPostKind.post,
  });

  final String groupId;
  final GroupPostKind initialKind;

  @override
  ConsumerState<GroupComposeScreen> createState() => _GroupComposeScreenState();
}

class _GroupComposeScreenState extends ConsumerState<GroupComposeScreen> {
  late GroupPostKind _kind = widget.initialKind;
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _picker = ImagePicker();
  final _photos = <_DraftPhoto>[];
  bool _submitting = false;
  String? _error;

  bool get _canAddMore => _photos.length < kMaxGroupPostImages;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  _DraftPhoto? _photoFromFile(XFile file, Uint8List bytes) {
    final lower = file.name.toLowerCase();
    var ext = 'jpg';
    var type = 'image/jpeg';
    if (lower.endsWith('.png')) {
      ext = 'png';
      type = 'image/png';
    } else if (lower.endsWith('.webp')) {
      ext = 'webp';
      type = 'image/webp';
    }
    return _DraftPhoto(bytes: bytes, contentType: type, extension: ext);
  }

  Future<void> _addPhotos() async {
    if (!_canAddMore) return;
    ImageSource source = ImageSource.gallery;
    if (!kIsWeb) {
      final chosen = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Photo library'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );
      if (chosen == null) return;
      source = chosen;
    }

    try {
      if (source == ImageSource.gallery) {
        final files = await _picker.pickMultiImage(
          maxWidth: 1600,
          maxHeight: 1600,
          imageQuality: 85,
          limit: kMaxGroupPostImages - _photos.length,
        );
        if (files.isEmpty) return;
        final next = <_DraftPhoto>[];
        for (final file in files) {
          if (_photos.length + next.length >= kMaxGroupPostImages) break;
          next.add(_photoFromFile(file, await file.readAsBytes())!);
        }
        if (!mounted) return;
        setState(() {
          _photos.addAll(next);
          _error = null;
        });
        return;
      }

      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final photo = _photoFromFile(file, await file.readAsBytes());
      if (!mounted || photo == null) return;
      setState(() {
        _photos.add(photo);
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not open that photo. Try another one.');
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(supportGroupServiceProvider).createPost(
            groupId: widget.groupId,
            title: _titleController.text,
            text: _bodyController.text,
            kind: _kind,
            images: [
              for (final photo in _photos)
                GroupPostImageUpload(
                  bytes: photo.bytes,
                  contentType: photo.contentType,
                  extension: photo.extension,
                ),
            ],
          );
      if (!mounted) return;
      Navigator.of(context).maybePop();
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not publish that. Try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isQuestion = _kind == GroupPostKind.question;
    return BrandScaffold(
      title: isQuestion ? 'Ask a question' : 'New post',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          Text(
            isQuestion
                ? 'Ask the group something they can help with. Other members can reply on this thread.'
                : 'Share an update, a tip, or something that might help others in this group.',
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Colors.black87.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<GroupPostKind>(
            segments: const [
              ButtonSegment(
                value: GroupPostKind.post,
                label: Text('Post'),
                icon: Icon(Icons.edit_outlined, size: 18),
              ),
              ButtonSegment(
                value: GroupPostKind.question,
                label: Text('Question'),
                icon: Icon(Icons.help_outline, size: 18),
              ),
            ],
            selected: {_kind},
            onSelectionChanged: (value) {
              setState(() => _kind = value.first);
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 120,
            decoration: InputDecoration(
              labelText: isQuestion ? 'Question' : 'Title',
              hintText: isQuestion
                  ? 'e.g. How did you find a pediatrician?'
                  : 'e.g. A resume tip that helped me',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 6,
            maxLines: 12,
            maxLength: 2000,
            decoration: InputDecoration(
              labelText: isQuestion ? 'Details (optional)' : 'Description',
              hintText: isQuestion
                  ? 'Add any details that would help people answer.'
                  : 'Add the story, a link, or anything useful.',
              alignLabelWithHint: true,
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (_photos.isNotEmpty) ...[
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length + (_canAddMore ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (index == _photos.length) {
                    return _AddPhotoTile(
                      onTap: _submitting ? null : _addPhotos,
                    );
                  }
                  return _PhotoThumb(
                    bytes: _photos[index].bytes,
                    onRemove: _submitting
                        ? null
                        : () => setState(() => _photos.removeAt(index)),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_photos.length} of $kMaxGroupPostImages photos',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87.withValues(alpha: 0.6),
              ),
            ),
          ] else
            OutlinedButton.icon(
              onPressed: _submitting ? null : _addPhotos,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Add photos'),
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
          const SizedBox(height: 16),
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
                : Text(isQuestion ? 'Post question' : 'Publish post'),
          ),
        ],
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.bytes, this.onRemove});

  final Uint8List bytes;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton.filled(
            onPressed: onRemove,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              foregroundColor: Colors.white,
              minimumSize: const Size(32, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(Icons.close, size: 16),
            tooltip: 'Remove photo',
          ),
        ),
      ],
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 120,
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.black87.withValues(alpha: 0.55)),
              const SizedBox(height: 4),
              Text(
                'Add',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
