import 'package:supabase_flutter/supabase_flutter.dart';

import 'notifications_models.dart';

class NotificationsRepository {
  NotificationsRepository(this._client);
  final SupabaseClient _client;

  Future<List<NotificationItem>> list({int limit = 80}) async {
    final rows = await _client
        .from('notifications')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((r) => NotificationItem.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<int> unreadCount() async {
    final rows = await _client
        .from('notifications')
        .select('id')
        .filter('read_at', 'is', null);
    return (rows as List).length;
  }

  Future<void> markRead(int notifId) async {
    await _client.rpc('mark_notification_read', params: {
      'p_notif_id': notifId,
    });
  }

  Future<int> markAllRead() async {
    final r = await _client.rpc('mark_all_notifications_read');
    return (r as num?)?.toInt() ?? 0;
  }
}
