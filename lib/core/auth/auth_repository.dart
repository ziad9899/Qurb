import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile.dart';

/// Thin wrapper around Supabase auth + the `profiles` table.
/// The trigger `on_auth_user_created_trg` (in 20260516_001_profiles.sql)
/// creates the profile row server-side immediately after signup, including
/// for anonymous users — we just read it back here.
class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authState => _client.auth.onAuthStateChange;

  /// Creates a new anonymous user. Server-side trigger creates the matching
  /// profile row with a unique 5-digit numeric_id.
  Future<AuthResponse> signInAnonymously() {
    return _client.auth.signInAnonymously();
  }

  /// Reads the profile of the current user. Returns null if nothing matches
  /// (which should never happen for a freshly-created anonymous user, but
  /// can occur briefly during the trigger window — caller should retry).
  Future<Profile?> fetchMyProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return null;
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();
    if (row == null) return null;
    return Profile.fromMap(row);
  }

  /// Best-effort heartbeat — fire-and-forget; failure is non-fatal.
  Future<void> touchLastSeen() async {
    try {
      await _client.rpc('touch_last_seen');
    } catch (_) {/* ignore */}
  }

  Future<void> signOut() => _client.auth.signOut();
}
