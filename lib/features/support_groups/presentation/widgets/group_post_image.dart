import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/support_group_service.dart';
import '../../../../core/theme/brand_colors.dart';

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
      return GroupPostImage(imagePath: paths.first, height: widget.height);
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
              return GroupPostImage(
                imagePath: paths[index],
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

/// Loads a support-group post image from Firebase Storage.
class GroupPostImage extends ConsumerWidget {
  const GroupPostImage({
    super.key,
    required this.imagePath,
    this.height,
    this.borderRadius = 12,
  });

  final String imagePath;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (imagePath.isEmpty) return const SizedBox.shrink();
    final async = ref.watch(groupPostImageProvider(imagePath));
    return async.when(
      loading: () => _Frame(
        height: height ?? 180,
        borderRadius: borderRadius,
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (bytes) {
        if (bytes == null || bytes.isEmpty) return const SizedBox.shrink();
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            width: double.infinity,
            height: height,
            child: Image.memory(
              bytes,
              fit: height == null ? BoxFit.fitWidth : BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
        );
      },
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({
    required this.height,
    required this.borderRadius,
    required this.child,
  });

  final double height;
  final double borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        width: double.infinity,
        color: kBrandGreen.withValues(alpha: 0.08),
        child: child,
      ),
    );
  }
}
