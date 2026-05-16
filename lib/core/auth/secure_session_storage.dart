import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Persists the Supabase auth session in platform-native secure storage.
///
/// Why we don't use the default Shared Preferences backend:
///   - For Minto, the session token IS the user's full identity — there is no
///     password to recover it. Losing the session = losing the account.
///   - Keychain (iOS) survives app reinstall when iCloud Keychain is enabled,
///     which mirrors the "permanent ID" promise from the welcome screen.
///   - EncryptedSharedPreferences (Android) gives at-rest protection.
class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage();

  static const _key = 'qurb_supabase_session_v1';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      synchronizable: false,
    ),
  );

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() => _storage.read(key: _key);

  @override
  Future<bool> hasAccessToken() async =>
      (await _storage.read(key: _key)) != null;

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: _key, value: persistSessionString);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: _key);
}
