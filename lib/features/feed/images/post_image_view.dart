import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'image_pipeline.dart';

/// Renders a post image in the feed by:
///   1. asking the image pipeline for a signed URL for the storage path
///   2. handing the URL to CachedNetworkImage so subsequent scrolls
///      don't re-download the bytes
///
/// The signed URL has a 1-hour TTL by default; CachedNetworkImage
/// keys its cache on the URL string, so when the signature expires
/// and a new URL is issued the cache is refilled exactly once.
/// To survive cache eviction across app launches the underlying
/// disk cache (flutter_cache_manager) keeps the bytes around even
/// after the URL it was originally fetched under is stale.
class PostImageView extends ConsumerWidget {
  const PostImageView({
    super.key,
    required this.storagePath,
    this.aspectRatio = 9 / 16,
  });

  final String storagePath;
  final double aspectRatio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlAsync = ref.watch(_signedUrlProvider(storagePath));
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: urlAsync.when(
        loading: () => Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (e, _) => Container(
          color: Theme.of(context).colorScheme.errorContainer,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined),
        ),
        data: (url) => CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 120),
          placeholder: (ctx, _) => Container(
            color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
          ),
          errorWidget: (ctx, _, _) => Container(
            color: Theme.of(ctx).colorScheme.errorContainer,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image_outlined),
          ),
        ),
      ),
    );
  }
}

/// Caches the signed URL per storage path for ~50 minutes so we
/// don't re-sign on every rebuild. The actual underlying signature
/// is good for 60 minutes; we refresh slightly earlier to be safe.
final _signedUrlProvider =
    FutureProvider.autoDispose.family<String, String>((ref, path) async {
  final link = ref.keepAlive();
  // Let the link expire 50 minutes after creation so a future watch
  // re-signs the URL. autoDispose still kicks in if no widget is
  // watching this path.
  Future.delayed(const Duration(minutes: 50), link.close);
  return ref.read(imagePipelineProvider).signedUrlFor(path);
});
