import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Sends Dart errors to Supabase via the `log_app_error` RPC.
/// No-op in debug mode (we still let FlutterError dump to console) and
/// silently swallows its own failures — observability is not a feature
/// the user should ever notice.
///
/// Usage in main():
///   ErrorLogger.bind();          // before runApp()
///   runZonedGuarded(
///     () => runApp(...),
///     ErrorLogger.onZonedError,
///   );
class ErrorLogger {
  ErrorLogger._();

  static const _appVersion = '0.1.0';
  static const _build = '1';

  /// Wires Flutter's two error channels to [_send].
  /// FlutterError.onError covers framework + widget exceptions;
  /// PlatformDispatcher.onError covers async errors that escape the zone.
  static void bind() {
    final priorFlutter = FlutterError.onError;
    FlutterError.onError = (details) {
      // Always let the original handler do its console dump.
      priorFlutter?.call(details);
      // Don't ship debug-time noise; devs see it in the IDE anyway.
      if (kDebugMode) return;
      _send(
        level: details.silent ? 'warn' : 'error',
        message: details.exceptionAsString(),
        stack: details.stack?.toString(),
      );
    };

    final priorDispatch = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      if (!kDebugMode) {
        _send(
          level: 'fatal',
          message: error.toString(),
          stack: stack.toString(),
        );
      }
      return priorDispatch?.call(error, stack) ?? false;
    };
  }

  /// Pass-through for runZonedGuarded's onError signature.
  static void onZonedError(Object error, StackTrace stack) {
    if (kDebugMode) return;
    _send(level: 'fatal', message: error.toString(), stack: stack.toString());
  }

  static String _platform() {
    if (kIsWeb) return 'web';
    try {
      if (Platform.isIOS) return 'ios';
      if (Platform.isAndroid) return 'android';
    } catch (_) {/* unsupported on web */}
    return 'other';
  }

  static Future<void> _send({
    required String level,
    required String message,
    String? stack,
  }) async {
    try {
      final client = Supabase.instance.client;
      await client.rpc('log_app_error', params: {
        'p_level': level,
        'p_message': message,
        'p_stack': stack,
        'p_platform': _platform(),
        'p_app_version': _appVersion,
        'p_build': _build,
        'p_context': null,
      });
    } catch (_) {
      // Logging must never throw. If Supabase is unreachable we drop
      // the error on the floor; the user is already in a bad place.
    }
  }
}
