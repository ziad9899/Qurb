import 'package:equatable/equatable.dart';

enum TrendDirection { up, down, flat }

TrendDirection _dirFromWire(String s) {
  switch (s) {
    case 'up':
      return TrendDirection.up;
    case 'down':
      return TrendDirection.down;
    default:
      return TrendDirection.flat;
  }
}

class TrendingTag extends Equatable {
  const TrendingTag({
    required this.tag,
    required this.postCount,
    required this.recentCount,
    required this.priorCount,
    required this.direction,
  });

  final String tag;
  final int postCount;
  final int recentCount;
  final int priorCount;
  final TrendDirection direction;

  factory TrendingTag.fromMap(Map<String, dynamic> m) => TrendingTag(
        tag: m['tag'] as String,
        postCount: (m['post_count'] as num).toInt(),
        recentCount: (m['recent_count'] as num).toInt(),
        priorCount: (m['prior_count'] as num).toInt(),
        direction: _dirFromWire(m['direction'] as String),
      );

  @override
  List<Object?> get props =>
      [tag, postCount, recentCount, priorCount, direction];
}
