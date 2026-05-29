import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:mobile_app/core/services/firebase_service.dart';

/// Thin wrapper around [FirebaseAnalytics].
///
/// All methods are no-ops when Firebase is disabled or not yet initialized.
class AnalyticsService {
  AnalyticsService._();

  static FirebaseAnalytics? get _instance =>
      FirebaseService.isInitialized ? FirebaseAnalytics.instance : null;

  // ── Standard events ────────────────────────────────────────────────────────

  static Future<void> logLogin({String method = 'email'}) async {
    await _instance?.logLogin(loginMethod: method);
  }

  static Future<void> logLogout() async {
    await _instance?.logEvent(name: 'logout');
  }

  static Future<void> logScreenView(String screenName) async {
    await _instance?.logScreenView(screenName: screenName);
  }

  // ── Domain events ─────────────────────────────────────────────────────────

  static Future<void> logAnimalAdded(String species) async {
    await _instance?.logEvent(
      name: 'animal_added',
      parameters: {'species': species},
    );
  }

  static Future<void> logRecordCreated(String recordType) async {
    await _instance?.logEvent(
      name: 'record_created',
      parameters: {'record_type': recordType},
    );
  }

  static Future<void> logModuleOpened(String module) async {
    await _instance?.logEvent(
      name: 'module_opened',
      parameters: {'module': module},
    );
  }

  // ── User properties ───────────────────────────────────────────────────────

  static Future<void> setUserProperties({
    required String userId,
    required String plan,
  }) async {
    if (_instance == null) return;
    await _instance!.setUserId(id: userId);
    await _instance!.setUserProperty(name: 'subscription_plan', value: plan);
  }
}
