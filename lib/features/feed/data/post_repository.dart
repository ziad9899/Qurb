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

/// Server-side radii (meters) keyed by feed filter. Mirrors the labels
/// shown in the composer: قريب=500م، الحي=2كم، المدينة=15كم.
double? radiusFor(FeedFilter f) {
  switch (f) {
    case FeedFilter.near:
      return 500;
    case FeedFilter.block:
      return 2000;
    case FeedFilter.city:
      return 15000;
    case FeedFilter.all:
      return null;
  }
}

class PostRepository {
  PostRepository(this._client);
  final SupabaseClient _client;

  /// Geographic feed via `posts_near` RPC. Only used when the user has a
  /// known coordinate; otherwise falls back to `fetchFeed` (proximity-string
  /// filter) so seeded mock data and pre-Phase-8 rows still appear.
  Future<List<Post>> fetchFeedNear({
    required double lat,
    required double lng,
    required double radiusM,
    int limit = 50,
  }) async {
    final rows = await _client.rpc(
      'posts_near',
      params: {
        'p_lat': lat,
        'p_lng': lng,
        'p_radius_m': radiusM,
        'p_limit': limit,
      },
    );
    return (rows as List)
        .map((r) => Post.fromMap(r as Map<String, dynamic>))
        .toList();
  }

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
    double? lat,
    double? lng,
    String? imagePath,
    int? imageWidth,
    int? imageHeight,
    int? imageBytes,
  }) async {
    final id = await _client.rpc(
      'create_post',
      params: {
        'p_body': body,
        'p_tag': tag,
        'p_proximity': proximityToWire(proximity),
        'p_lat': lat,
        'p_lng': lng,
        'p_image_path': imagePath,
        'p_img_width': imageWidth,
        'p_img_height': imageHeight,
        'p_img_bytes': imageBytes,
      },
    );
    return (id as num).toInt();
  }

  Future<void> updateMyPost({
    required int postId,
    required String body,
  }) async {
    await _client.rpc('update_my_post', params: {
      'p_post_id': postId,
      'p_body': body,
    });
  }

  Future<void> deleteMyPost(int postId) async {
    await _client.rpc('delete_my_post', params: {
      'p_post_id': postId,
    });
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

  /// Subscribe to new comments on a post via Postgres realtime so the
  /// other party sees your reply without a manual refresh.
  ///
  /// The callback fires with no payload — it is a notification, not a
  /// data delivery. The screen owns a debounced `ref.invalidate` to
  /// coalesce bursts. The previous version did a per-INSERT
  /// `comments_for_post?id=eq.X` fetch just to recover the joined
  /// `author_numeric_id`, then the screen invalidated the whole list
  /// anyway → two REST trips per comment. Now we do zero extra fetches
  /// in the subscription path.
  RealtimeChannel subscribeToPostComments({
    required int postId,
    required void Function() onChange,
  }) {
    final channel = _client
        .channel('comments-post-$postId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'comments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'post_id',
            value: postId,
          ),
          callback: (_) => onChange(),
        )
      ..subscribe();
    return channel;
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
