import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'package:mobile_app/core/config/app_environment.dart';
import 'package:mobile_app/firebase_options.dart';

/// Wrapper around Firebase initialization.
///
/// Call [FirebaseService.initialize] once during app startup.
/// It is a no-op when [AppEnvironment.firebaseEnabled] is false (default in dev).
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;

  /// Initialize Firebase and Crashlytics.
  ///
  /// Safe to call even when [AppEnvironment.firebaseEnabled] is false — it will
  /// simply skip initialization and leave [_initialized] as false.
  static Future<void> initialize() async {
    if (!AppEnvironment.firebaseEnabled) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;

      // Route Flutter framework errors to Crashlytics.
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      // Route async / zone errors to Crashlytics.
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Disable Crashlytics collection in debug builds to avoid noise.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      );
    } catch (e, stack) {
      // Firebase initialization failures must not crash the app.
      // This typically means firebase_options.dart has not been generated yet.
      debugPrint('[FirebaseService] Initialization failed: $e\n$stack');
    }
  }

  static bool get isInitialized => _initialized;
}
