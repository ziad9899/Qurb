import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_providers.dart';
import 'whispers_models.dart';
import 'whispers_repository.dart';

final whispersRepositoryProvider = Provider<WhispersRepository>(
  (ref) => WhispersRepository(ref.watch(supabaseClientProvider)),
);

final myChatsProvider =
    FutureProvider.autoDispose<List<ChatThread>>((ref) async {
  return ref.watch(whispersRepositoryProvider).listMyChats();
});

final incomingWhispersProvider =
    FutureProvider.autoDispose<List<IncomingWhisper>>((ref) async {
  return ref.watch(whispersRepositoryProvider).listIncomingRequests();
});

/// REST-based initial message list for a chat. The WhisperThreadScreen
/// uses this as the seed, then layers realtime inserts on top locally.
final chatMessagesInitialProvider = FutureProvider.autoDispose
    .family<List<ChatMessage>, int>((ref, chatId) async {
  return ref.watch(whispersRepositoryProvider).listMessages(chatId);
});
