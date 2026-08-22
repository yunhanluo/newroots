import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Web: listens for file drops over this widget's bounds.
class ScreenshotDropZone extends StatefulWidget {
  const ScreenshotDropZone({
    super.key,
    required this.child,
    required this.enabled,
    required this.onImageDropped,
  });

  final Widget child;
  final bool enabled;
  final void Function(
    Uint8List bytes,
    String name,
    String contentType,
    String extension,
  ) onImageDropped;

  @override
  State<ScreenshotDropZone> createState() => _ScreenshotDropZoneState();
}

class _ScreenshotDropZoneState extends State<ScreenshotDropZone> {
  final _key = GlobalKey();
  StreamSubscription<html.MouseEvent>? _dragOverSub;
  StreamSubscription<html.MouseEvent>? _dragLeaveSub;
  StreamSubscription<html.MouseEvent>? _dropSub;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _dragOverSub = html.document.onDragOver.listen(_onDragOver);
    _dragLeaveSub = html.document.onDragLeave.listen(_onDragLeave);
    _dropSub = html.document.onDrop.listen(_onDrop);
  }

  @override
  void dispose() {
    _dragOverSub?.cancel();
    _dragLeaveSub?.cancel();
    _dropSub?.cancel();
    super.dispose();
  }

  bool _isPointerOver(num clientX, num clientY) {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return false;
    final origin = box.localToGlobal(Offset.zero);
    final rect = origin & box.size;
    return rect.contains(Offset(clientX.toDouble(), clientY.toDouble()));
  }

  void _onDragOver(html.MouseEvent event) {
    if (!widget.enabled) return;
    if (!_isPointerOver(event.client.x, event.client.y)) {
      if (_dragging) setState(() => _dragging = false);
      return;
    }
    event.preventDefault();
    event.stopPropagation();
    if (!_dragging) setState(() => _dragging = true);
  }

  void _onDragLeave(html.MouseEvent event) {
    if (!_dragging) return;
    if (_isPointerOver(event.client.x, event.client.y)) return;
    setState(() => _dragging = false);
  }

  Future<void> _onDrop(html.MouseEvent event) async {
    if (!widget.enabled) return;
    if (!_isPointerOver(event.client.x, event.client.y)) return;
    event.preventDefault();
    event.stopPropagation();
    setState(() => _dragging = false);

    final transfer = event.dataTransfer;
    final files = transfer.files;
    if (files == null || files.isEmpty) return;

    html.File? imageFile;
    for (final file in files) {
      final type = file.type;
      final name = file.name.toLowerCase();
      final isImage = type.startsWith('image/') ||
          name.endsWith('.png') ||
          name.endsWith('.jpg') ||
          name.endsWith('.jpeg') ||
          name.endsWith('.webp') ||
          name.endsWith('.gif');
      if (isImage) {
        imageFile = file;
        break;
      }
    }
    if (imageFile == null) return;

    final bytes = await _readFileBytes(imageFile);
    if (bytes == null || !mounted) return;

    final name = imageFile.name;
    final lower = name.toLowerCase();
    var ext = 'jpg';
    var contentType =
        imageFile.type.isNotEmpty ? imageFile.type : 'image/jpeg';
    if (lower.endsWith('.png') || contentType.contains('png')) {
      ext = 'png';
      contentType = 'image/png';
    } else if (lower.endsWith('.webp') || contentType.contains('webp')) {
      ext = 'webp';
      contentType = 'image/webp';
    } else if (lower.endsWith('.gif') || contentType.contains('gif')) {
      ext = 'gif';
      contentType = 'image/gif';
    }

    widget.onImageDropped(bytes, name, contentType, ext);
  }

  Future<Uint8List?> _readFileBytes(html.File file) {
    final completer = Completer<Uint8List?>();
    final reader = html.FileReader();
    reader.onLoad.listen((_) {
      final result = reader.result;
      if (result is ByteBuffer) {
        completer.complete(Uint8List.view(result));
      } else if (result is Uint8List) {
        completer.complete(result);
      } else {
        completer.complete(null);
      }
    });
    reader.onError.listen((_) => completer.complete(null));
    reader.readAsArrayBuffer(file);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: _dragging
              ? Border.all(color: const Color(0xFF1B6B5A), width: 2)
              : null,
          color: _dragging
              ? const Color(0xFF1B6B5A).withValues(alpha: 0.06)
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}
