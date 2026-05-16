import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_providers.dart';
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

/// Feed posts for the active filter. Re-fetches when filter changes.
final feedPostsProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
  final filter = ref.watch(feedFilterProvider);
  final repo = ref.watch(postRepositoryProvider);
  return repo.fetchFeed(filter: filter);
});

/// Current user's vote map for posts in the feed.
final feedVotesProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final posts = await ref.watch(feedPostsProvider.future);
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
