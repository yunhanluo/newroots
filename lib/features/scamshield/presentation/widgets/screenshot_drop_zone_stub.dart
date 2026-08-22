import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Non-web: drag-and-drop is unavailable; just renders [child].
class ScreenshotDropZone extends StatelessWidget {
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
  Widget build(BuildContext context) => child;
}
