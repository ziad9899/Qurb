import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'prefs_repository.dart';

/// Resolved once at app boot in `main.dart` via an override; reading the
/// default throws to surface mis-setup early.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('SharedPreferences must be overridden'),
);

final prefsRepositoryProvider = Provider<PrefsRepository>(
  (ref) => PrefsRepository(ref.watch(sharedPreferencesProvider)),
);

// ─── locale ────────────────────────────────────────────────────
//
// null = follow the system; ('ar') / ('en') = user override.
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final s = ref.read(prefsRepositoryProvider).readLocale();
    return s == null ? null : Locale(s);
  }

  Future<void> setLocale(Locale? l) async {
    await ref.read(prefsRepositoryProvider).writeLocale(l?.languageCode);
    state = l;
  }
}

final localeProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);

// ─── theme mode ────────────────────────────────────────────────
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final s = ref.read(prefsRepositoryProvider).readThemeMode();
    return switch (s) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }

  Future<void> setMode(ThemeMode m) async {
    final wire = switch (m) {
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
      ThemeMode.dark => 'dark',
    };
    await ref.read(prefsRepositoryProvider).writeThemeMode(wire);
    state = m;
  }
}

final appThemeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

// ─── simple boolean toggles ────────────────────────────────────
class _BoolPrefController extends Notifier<bool> {
  _BoolPrefController({required this.read, required this.write});
  final bool Function(PrefsRepository) read;
  final Future<void> Function(PrefsRepository, bool) write;

  @override
  bool build() => read(ref.read(prefsRepositoryProvider));

  Future<void> set(bool v) async {
    await write(ref.read(prefsRepositoryProvider), v);
    state = v;
  }
}

final locationShareProvider =
    NotifierProvider<_BoolPrefController, bool>(() => _BoolPrefController(
          read: (r) => r.readLocationShare(),
          write: (r, v) => r.writeLocationShare(v),
        ));

final allowStrangersProvider =
    NotifierProvider<_BoolPrefController, bool>(() => _BoolPrefController(
          read: (r) => r.readAllowStrangers(),
          write: (r, v) => r.writeAllowStrangers(v),
        ));

final readReceiptsProvider =
    NotifierProvider<_BoolPrefController, bool>(() => _BoolPrefController(
          read: (r) => r.readReadReceipts(),
          write: (r, v) => r.writeReadReceipts(v),
        ));

final allNotifsProvider =
    NotifierProvider<_BoolPrefController, bool>(() => _BoolPrefController(
          read: (r) => r.readAllNotifs(),
          write: (r, v) => r.writeAllNotifs(v),
        ));

final pulseNotifsProvider =
    NotifierProvider<_BoolPrefController, bool>(() => _BoolPrefController(
          read: (r) => r.readPulseNotifs(),
          write: (r, v) => r.writePulseNotifs(v),
        ));
