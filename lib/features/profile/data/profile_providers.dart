import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_providers.dart';
import '../../feed/data/post.dart';
import 'profile_models.dart';
import 'profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(supabaseClientProvider)),
);

final myStatsProvider =
    FutureProvider.autoDispose<ProfileStats>((ref) {
  return ref.watch(profileRepositoryProvider).getMyStats();
});

final myPostsProvider =
    FutureProvider.autoDispose<List<Post>>((ref) {
  return ref.watch(profileRepositoryProvider).getMyPosts();
});

final myCommentsProvider =
    FutureProvider.autoDispose<List<MyComment>>((ref) {
  return ref.watch(profileRepositoryProvider).getMyComments();
});

final myBookmarksProvider =
    FutureProvider.autoDispose<List<Post>>((ref) {
  return ref.watch(profileRepositoryProvider).getMyBookmarks();
});

final myBlocksProvider =
    FutureProvider.autoDispose<List<BlockedUser>>((ref) {
  return ref.watch(profileRepositoryProvider).getMyBlocks();
});

enum ProfileTab { posts, comments, bookmarks }

final profileTabProvider =
    StateProvider<ProfileTab>((ref) => ProfileTab.posts);
