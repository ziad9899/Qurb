import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/auth/secure_session_storage.dart';
import 'core/config/supabase_config.dart';
import 'core/diagnostics/error_logger.dart';
import 'core/prefs/prefs_providers.dart';
import 'features/splash/offline_boot_screen.dart';

Future<void> main() async {
  // Run the whole app under a guarded zone so async exceptions that escape
  // FlutterError get a second chance to be reported through ErrorLogger.
  runZonedGuarded(_boot, ErrorLogger.onZonedError);
}

Future<void> _boot() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wire crash hooks BEFORE any work that could fail, so the first
  // bad allocation/promise isn't lost to console-only output.
  ErrorLogger.bind();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  final prefs = await SharedPreferences.getInstance();

  // Supabase.initialize must succeed before any Riverpod provider that
  // reads `Supabase.instance.client` is built. If the network/DNS is
  // down (or the project is temporarily unreachable) it throws — and
  // because we awaited it before runApp, the user would otherwise see
  // a black screen forever. Catch it, mount a minimal retry UI, and
  // re-run _boot() when they tap Retry.
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: SecureSessionStorage(),
        autoRefreshToken: true,
      ),
      debug: false,
    );
  } catch (_) {
    runApp(const OfflineBootScreen(onRetry: _boot));
    return;
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const QurbApp(),
    ),
  );
}
