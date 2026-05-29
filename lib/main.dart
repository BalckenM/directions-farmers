import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/core/database/database_provider.dart';
import 'package:mobile_app/core/services/firebase_service.dart';
import 'package:mobile_app/core/services/offline_sync_service.dart';
import 'package:mobile_app/core/services/notification_service.dart';
import 'package:mobile_app/core/services/remote_config_service.dart';
import 'package:mobile_app/app.dart';
import 'package:mobile_app/core/observers/provider_logger_observer.dart';
import 'package:mobile_app/core/providers/shared_preferences_provider.dart';
import 'package:mobile_app/core/utils/logger.dart';

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

      // Initialise Firebase (Crashlytics, Analytics, Remote Config).
      // No-op when FIREBASE_ENABLED=false (default in dev).
      await FirebaseService.initialize();
      await RemoteConfigService.initialize();

      // Configure cached_network_image global cache.
      PaintingBinding.instance.imageCache.maximumSizeBytes =
          100 * 1024 * 1024; // 100 MB in-memory
      DefaultCacheManager(); // warm up the disk cache manager

      AppLogger.info('App starting', tag: 'Boot');
      AppLogger.info(
        'Log file → ${AppLogger.logFilePath ?? "not initialised"}',
        tag: 'Boot',
      );

      await NotificationService.initialize();

      final prefs = await SharedPreferences.getInstance();

      // Build the container so services can be started before runApp finishes.
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        observers: const [ProviderLoggerObserver()],
      );

      // Warm up the local database and start the offline sync flush loop.
      // The database opens lazily so this merely registers the provider.
      container.read(appDatabaseProvider);
      container.read(offlineSyncServiceProvider).startPeriodicFlush();

      runApp(
        UncontrolledProviderScope(container: container, child: const App()),
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
