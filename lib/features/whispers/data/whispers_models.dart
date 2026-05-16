import 'package:equatable/equatable.dart';

/// One row from the `my_chats` view.
class ChatThread extends Equatable {
  const ChatThread({
    required this.id,
    required this.otherNumericId,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessagePreview,
    required this.status,
    required this.unreadCount,
  });

  final int id;
  final int otherNumericId;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? lastMessagePreview;
  final String status;
  final int unreadCount;

  factory ChatThread.fromMap(Map<String, dynamic> m) => ChatThread(
        id: (m['id'] as num).toInt(),
        otherNumericId: (m['other_numeric_id'] as num).toInt(),
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
        lastMessageAt: m['last_message_at'] != null
            ? DateTime.parse(m['last_message_at'] as String).toLocal()
            : null,
        lastMessagePreview: m['last_message_preview'] as String?,
        status: m['status'] as String? ?? 'active',
        unreadCount: (m['unread_count'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [
        id, otherNumericId, createdAt, lastMessageAt,
        lastMessagePreview, status, unreadCount,
      ];
}

/// Pending incoming whisper request (from `my_incoming_whispers` view).
class IncomingWhisper extends Equatable {
  const IncomingWhisper({
    required this.id,
    required this.fromNumericId,
    this.postId,
    this.postPreview,
    this.message,
    required this.createdAt,
  });

  final int id;
  final int fromNumericId;
  final int? postId;
  final String? postPreview;
  final String? message;
  final DateTime createdAt;

  factory IncomingWhisper.fromMap(Map<String, dynamic> m) => IncomingWhisper(
        id: (m['id'] as num).toInt(),
        fromNumericId: (m['from_numeric_id'] as num).toInt(),
        postId: (m['post_id'] as num?)?.toInt(),
        postPreview: m['post_preview'] as String?,
        message: m['message'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
      );

  @override
  List<Object?> get props =>
      [id, fromNumericId, postId, postPreview, message, createdAt];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.body,
    required this.isMine,
    required this.createdAt,
    this.readAt,
  });

  final int id;
  final int chatId;
  final String body;
  final bool isMine;
  final DateTime createdAt;
  final DateTime? readAt;

  factory ChatMessage.fromView(Map<String, dynamic> m) => ChatMessage(
        id: (m['id'] as num).toInt(),
        chatId: (m['chat_id'] as num).toInt(),
        body: m['body'] as String,
        isMine: m['is_mine'] as bool? ?? false,
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
        readAt: m['read_at'] != null
            ? DateTime.parse(m['read_at'] as String).toLocal()
            : null,
      );

  /// Build from a raw `messages` row (used by Realtime events which deliver
  /// the row without the `is_mine` view column).
  factory ChatMessage.fromRow(
    Map<String, dynamic> m,
    String currentUserId,
  ) =>
      ChatMessage(
        id: (m['id'] as num).toInt(),
        chatId: (m['chat_id'] as num).toInt(),
        body: m['body'] as String,
        isMine: m['sender_id'] == currentUserId,
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
        readAt: m['read_at'] != null
            ? DateTime.parse(m['read_at'] as String).toLocal()
            : null,
      );

  @override
  List<Object?> get props => [id, chatId, body, isMine, createdAt, readAt];
}
