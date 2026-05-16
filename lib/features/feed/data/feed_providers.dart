import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/location/location_providers.dart';
import 'post.dart';
import 'post_comment.dart';
import 'post_repository.dart';

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(supabaseClientProvider)),
);

final voteRepositoryProvider = Provider<VoteRepository>(
  (ref) => VoteRepository(ref.watch(supabaseClientProvider)),
);

final feedFilterProvider =
    StateProvider<FeedFilter>((ref) => FeedFilter.near);

/// Result of resolving the feed. We use a discriminated value (rather than
/// throwing) so the UI can distinguish "no location yet → ask for it" from
/// "geo query succeeded but empty → render empty state". A silent fallback
/// to the geo-free view would let users in city A see posts from city B,
/// which violates the product's locality contract.
sealed class FeedResult {
  const FeedResult();
}

class FeedReady extends FeedResult {
  const FeedReady(this.posts);
  final List<Post> posts;
}

/// User hasn't granted location permission yet (or it failed). The UI
/// surfaces a "share your location to see what's nearby" call-to-action.
class FeedLocationNeeded extends FeedResult {
  const FeedLocationNeeded();
}

/// Feed for the active filter. Strict locality: any filter with a defined
/// radius requires a known coordinate. The `all` filter (no radius) keeps
/// the old behavior — it's the explicit "show me everywhere" escape hatch.
final feedPostsProvider =
    FutureProvider.autoDispose<FeedResult>((ref) async {
  final filter = ref.watch(feedFilterProvider);
  final repo = ref.watch(postRepositoryProvider);
  final loc = latLngFrom(ref.watch(myLocationProvider));
  final radius = radiusFor(filter);

  // Geo filter requested → must have a coordinate. No silent fallback.
  if (radius != null) {
    if (loc == null) return const FeedLocationNeeded();
    final posts = await repo.fetchFeedNear(
      lat: loc.lat,
      lng: loc.lng,
      radiusM: radius,
    );
    return FeedReady(posts);
  }

  // FeedFilter.all — explicit non-geo. Returns whatever the view yields.
  return FeedReady(await repo.fetchFeed(filter: filter));
});

/// Current user's vote map for posts in the feed.
final feedVotesProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final result = await ref.watch(feedPostsProvider.future);
  final posts = result is FeedReady ? result.posts : const <Post>[];
  if (posts.isEmpty) return {};
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return ref.watch(voteRepositoryProvider).myVotesFor(
        targetType: 'post',
        targetIds: posts.map((p) => p.id).toList(),
      );
});

final commentsProvider = FutureProvider.autoDispose
    .family<List<PostComment>, int>((ref, postId) async {
  return ref.watch(postRepositoryProvider).fetchComments(postId);
});

/// Single-post fetch keyed by id. Provided so screens can read the post
/// once via `ref.watch(postByIdProvider(id))` instead of constructing a
/// fresh `Future` inside `build()` — the old `FutureBuilder(future: ...)`
/// pattern was re-issuing a REST call on every composer keystroke.
final postByIdProvider = FutureProvider.autoDispose
    .family<Post?, int>((ref, postId) async {
  return ref.watch(postRepositoryProvider).fetchPost(postId);
});

final commentVotesProvider = FutureProvider.autoDispose
    .family<Map<String, int>, int>((ref, postId) async {
  final threaded = await ref.watch(commentsProvider(postId).future);
  // flatten ids (top + replies)
  final ids = <int>[];
  for (final c in threaded) {
    ids.add(c.id);
    for (final r in c.replies) {
      ids.add(r.id);
    }
  }
  if (ids.isEmpty) return {};
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return ref.watch(voteRepositoryProvider).myVotesFor(
        targetType: 'comment',
        targetIds: ids,
      );
});
