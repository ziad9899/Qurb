import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_providers.dart';
import 'trend_models.dart';
import 'trend_repository.dart';

final trendRepositoryProvider = Provider<TrendRepository>(
  (ref) => TrendRepository(ref.watch(supabaseClientProvider)),
);

final trendingTagsProvider =
    FutureProvider.autoDispose<List<TrendingTag>>((ref) {
  return ref.watch(trendRepositoryProvider).listTrendingTags();
});
