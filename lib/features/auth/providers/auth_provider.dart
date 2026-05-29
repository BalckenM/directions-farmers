import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_app/core/auth/user_role.dart';
import 'package:mobile_app/core/providers/secure_storage_provider.dart';
import 'package:mobile_app/core/providers/shared_preferences_provider.dart';
import 'package:mobile_app/features/auth/data/auth_data_source.dart';
import 'package:mobile_app/features/auth/data/auth_mock_data_source.dart';
import 'package:mobile_app/features/auth/models/auth_state.dart';
import 'package:mobile_app/features/auth/models/auth_user.dart';

export '../data/auth_mock_data_source.dart'
    show kSubscriptionPlans, kCountryProvinces, FarmerModules, SubscriptionPlan;

const _kOnboardingKey = 'has_completed_onboarding';
const _kIntroKey = 'has_seen_intro';

// ── Provider for the data source ─────────────────────────────────────────────
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthMockDataSource(
    ref.read(sharedPreferencesProvider),
    ref.read(secureStorageProvider),
  );
});

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // Restore session from secure storage on cold start.
    final ds = ref.read(authDataSourceProvider);
    final user = await ds.restoreSession();
    if (user != null) {
      // Defer setRole past the current build frame — Riverpod 3.x forbids
      // modifying another provider synchronously during initialization.
      Future.microtask(
        () => ref
            .read(userRoleProvider.notifier)
            .setRole(UserRoleX.fromString(user.role)),
      );
      return AuthAuthenticated(
        user: user,
        accessToken: 'mock_token_${user.id}',
      );
    }
    return const AuthUnauthenticated();
  }

  // ── Sign In ──────────────────────────────────────────────────────────────────
  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final ds = ref.read(authDataSourceProvider);
      final user = await ds.signIn(email: email, password: password);
      ref
          .read(userRoleProvider.notifier)
          .setRole(UserRoleX.fromString(user.role));
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
      final ds = ref.read(authDataSourceProvider);
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
      ref
          .read(userRoleProvider.notifier)
          .setRole(UserRoleX.fromString(user.role));
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
    await ref.read(authDataSourceProvider).clearSession();
    ref
        .read(userRoleProvider.notifier)
        .setRole(UserRole.farmWorker); // reset on sign-out
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
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

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

/// All staff accounts on the current farm.
/// Returns an empty list if the current user is not signed in.
final teamMembersProvider = Provider<List<AuthUser>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  // Owner's own farmOwnerId is their id; staff farmOwnerId points to the owner.
  final ownerId = user.isOwner ? user.id : (user.farmOwnerId ?? user.id);
  return ref.read(authDataSourceProvider).getTeamMembers(ownerId);
});

/// True when the user is on a trial plan that expires within 7 days.
final trialExpiringProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  if (user.subscriptionStatus != 'trial') return false;
  final endsAt = user.trialEndsAt;
  if (endsAt == null) return false;
  return endsAt.isBefore(DateTime.now().add(const Duration(days: 7)));
});

/// Days remaining in the current trial, or null if not on trial.
final trialDaysRemainingProvider = Provider<int?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  if (user.subscriptionStatus != 'trial') return null;
  final endsAt = user.trialEndsAt;
  if (endsAt == null) return null;
  final diff = endsAt.difference(DateTime.now()).inDays;
  return diff.clamp(0, 9999);
});
