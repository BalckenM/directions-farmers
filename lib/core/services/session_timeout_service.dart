import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Duration of inactivity before forcing re-authentication.
const _kSessionTimeout = Duration(minutes: 15);

/// Manages session inactivity timeout.
///
/// Starts a countdown on app pause/background. If the user does not return
/// within [_kSessionTimeout], the session is expired and [onSessionExpired]
/// is called. Resets the timer on any user interaction or app resume.
class SessionTimeoutService with WidgetsBindingObserver {
  SessionTimeoutService({required this.onSessionExpired});

  final VoidCallback onSessionExpired;
  Timer? _inactivityTimer;
  DateTime? _backgroundedAt;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
  }

  /// Call on every meaningful user interaction to reset the countdown.
  void recordActivity() => _resetTimer();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _backgroundedAt = DateTime.now();
        break;
      case AppLifecycleState.resumed:
        if (_backgroundedAt != null) {
          final elapsed = DateTime.now().difference(_backgroundedAt!);
          if (elapsed >= _kSessionTimeout) {
            onSessionExpired();
          } else {
            _resetTimer();
          }
          _backgroundedAt = null;
        }
        break;
      default:
        break;
    }
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_kSessionTimeout, onSessionExpired);
  }
}

/// Provider for the session timeout service.
/// Requires [onSessionExpired] to be set after provider is read.
final sessionTimeoutProvider = Provider<SessionTimeoutService>((ref) {
  final service = SessionTimeoutService(onSessionExpired: () {
    // This will be connected in the App widget
  });
  ref.onDispose(service.dispose);
  return service;
});
