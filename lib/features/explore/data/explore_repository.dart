import 'package:supabase_flutter/supabase_flutter.dart';

import '../../feed/data/post.dart';
import 'explore_models.dart';

class ExploreRepository {
  ExploreRepository(this._client);
  final SupabaseClient _client;

  Future<List<Community>> listCommunities() async {
    final rows = await _client
        .from('communities')
        .select()
        .order('members', ascending: false);
    return (rows as List)
        .map((r) => Community.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<Post>> searchPosts(String query, {int limit = 30}) async {
    if (query.trim().isEmpty) return const [];
    final rows = await _client.rpc('search_posts', params: {
      'p_query': query.trim(),
      'p_limit': limit,
    });
    return (rows as List)
        .map((r) => Post.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<Post>> suggestedPosts({int limit = 6}) async {
    final rows = await _client
        .from('posts_feed')
        .select()
        .order('score', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((r) => Post.fromMap(r as Map<String, dynamic>))
        .toList();
  }
}
