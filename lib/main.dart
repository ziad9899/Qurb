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

Future<void> main() async {
  // Run the whole app under a guarded zone so async exceptions that escape
  // FlutterError get a second chance to be reported through ErrorLogger.
  runZonedGuarded(() async {
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

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: SecureSessionStorage(),
        autoRefreshToken: true,
      ),
      debug: false,
    );

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const QurbApp(),
      ),
    );
  }, ErrorLogger.onZonedError);
}
