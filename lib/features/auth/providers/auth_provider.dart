import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/shared_preferences_provider.dart';
import '../data/auth_mock_data_source.dart';
import '../models/auth_state.dart';
import '../models/auth_user.dart';

export '../data/auth_mock_data_source.dart'
    show kSubscriptionPlans, kCountryProvinces, FarmerModules, SubscriptionPlan;

const _kOnboardingKey = 'has_completed_onboarding';
const _kIntroKey = 'has_seen_intro';

// ── Provider for the data source ─────────────────────────────────────────────
final authMockDataSourceProvider = Provider<AuthMockDataSource>((ref) {
  return AuthMockDataSource(ref.read(sharedPreferencesProvider));
});

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // Restore session from SharedPreferences on cold start.
    final ds = ref.read(authMockDataSourceProvider);
    final user = ds.restoreSession();
    if (user != null) return AuthAuthenticated(user: user, accessToken: 'mock_token_${user.id}');
    return const AuthUnauthenticated();
  }

  // ── Sign In ──────────────────────────────────────────────────────────────────
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final ds = ref.read(authMockDataSourceProvider);
      final user = await ds.signIn(email: email, password: password);
      state = AsyncValue.data(
        AuthAuthenticated(user: user, accessToken: 'mock_token_${user.id}'),
      );
    } on MockAuthException catch (e) {
      state = AsyncValue.data(AuthError(e.message));
    } catch (e) {
      state = AsyncValue.data(AuthError('Unexpected error: $e'));
    }
  }

  // ── Register ─────────────────────────────────────────────────────────────────
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String farmName,
    required String country,
    required String province,
    required String subscriptionPlan,
    required List<String> activatedModules,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      final ds = ref.read(authMockDataSourceProvider);
      final user = await ds.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        farmName: farmName,
        country: country,
        province: province,
        subscriptionPlan: subscriptionPlan,
        activatedModules: activatedModules,
        phone: phone,
      );
      // Mark onboarding done so splash skips the intro next time.
      markOnboardingDone();
      state = AsyncValue.data(
        AuthAuthenticated(user: user, accessToken: 'mock_token_${user.id}'),
      );
    } on MockAuthException catch (e) {
      state = AsyncValue.data(AuthError(e.message));
    } catch (e) {
      state = AsyncValue.data(AuthError('Unexpected error: $e'));
    }
  }

  // ── Complete MFA ─────────────────────────────────────────────────────────────
  Future<void> completeMfa({
    required String challengeToken,
    required String totp,
  }) async {
    state = const AsyncValue.loading();
    // TODO: Verify TOTP code against the 4D Farmer API.
    state = const AsyncValue.data(AuthError('MFA not yet implemented.'));
  }

  // ── Sign Out ─────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await ref.read(authMockDataSourceProvider).clearSession();
    state = const AsyncValue.data(AuthUnauthenticated());
  }

  /// Backwards-compatible alias for [signOut].
  Future<void> logOut() => signOut();

  /// Persists the onboarding flag so the splash screen knows to skip to login.
  void markOnboardingDone() {
    ref.read(sharedPreferencesProvider).setBool(_kOnboardingKey, true);
  }

  /// Persists the intro flag so the splash screen skips intro for returning users.
  void markIntroSeen() {
    ref.read(sharedPreferencesProvider).setBool(_kIntroKey, true);
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────
final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// ── Computed selectors ───────────────────────────────────────────────────────
/// Synchronous bool used by the router guard.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).value?.isAuthenticated ?? false;
});

/// Convenience selector for the signed-in user (null when unauthenticated).
final currentUserProvider = Provider<AuthUser?>((ref) {
  final s = ref.watch(authProvider).value;
  return s is AuthAuthenticated ? s.user : null;
});

/// Whether the user has ever completed onboarding on this device.
final onboardingDoneProvider = Provider<bool>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return prefs.getBool(_kOnboardingKey) ?? false;
});

/// Whether the user has ever seen the intro slides on this device.
final hasSeenIntroProvider = Provider<bool>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return prefs.getBool(_kIntroKey) ?? false;
});
