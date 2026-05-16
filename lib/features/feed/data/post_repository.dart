import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/data/mock_data.dart' show Proximity;
import 'post.dart';
import 'post_comment.dart';

enum FeedFilter { near, block, city, all }

String? _filterToProximity(FeedFilter f) {
  switch (f) {
    case FeedFilter.near:
      return 'near';
    case FeedFilter.block:
      return 'block';
    case FeedFilter.city:
      return 'city';
    case FeedFilter.all:
      return null;
  }
}

class PostRepository {
  PostRepository(this._client);
  final SupabaseClient _client;

  Future<List<Post>> fetchFeed({
    FeedFilter filter = FeedFilter.near,
    int limit = 50,
  }) async {
    final proximityWire = _filterToProximity(filter);
    var query = _client.from('posts_feed').select();
    if (proximityWire != null) {
      query = query.eq('proximity', proximityWire);
    }
    final rows = await query
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((r) => Post.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<Post?> fetchPost(int postId) async {
    final row = await _client
        .from('posts_feed')
        .select()
        .eq('id', postId)
        .maybeSingle();
    if (row == null) return null;
    return Post.fromMap(row);
  }

  Future<int> createPost({
    required String body,
    required String? tag,
    required Proximity proximity,
  }) async {
    final id = await _client.rpc(
      'create_post',
      params: {
        'p_body': body,
        'p_tag': tag,
        'p_proximity': proximityToWire(proximity),
      },
    );
    return (id as num).toInt();
  }

  Future<List<PostComment>> fetchComments(int postId) async {
    final rows = await _client
        .from('comments_for_post')
        .select()
        .eq('post_id', postId)
        .order('created_at');
    final flat = (rows as List)
        .map((r) => PostComment.fromMap(r as Map<String, dynamic>))
        .toList();
    return PostComment.threadify(flat);
  }

  Future<int> createComment({
    required int postId,
    int? parentId,
    required String body,
  }) async {
    final id = await _client.rpc(
      'create_comment',
      params: {
        'p_post_id': postId,
        'p_parent_id': parentId,
        'p_body': body,
      },
    );
    return (id as num).toInt();
  }
}

class VoteRepository {
  VoteRepository(this._client);
  final SupabaseClient _client;

  /// value: 1, -1, or 0 (clear). Returns new server-side score.
  Future<int> castVote({
    required String targetType,
    required int targetId,
    required int value,
  }) async {
    final score = await _client.rpc(
      'cast_vote',
      params: {
        'p_target_type': targetType,
        'p_target_id': targetId,
        'p_value': value,
      },
    );
    return (score as num).toInt();
  }

  /// Map of (target_type, target_id) → 1|-1 for the current user, used
  /// to highlight the user's existing votes on first paint.
  Future<Map<String, int>> myVotesFor({
    required String targetType,
    required List<int> targetIds,
  }) async {
    if (targetIds.isEmpty) return {};
    final rows = await _client
        .from('votes')
        .select('target_type, target_id, value')
        .eq('target_type', targetType)
        .inFilter('target_id', targetIds);
    return {
      for (final r in (rows as List))
        '${(r as Map)['target_type']}:${r['target_id']}': (r['value'] as num).toInt(),
    };
  }
}
