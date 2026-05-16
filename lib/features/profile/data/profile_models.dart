import 'package:equatable/equatable.dart';

class ProfileStats extends Equatable {
  const ProfileStats({
    required this.postsCount,
    required this.commentsCount,
    required this.karma,
    required this.blockedCount,
    required this.bookmarksCount,
  });
  final int postsCount;
  final int commentsCount;
  final int karma;
  final int blockedCount;
  final int bookmarksCount;

  factory ProfileStats.fromMap(Map<String, dynamic> m) => ProfileStats(
        postsCount: (m['posts_count'] as num?)?.toInt() ?? 0,
        commentsCount: (m['comments_count'] as num?)?.toInt() ?? 0,
        karma: (m['karma'] as num?)?.toInt() ?? 0,
        blockedCount: (m['blocked_count'] as num?)?.toInt() ?? 0,
        bookmarksCount: (m['bookmarks_count'] as num?)?.toInt() ?? 0,
      );

  String get karmaShort {
    if (karma.abs() >= 1000) {
      return '${(karma / 1000).toStringAsFixed(1)}ك';
    }
    return karma.toString();
  }

  @override
  List<Object?> get props =>
      [postsCount, commentsCount, karma, blockedCount, bookmarksCount];
}

class BlockedUser extends Equatable {
  const BlockedUser({
    required this.blockedNumericId,
    required this.createdAt,
  });
  final int blockedNumericId;
  final DateTime createdAt;
  factory BlockedUser.fromMap(Map<String, dynamic> m) => BlockedUser(
        blockedNumericId: (m['blocked_numeric_id'] as num).toInt(),
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
      );
  @override
  List<Object?> get props => [blockedNumericId, createdAt];
}

class MyComment extends Equatable {
  const MyComment({
    required this.id,
    required this.postId,
    required this.body,
    required this.score,
    required this.createdAt,
    this.postPreview,
  });
  final int id;
  final int postId;
  final String body;
  final int score;
  final DateTime createdAt;
  final String? postPreview;
  factory MyComment.fromMap(Map<String, dynamic> m) => MyComment(
        id: (m['id'] as num).toInt(),
        postId: (m['post_id'] as num).toInt(),
        body: m['body'] as String,
        score: (m['score'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
        postPreview: m['post_preview'] as String?,
      );
  @override
  List<Object?> get props =>
      [id, postId, body, score, createdAt, postPreview];
}
