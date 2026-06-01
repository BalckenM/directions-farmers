import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_app/core/auth/user_role.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/core/providers/secure_storage_provider.dart';
import 'package:mobile_app/core/providers/shared_preferences_provider.dart';
import 'package:mobile_app/features/auth/data/auth_data_source.dart';
import 'package:mobile_app/features/auth/data/auth_remote_data_source.dart';
import 'package:mobile_app/features/auth/models/auth_state.dart';
import 'package:mobile_app/features/auth/models/auth_user.dart';

export '../data/subscription_data.dart'
    show kSubscriptionPlans, kCountryProvinces, FarmerModules, SubscriptionPlan;

const _kOnboardingKey = 'has_completed_onboarding';
const _kIntroKey = 'has_seen_intro';

// ── Provider for the data source ─────────────────────────────────────────────
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthRemoteDataSource(
    ref.read(apiDioProvider),
    ref.read(secureStorageProvider),
  );
});

/// Typed accessor for async operations (team members, forgot password, etc.)
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return ref.read(authDataSourceProvider) as AuthRemoteDataSource;
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
      final secure = ref.read(secureStorageProvider);
      final accessToken = await secure.read(kAccessTokenKey) ?? '';
      return AuthAuthenticated(
        user: user,
        accessToken: accessToken,
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
      final secure = ref.read(secureStorageProvider);
      final accessToken = await secure.read(kAccessTokenKey) ?? '';
      state = AsyncValue.data(
        AuthAuthenticated(user: user, accessToken: accessToken),
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      state = AsyncValue.data(AuthError(message));
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
      final secure = ref.read(secureStorageProvider);
      final accessToken = await secure.read(kAccessTokenKey) ?? '';
      state = AsyncValue.data(
        AuthAuthenticated(user: user, accessToken: accessToken),
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      state = AsyncValue.data(AuthError(message));
    } catch (e) {
      state = AsyncValue.data(AuthError('Unexpected error: $e'));
    }
  }

  // ── Social Sign In ───────────────────────────────────────────────────────────
  /// Signs in (or registers) via social provider. Returns true if this is a new
  /// user who needs to complete the farm setup wizard.
  Future<bool> socialSignIn({
    required String provider,
    required String idToken,
  }) async {
    state = const AsyncValue.loading();
    try {
      final ds = ref.read(authDataSourceProvider);
      final result = await ds.socialLogin(
        provider: provider,
        idToken: idToken,
      );
      ref
          .read(userRoleProvider.notifier)
          .setRole(UserRoleX.fromString(result.user.role));
      final secure = ref.read(secureStorageProvider);
      final accessToken = await secure.read(kAccessTokenKey) ?? '';
      state = AsyncValue.data(
        AuthAuthenticated(user: result.user, accessToken: accessToken),
      );
      return result.isNewUser;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      state = AsyncValue.data(AuthError(message));
      return false;
    } catch (e) {
      state = AsyncValue.data(AuthError('Unexpected error: $e'));
      return false;
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

  /// Re-fetches the user profile and updates auth state.
  /// Used after farm setup to pick up new profile fields + modules.
  Future<void> refreshSession() async {
    try {
      final ds = ref.read(authDataSourceProvider);
      final user = await ds.restoreSession();
      if (user != null) {
        ref
            .read(userRoleProvider.notifier)
            .setRole(UserRoleX.fromString(user.role));
        final secure = ref.read(secureStorageProvider);
        final accessToken = await secure.read(kAccessTokenKey) ?? '';
        state = AsyncValue.data(
          AuthAuthenticated(user: user, accessToken: accessToken),
        );
      }
    } catch (_) {
      // Silently fail — user is still authenticated
    }
  }

  /// Request a password reset email.
  Future<void> forgotPassword(String email) async {
    final ds = ref.read(authRemoteDataSourceProvider);
    await ds.forgotPassword(email);
  }

  /// Reset password with the token received via email.
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    final ds = ref.read(authRemoteDataSourceProvider);
    await ds.resetPassword(token: token, password: password);
  }

  /// Accept a staff invite and sign in.
  Future<void> acceptInvite({
    required String token,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final ds = ref.read(authRemoteDataSourceProvider);
      final user = await ds.acceptInvite(
        token: token,
        firstName: firstName,
        lastName: lastName,
        password: password,
      );
      ref
          .read(userRoleProvider.notifier)
          .setRole(UserRoleX.fromString(user.role));
      final secure = ref.read(secureStorageProvider);
      final accessToken = await secure.read(kAccessTokenKey) ?? '';
      state = AsyncValue.data(
        AuthAuthenticated(user: user, accessToken: accessToken),
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      state = AsyncValue.data(AuthError(message));
    } catch (e) {
      state = AsyncValue.data(AuthError('Unexpected error: $e'));
    }
  }

  /// Extracts a user-friendly error message from a [DioException].
  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        return error['message'] as String? ?? 'Request failed';
      }
      return data['message'] as String? ?? 'Request failed';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please check your internet.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to connect to server. Please check your internet.';
    }
    return 'Something went wrong. Please try again.';
  }

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

/// All staff accounts on the current farm (fetched from API).
final teamMembersProvider = FutureProvider<List<AuthUser>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  final ds = ref.read(authRemoteDataSourceProvider);
  return ds.getTeamMembersAsync();
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
