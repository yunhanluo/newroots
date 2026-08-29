import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/brand_colors.dart';

final storageDownloadUrlProvider =
    FutureProvider.family<String?, String>((ref, path) async {
  final clean = path.trim().replaceFirst(RegExp(r'^/+'), '');
  if (clean.isEmpty || clean.contains('..')) return null;
  try {
    return await FirebaseStorage.instance.ref(clean).getDownloadURL();
  } catch (_) {
    return null;
  }
});

/// Loads an image from a Firebase Storage path.
///
/// Uses a download URL plus an HTML `<img>` on web so Chrome can display the
/// photo even when the CanvasKit fetch path is blocked by Storage CORS.
class StorageImage extends ConsumerWidget {
  const StorageImage({
    super.key,
    required this.path,
    this.height,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  final String path;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (path.trim().isEmpty) return const SizedBox.shrink();
    final async = ref.watch(storageDownloadUrlProvider(path));
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
      error: (error, stackTrace) => _Broken(
        height: height ?? 180,
        borderRadius: borderRadius,
      ),
      data: (url) {
        if (url == null || url.isEmpty) {
          return _Broken(
            height: height ?? 180,
            borderRadius: borderRadius,
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.network(
            url,
            width: double.infinity,
            height: height,
            fit: height == null ? BoxFit.fitWidth : fit,
            webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _Frame(
                height: height ?? 180,
                borderRadius: borderRadius,
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => _Broken(
              height: height ?? 180,
              borderRadius: 0,
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

class _Broken extends StatelessWidget {
  const _Broken({required this.height, required this.borderRadius});

  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        width: double.infinity,
        color: kBrandGreen.withValues(alpha: 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              color: Colors.black87.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 6),
            Text(
              'Photo could not load',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
