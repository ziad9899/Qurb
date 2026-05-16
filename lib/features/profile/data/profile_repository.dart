import 'package:supabase_flutter/supabase_flutter.dart';

import '../../feed/data/post.dart';
import 'profile_models.dart';

class ProfileRepository {
  ProfileRepository(this._client);
  final SupabaseClient _client;

  Future<ProfileStats> getMyStats() async {
    final rows = await _client.rpc('my_stats') as List;
    if (rows.isEmpty) {
      return const ProfileStats(
        postsCount: 0, commentsCount: 0, karma: 0,
        blockedCount: 0, bookmarksCount: 0,
      );
    }
    return ProfileStats.fromMap(rows.first as Map<String, dynamic>);
  }

  Future<List<Post>> getMyPosts({int limit = 30}) async {
    final rows = await _client
        .from('my_posts')
        .select()
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((r) => Post.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<MyComment>> getMyComments({int limit = 30}) async {
    final rows = await _client
        .from('my_comment_threads')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((r) => MyComment.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<Post>> getMyBookmarks({int limit = 30}) async {
    final rows = await _client
        .from('my_bookmarks')
        .select()
        .order('bookmarked_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((r) => Post.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<BlockedUser>> getMyBlocks() async {
    final rows = await _client
        .from('my_blocks')
        .select()
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => BlockedUser.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> blockUserByPost(int postId) =>
      _client.rpc('block_user_by_post', params: {'p_post_id': postId});

  Future<void> unblockByNumericId(int numericId) => _client.rpc(
        'unblock_user_by_numeric_id',
        params: {'p_numeric_id': numericId},
      );

  Future<int> fileReport({
    required String targetType,
    int? targetId,
    required String reason,
    String? note,
  }) async {
    final r = await _client.rpc('file_report', params: {
      'p_target_type': targetType,
      'p_target_id': targetId,
      'p_reason': reason,
      'p_note': note,
    });
    return (r as num).toInt();
  }

  Future<bool> toggleBookmark(int postId) async {
    final r = await _client.rpc('toggle_bookmark', params: {
      'p_post_id': postId,
    });
    return r as bool;
  }

  Future<void> deleteMyAccount() => _client.rpc('delete_my_account');
}
