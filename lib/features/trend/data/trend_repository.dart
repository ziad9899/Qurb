import 'package:supabase_flutter/supabase_flutter.dart';

import 'trend_models.dart';

class TrendRepository {
  TrendRepository(this._client);
  final SupabaseClient _client;

  Future<List<TrendingTag>> listTrendingTags() async {
    final rows = await _client.from('trending_tags').select();
    return (rows as List)
        .map((r) => TrendingTag.fromMap(r as Map<String, dynamic>))
        .toList();
  }
}
