import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_app/core/services/firebase_service.dart';

/// Known Remote Config keys.
///
/// Add new feature-flag keys here as string constants.
class RemoteConfigKeys {
  RemoteConfigKeys._();

  static const enableCropModule = 'enable_crop_module';
  static const enableTraceability = 'enable_traceability';
  static const enableInsights = 'enable_insights';
  static const maintenanceMode = 'maintenance_mode';
  static const minAppVersion = 'min_app_version';
}

/// Wrapper around [FirebaseRemoteConfig].
///
/// Fetches and activates on startup; falls back to defaults when Firebase is
/// not initialized.
class RemoteConfigService {
  RemoteConfigService._();

  static const _defaults = <String, dynamic>{
    RemoteConfigKeys.enableCropModule: true,
    RemoteConfigKeys.enableTraceability: true,
    RemoteConfigKeys.enableInsights: true,
    RemoteConfigKeys.maintenanceMode: false,
    RemoteConfigKeys.minAppVersion: '1.0.0',
  };

  static bool _ready = false;

  static Future<void> initialize() async {
    if (!FirebaseService.isInitialized) return;

    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setDefaults(_defaults);
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await rc.fetchAndActivate();
      _ready = true;
    } catch (e) {
      // Non-fatal — defaults apply.
    }
  }

  static bool getBool(String key) {
    if (!_ready) {
      return (_defaults[key] as bool?) ?? false;
    }
    return FirebaseRemoteConfig.instance.getBool(key);
  }

  static String getString(String key) {
    if (!_ready) {
      return (_defaults[key] as String?) ?? '';
    }
    return FirebaseRemoteConfig.instance.getString(key);
  }
}

// ── Riverpod providers ────────────────────────────────────────────────────────

/// Provides all feature flags as a map for easy Riverpod watching.
final featureFlagsProvider = Provider<Map<String, bool>>((ref) {
  return {
    RemoteConfigKeys.enableCropModule: RemoteConfigService.getBool(
      RemoteConfigKeys.enableCropModule,
    ),
    RemoteConfigKeys.enableTraceability: RemoteConfigService.getBool(
      RemoteConfigKeys.enableTraceability,
    ),
    RemoteConfigKeys.enableInsights: RemoteConfigService.getBool(
      RemoteConfigKeys.enableInsights,
    ),
    RemoteConfigKeys.maintenanceMode: RemoteConfigService.getBool(
      RemoteConfigKeys.maintenanceMode,
    ),
  };
});
