import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/shared_preferences_provider.dart';

const _kAuthKey = 'auth_logged_in';
const _kOnboardingKey = 'has_completed_onboarding';

/// Tracks whether the user has completed login / onboarding.
/// State is persisted to [SharedPreferences] so it survives app restarts.
class AuthNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(_kAuthKey) ?? false;
  }

  void logIn() {
    state = true;
    ref.read(sharedPreferencesProvider).setBool(_kAuthKey, true);
  }

  void logOut() {
    state = false;
    ref.read(sharedPreferencesProvider).setBool(_kAuthKey, false);
  }

  void markOnboardingDone() {
    ref.read(sharedPreferencesProvider).setBool(_kOnboardingKey, true);
  }
}

final authProvider = NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

/// Whether the user has ever completed onboarding on this device.
final onboardingDoneProvider = Provider<bool>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return prefs.getBool(_kOnboardingKey) ?? false;
});
