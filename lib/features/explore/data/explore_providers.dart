import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_providers.dart';
import '../../feed/data/post.dart';
import 'explore_models.dart';
import 'explore_repository.dart';

final exploreRepositoryProvider = Provider<ExploreRepository>(
  (ref) => ExploreRepository(ref.watch(supabaseClientProvider)),
);

final communitiesProvider =
    FutureProvider.autoDispose<List<Community>>((ref) {
  return ref.watch(exploreRepositoryProvider).listCommunities();
});

final suggestedPostsProvider =
    FutureProvider.autoDispose<List<Post>>((ref) {
  return ref.watch(exploreRepositoryProvider).suggestedPosts();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider =
    FutureProvider.autoDispose<List<Post>>((ref) async {
  final q = ref.watch(searchQueryProvider);
  if (q.trim().isEmpty) return const [];
  return ref.watch(exploreRepositoryProvider).searchPosts(q);
});
