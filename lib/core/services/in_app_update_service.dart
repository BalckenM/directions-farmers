import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Checks for and applies Android in-app updates via the Play Core library.
///
/// Only runs on Android — all methods are no-ops on other platforms.
/// Call [checkForUpdate] once after the app shell has loaded (not at startup,
/// to avoid blocking the UI).
class InAppUpdateService {
  InAppUpdateService._();

  /// Check whether an update is available and trigger the appropriate flow.
  ///
  /// - **Immediate update** (staleness ≥ 90 days or high priority ≥ 4):
  ///   shows a full-screen, mandatory update dialog.
  /// - **Flexible update** (otherwise): shows a bottom-sheet prompt and
  ///   downloads in the background.
  ///
  /// Silently swallows all errors so a Play Store outage never breaks the app.
  static Future<void> checkForUpdate() async {
    if (!defaultTargetPlatform.isAndroid) return;

    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) return;

      final isHighPriority = info.updatePriority >= 4;
      final isStale = (info.clientVersionStalenessDays ?? 0) >= 90;

      if (isHighPriority || isStale) {
        await InAppUpdate.performImmediateUpdate();
      } else {
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (e) {
      debugPrint('[InAppUpdateService] Update check failed: $e');
    }
  }
}

extension on TargetPlatform {
  bool get isAndroid => this == TargetPlatform.android;
}
