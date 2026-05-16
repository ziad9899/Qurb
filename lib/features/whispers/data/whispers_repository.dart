import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'whispers_models.dart';

class WhispersRepository {
  WhispersRepository(this._client);
  final SupabaseClient _client;

  // ── Lists ──────────────────────────────────────────────

  Future<List<ChatThread>> listMyChats() async {
    final rows = await _client
        .from('my_chats')
        .select()
        .order('last_message_at', ascending: false, nullsFirst: false);
    return (rows as List)
        .map((r) => ChatThread.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<IncomingWhisper>> listIncomingRequests() async {
    final rows = await _client
        .from('my_incoming_whispers')
        .select()
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => IncomingWhisper.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  // ── Requests ───────────────────────────────────────────

  /// Returns the new request id, OR throws `chat_exists:N` if a chat
  /// already exists between the two users — the UI should jump to it.
  Future<int> requestWhisper({
    required int postId,
    String? message,
  }) async {
    final id = await _client.rpc(
      'request_whisper',
      params: {
        'p_post_id': postId,
        'p_message': message,
      },
    );
    return (id as num).toInt();
  }

  /// Returns chat_id when accepted, null when declined.
  Future<int?> respondToRequest({
    required int requestId,
    required bool accept,
  }) async {
    final res = await _client.rpc(
      'respond_whisper_request',
      params: {
        'p_request_id': requestId,
        'p_action': accept ? 'accept' : 'decline',
      },
    );
    if (res == null) return null;
    return (res as num).toInt();
  }

  // ── Messages ───────────────────────────────────────────

  Future<List<ChatMessage>> listMessages(int chatId) async {
    final rows = await _client
        .from('messages_for_chat')
        .select()
        .eq('chat_id', chatId)
        .order('created_at');
    return (rows as List)
        .map((r) => ChatMessage.fromView(r as Map<String, dynamic>))
        .toList();
  }

  Future<int> sendMessage({required int chatId, required String body}) async {
    final id = await _client.rpc(
      'send_message',
      params: {'p_chat_id': chatId, 'p_body': body},
    );
    return (id as num).toInt();
  }

  Future<void> markRead(int chatId) async {
    await _client.rpc('mark_read', params: {'p_chat_id': chatId});
  }

  /// Subscribe to new messages in a chat via Postgres realtime.
  /// Caller is responsible for unsubscribing.
  RealtimeChannel subscribeToChat({
    required int chatId,
    required void Function(ChatMessage message) onMessage,
  }) {
    final currentUid = _client.auth.currentUser?.id ?? '';
    final channel = _client
        .channel('messages-chat-$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: chatId,
          ),
          callback: (payload) {
            final row = payload.newRecord;
            onMessage(ChatMessage.fromRow(row, currentUid));
          },
        )
      ..subscribe();
    return channel;
  }
}
