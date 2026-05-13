import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/notification_service.dart';
import 'app.dart';
import 'core/observers/provider_logger_observer.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'core/utils/logger.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Capture Flutter framework errors (widget build failures, render errors, etc.)
      FlutterError.onError = AppLogger.captureFlutterError;

      // Capture platform-channel / async errors not caught by the zone
      PlatformDispatcher.instance.onError = AppLogger.captureZoneError;

      // Initialise file logging — writes to <documents>/logs/app_YYYY-MM-DD.log
      await AppLogger.initFileLogging();

      AppLogger.info('App starting', tag: 'Boot');
      AppLogger.info(
        'Log file → ${AppLogger.logFilePath ?? "not initialised"}',
        tag: 'Boot',
      );

      await NotificationService.initialize();

      final prefs = await SharedPreferences.getInstance();

      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          observers: const [ProviderLoggerObserver()],
          child: const App(),
        ),
      );
    },
    // Catch any errors thrown inside the zone (including unawaited futures)
    (error, stack) {
      AppLogger.error(
        'Uncaught zone error: $error',
        tag: 'Zone',
        error: error,
        stackTrace: stack,
      );
      if (kDebugMode) {
        debugPrint('🔴 [Zone] $error\n$stack');
      }
    },
  );
}
