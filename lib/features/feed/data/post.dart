import 'package:equatable/equatable.dart';

import '../../../core/data/mock_data.dart' show Proximity;

/// Mirrors `public.posts_feed` view.
class Post extends Equatable {
  const Post({
    required this.id,
    required this.authorNumericId,
    required this.body,
    this.tag,
    required this.proximity,
    required this.score,
    required this.commentsCount,
    required this.hasImage,
    required this.createdAt,
  });

  final int id;
  final int authorNumericId;
  final String body;
  final String? tag;
  final Proximity proximity;
  final int score;
  final int commentsCount;
  final bool hasImage;
  final DateTime createdAt;

  int get minutesAgo => DateTime.now().difference(createdAt).inMinutes;

  factory Post.fromMap(Map<String, dynamic> m) => Post(
        id: (m['id'] as num).toInt(),
        authorNumericId: (m['author_numeric_id'] as num).toInt(),
        body: m['body'] as String,
        tag: m['tag'] as String?,
        proximity: _proximityFrom(m['proximity'] as String),
        score: (m['score'] as num?)?.toInt() ?? 0,
        commentsCount: (m['comments_count'] as num?)?.toInt() ?? 0,
        hasImage: m['has_image'] as bool? ?? false,
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
      );

  @override
  List<Object?> get props =>
      [id, authorNumericId, body, tag, proximity, score, commentsCount, hasImage, createdAt];
}

Proximity _proximityFrom(String s) {
  switch (s) {
    case 'block':
      return Proximity.block;
    case 'city':
      return Proximity.city;
    case 'near':
    default:
      return Proximity.near;
  }
}

String proximityToWire(Proximity p) {
  switch (p) {
    case Proximity.near:
      return 'near';
    case Proximity.block:
      return 'block';
    case Proximity.city:
      return 'city';
  }
}
