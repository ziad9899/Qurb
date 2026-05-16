import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';
import 'profile.dart';

/// Single shared Supabase client.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

/// Live auth state stream — emits on sign-in / sign-out / token refresh.
final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authState;
});

/// Current user, derived from the auth state stream. Null when signed out.
final currentUserProvider = Provider<User?>((ref) {
  final asyncState = ref.watch(authStateStreamProvider);
  return asyncState.maybeWhen(
    data: (s) => s.session?.user,
    orElse: () => ref.read(authRepositoryProvider).currentUser,
  );
});

/// Profile for the current user. Triggers a fetch when user changes.
/// The server-side trigger creates the profile row on signup, but we briefly
/// retry to cover the small window between INSERT and SELECT visibility.
final myProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final repo = ref.watch(authRepositoryProvider);
  for (var attempt = 0; attempt < 5; attempt++) {
    final p = await repo.fetchMyProfile();
    if (p != null) return p;
    await Future<void>.delayed(
      Duration(milliseconds: 200 * (attempt + 1)),
    );
  }
  return null;
});
