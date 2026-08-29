import 'package:flutter/material.dart';

import '../../../../core/widgets/storage_image.dart';

/// One or more support-group post images from Firebase Storage.
class GroupPostImageGallery extends StatefulWidget {
  const GroupPostImageGallery({
    super.key,
    required this.imagePaths,
    this.height,
    this.interactive = true,
  });

  final List<String> imagePaths;
  final double? height;
  final bool interactive;

  @override
  State<GroupPostImageGallery> createState() => _GroupPostImageGalleryState();
}

class _GroupPostImageGalleryState extends State<GroupPostImageGallery> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final paths = widget.imagePaths.where((p) => p.isNotEmpty).toList();
    if (paths.isEmpty) return const SizedBox.shrink();
    if (paths.length == 1) {
      return StorageImage(path: paths.first, height: widget.height);
    }

    final height = widget.height ?? 240.0;
    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            physics: widget.interactive
                ? const PageScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: paths.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, index) {
              return StorageImage(
                path: paths[index],
                height: height,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_index + 1} / ${paths.length}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
