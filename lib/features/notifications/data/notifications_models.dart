import 'package:equatable/equatable.dart';

enum NotificationKind {
  reply,
  replyToComment,
  voteMilestone,
  whisperRequest,
  pulse,
  tagTrending,
}

NotificationKind _kindFromWire(String s) {
  switch (s) {
    case 'reply':
      return NotificationKind.reply;
    case 'reply_to_comment':
      return NotificationKind.replyToComment;
    case 'vote_milestone':
      return NotificationKind.voteMilestone;
    case 'whisper_request':
      return NotificationKind.whisperRequest;
    case 'pulse':
      return NotificationKind.pulse;
    case 'tag_trending':
      return NotificationKind.tagTrending;
  }
  return NotificationKind.reply;
}

class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.kind,
    this.actorNumericId,
    this.targetType,
    this.targetId,
    required this.body,
    required this.createdAt,
    this.readAt,
  });

  final int id;
  final NotificationKind kind;
  final int? actorNumericId;
  final String? targetType;
  final int? targetId;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isUnread => readAt == null;
  int get minutesAgo => DateTime.now().difference(createdAt).inMinutes;

  factory NotificationItem.fromMap(Map<String, dynamic> m) => NotificationItem(
        id: (m['id'] as num).toInt(),
        kind: _kindFromWire(m['kind'] as String),
        actorNumericId: (m['actor_numeric_id'] as num?)?.toInt(),
        targetType: m['target_type'] as String?,
        targetId: (m['target_id'] as num?)?.toInt(),
        body: m['body'] as String? ?? '',
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
        readAt: m['read_at'] != null
            ? DateTime.parse(m['read_at'] as String).toLocal()
            : null,
      );

  @override
  List<Object?> get props => [
        id, kind, actorNumericId, targetType, targetId,
        body, createdAt, readAt,
      ];
}

/// Bucket label used to group notifications on the screen.
enum NotificationBucket { today, yesterday, thisWeek, earlier }

NotificationBucket bucketOf(DateTime t) {
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final startOfYesterday = startOfToday.subtract(const Duration(days: 1));
  final startOfThisWeek = startOfToday.subtract(Duration(days: now.weekday - 1));
  if (!t.isBefore(startOfToday)) return NotificationBucket.today;
  if (!t.isBefore(startOfYesterday)) return NotificationBucket.yesterday;
  if (!t.isBefore(startOfThisWeek)) return NotificationBucket.thisWeek;
  return NotificationBucket.earlier;
}

String bucketLabel(NotificationBucket b) {
  switch (b) {
    case NotificationBucket.today:
      return 'اليوم';
    case NotificationBucket.yesterday:
      return 'الأمس';
    case NotificationBucket.thisWeek:
      return 'هذا الأسبوع';
    case NotificationBucket.earlier:
      return 'سابقاً';
  }
}
