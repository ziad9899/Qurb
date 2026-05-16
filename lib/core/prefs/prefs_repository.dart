import 'package:shared_preferences/shared_preferences.dart';

/// Thin typed wrapper over SharedPreferences for user-facing toggles.
/// One source of truth — providers in `prefs_providers.dart` read/write
/// through this so the storage layer can be swapped (e.g. to secure_storage
/// for sensitive fields) without touching callers.
class PrefsRepository {
  PrefsRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _kLocale = 'pref.locale';
  static const _kThemeMode = 'pref.themeMode';
  static const _kLocationShare = 'pref.locationShare';
  static const _kAllowStrangers = 'pref.allowStrangers';
  static const _kReadReceipts = 'pref.readReceipts';
  static const _kAllNotifs = 'pref.allNotifs';
  static const _kPulseNotifs = 'pref.pulseNotifs';
  static const _kDemoLocation = 'pref.demoLocation';

  // locale: 'ar' | 'en' | null (= system)
  String? readLocale() => _prefs.getString(_kLocale);
  Future<void> writeLocale(String? v) async {
    if (v == null) {
      await _prefs.remove(_kLocale);
    } else {
      await _prefs.setString(_kLocale, v);
    }
  }

  // themeMode: 'dark' | 'light' | 'system'
  String readThemeMode() => _prefs.getString(_kThemeMode) ?? 'dark';
  Future<void> writeThemeMode(String v) => _prefs.setString(_kThemeMode, v);

  bool readLocationShare() => _prefs.getBool(_kLocationShare) ?? true;
  Future<void> writeLocationShare(bool v) => _prefs.setBool(_kLocationShare, v);

  bool readAllowStrangers() => _prefs.getBool(_kAllowStrangers) ?? true;
  Future<void> writeAllowStrangers(bool v) =>
      _prefs.setBool(_kAllowStrangers, v);

  bool readReadReceipts() => _prefs.getBool(_kReadReceipts) ?? false;
  Future<void> writeReadReceipts(bool v) => _prefs.setBool(_kReadReceipts, v);

  bool readAllNotifs() => _prefs.getBool(_kAllNotifs) ?? true;
  Future<void> writeAllNotifs(bool v) => _prefs.setBool(_kAllNotifs, v);

  bool readPulseNotifs() => _prefs.getBool(_kPulseNotifs) ?? true;
  Future<void> writePulseNotifs(bool v) => _prefs.setBool(_kPulseNotifs, v);

  /// Apple reviewers test from Cupertino, CA and would see an empty feed
  /// because all our seed data is geographically anchored to Saudi cities.
  /// When `demoLocation` is true, [LocationRepository.acquireAndSync] reports
  /// a fixed Riyadh coordinate (24.7136, 46.6753) instead of reading GPS, so
  /// the review session reaches a populated feed. Documented in
  /// docs/REVIEWER_NOTES.md.
  bool readDemoLocation() => _prefs.getBool(_kDemoLocation) ?? false;
  Future<void> writeDemoLocation(bool v) =>
      _prefs.setBool(_kDemoLocation, v);
}
