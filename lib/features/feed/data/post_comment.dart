import 'package:equatable/equatable.dart';

/// Mirrors `public.comments_for_post` view.
class PostComment extends Equatable {
  const PostComment({
    required this.id,
    required this.postId,
    this.parentId,
    required this.authorNumericId,
    required this.body,
    required this.score,
    required this.createdAt,
    this.replies = const [],
  });

  final int id;
  final int postId;
  final int? parentId;
  final int authorNumericId;
  final String body;
  final int score;
  final DateTime createdAt;
  final List<PostComment> replies;

  int get minutesAgo => DateTime.now().difference(createdAt).inMinutes;

  PostComment withReplies(List<PostComment> r) => PostComment(
        id: id,
        postId: postId,
        parentId: parentId,
        authorNumericId: authorNumericId,
        body: body,
        score: score,
        createdAt: createdAt,
        replies: r,
      );

  factory PostComment.fromMap(Map<String, dynamic> m) => PostComment(
        id: (m['id'] as num).toInt(),
        postId: (m['post_id'] as num).toInt(),
        parentId: (m['parent_id'] as num?)?.toInt(),
        authorNumericId: (m['author_numeric_id'] as num).toInt(),
        body: m['body'] as String,
        score: (m['score'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
      );

  /// Group a flat list of comments by parent_id, returning top-level
  /// comments with their replies attached (one level deep).
  static List<PostComment> threadify(List<PostComment> flat) {
    final replyMap = <int, List<PostComment>>{};
    for (final c in flat) {
      if (c.parentId != null) {
        replyMap.putIfAbsent(c.parentId!, () => []).add(c);
      }
    }
    return flat
        .where((c) => c.parentId == null)
        .map((c) => c.withReplies(replyMap[c.id] ?? const []))
        .toList();
  }

  @override
  List<Object?> get props => [
        id, postId, parentId, authorNumericId, body, score, createdAt, replies,
      ];
}
