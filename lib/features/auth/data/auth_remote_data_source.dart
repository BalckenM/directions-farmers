import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:mobile_app/core/services/secure_storage_service.dart';
import 'package:mobile_app/features/auth/models/auth_user.dart';
import 'package:mobile_app/features/auth/data/auth_data_source.dart';

/// Storage keys for tokens.
const _kAccessTokenKey = 'access_token';
const _kRefreshTokenKey = 'refresh_token';
const _kUserKey = 'cached_user';

/// Real HTTP implementation of [AuthDataSource] that talks to the backend API.
class AuthRemoteDataSource implements AuthDataSource {
  AuthRemoteDataSource(this._dio, this._secureStorage);

  final Dio _dio;
  final SecureStorageService _secureStorage;

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Persists both tokens, caches user JSON, and returns the parsed [AuthUser].
  /// Reads the flat `{ access_token, refresh_token, user }` shape that every
  /// auth endpoint returns (no nested `data` wrapper on auth routes).
  Future<AuthUser> _persistAndReturn(Map<String, dynamic> body) async {
    final accessToken = body['access_token'] as String? ?? '';
    final refreshToken = body['refresh_token'] as String? ?? '';

    await _secureStorage.write(_kAccessTokenKey, accessToken);
    if (refreshToken.isNotEmpty) {
      await _secureStorage.write(_kRefreshTokenKey, refreshToken);
    }

    final userJson = body['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      // Fallback: fetch profile explicitly if not in response
      return _fetchAndCacheProfile(accessToken);
    }
    final user = AuthUser.fromJson(userJson);
    await _secureStorage.write(_kUserKey, jsonEncode(user.toJson()));
    return user;
  }

  // ── Sign In ────────────────────────────────────────────────────────────────

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    final body = response.data!;

    // Backend returns mfa_required: true when TOTP is enabled on the account.
    // Throw a typed exception so AuthNotifier can transition to AuthMfaRequired.
    if (body['mfa_required'] == true) {
      throw MfaRequiredException(
        challengeToken: body['challenge_token'] as String? ?? '',
        email: email,
      );
    }

    return _persistAndReturn(body);
  }

  // ── Tenant Sign-Up (SaaS owner registration) ──────────────────────────────

  @override
  Future<AuthUser> register({
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
    int? industryId,
  }) async {
    // Map Flutter registration fields to backend tenant-signup shape.
    // `industry_id` defaults to 1 (Agriculture) when not provided by UI.
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/tenant-signup',
      data: {
        'name': '$firstName $lastName'.trim(),
        'email': email,
        'password': password,
        'company_name': farmName,
        'plan_slug': subscriptionPlan,
        'industry_id': industryId ?? 1,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        // Pass extra fields — backend ignores unknown; helps future profile update
        'country': country,
        'province': province,
      },
    );

    final body = response.data!;

    // Tenant signup may require upfront payment for non-trial plans.
    // We persist tokens and return the user regardless; the caller (AuthNotifier)
    // should check AuthUser.subscriptionStatus == 'pending_payment' and show
    // the checkout_url from the response if present.
    return _persistAndReturn(body);
  }

  // ── Social Sign-In ─────────────────────────────────────────────────────────

  @override
  Future<SocialLoginResult> socialLogin({
    required String provider,
    required String idToken,
  }) async {
    // Map provider names to backend endpoints:
    //   microsoft → POST /auth/microsoft  (id_token field)
    //   google / apple / facebook → POST /auth/social (generic, id_token field)
    final String endpoint;
    final Map<String, dynamic> body;
    if (provider == 'microsoft') {
      endpoint = '/auth/microsoft';
      body = {'id_token': idToken};
    } else {
      endpoint = '/auth/social';
      body = {'provider': provider, 'id_token': idToken};
    }

    final response = await _dio.post<Map<String, dynamic>>(
      endpoint,
      data: body,
    );
    final responseBody = response.data!;

    final isNewUser = responseBody['is_new_user'] as bool? ?? false;
    final user = await _persistAndReturn(responseBody);
    return SocialLoginResult(user: user, isNewUser: isNewUser);
  }

  // ── MFA Challenge ──────────────────────────────────────────────────────────

  /// Completes the second step of an MFA login.
  /// [challengeToken] is received from POST /auth/login when mfa_required=true.
  /// [totpCode] is the 6-digit code from the authenticator app.
  Future<AuthUser> completeMfaChallenge({
    required String challengeToken,
    required String totpCode,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/mfa/challenge',
      data: {'challenge_token': challengeToken, 'totp_code': totpCode},
    );
    return _persistAndReturn(response.data!);
  }

  // ── Session Restore ────────────────────────────────────────────────────────

  @override
  Future<AuthUser?> restoreSession() async {
    final accessToken = await _secureStorage.read(_kAccessTokenKey);
    final refreshToken = await _secureStorage.read(_kRefreshTokenKey);

    if (accessToken == null || accessToken.isEmpty) {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        return _refreshAndRestore(refreshToken);
      }
      // Try cold-start fallback from cached user JSON
      final cachedJson = await _secureStorage.read(_kUserKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          return AuthUser.fromJson(
            jsonDecode(cachedJson) as Map<String, dynamic>,
          );
        } catch (_) {}
      }
      return null;
    }

    try {
      return await _fetchAndCacheProfile(accessToken);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 &&
          refreshToken != null &&
          refreshToken.isNotEmpty) {
        return _refreshAndRestore(refreshToken);
      }
      await clearSession();
      return null;
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────

  @override
  Future<void> clearSession() async {
    final refreshToken = await _secureStorage.read(_kRefreshTokenKey);

    // Best-effort logout: send refresh_token in body so backend can revoke it.
    // Backend also reads it from HttpOnly cookie on web — both are fine.
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _dio.post('/auth/logout', data: {'refresh_token': refreshToken});
      } catch (_) {
        // Never block local sign-out on network failure
      }
    }

    await _secureStorage.delete(_kAccessTokenKey);
    await _secureStorage.delete(_kRefreshTokenKey);
    await _secureStorage.delete(_kUserKey);
  }

  // ── Team Members ───────────────────────────────────────────────────────────

  @override
  List<AuthUser> getTeamMembers(String farmOwnerId) => const [];

  /// Async version that fetches team from the API.
  Future<List<AuthUser>> getTeamMembersAsync() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/farm/team');
      final data =
          (response.data!.containsKey('data')
                  ? response.data!['data']
                  : response.data!)
              as List<dynamic>;
      return data
          .map((item) => AuthUser.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // ── Staff Management ────────────────────────────────────────────────────────

  Future<void> inviteStaff({
    required String firstName,
    required String lastName,
    required String email,
    required String role,
  }) async {
    await _dio.post(
      '/farm/staff',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
      },
    );
  }

  Future<void> deleteStaff(String staffId) async {
    await _dio.delete('/farm/staff/$staffId');
  }

  // ── Password Management ────────────────────────────────────────────────────

  Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await _dio.post(
      '/auth/reset-password',
      data: {'token': token, 'password': password},
    );
  }

  Future<void> verifyEmail(String token) async {
    await _dio.get('/auth/verify-email', queryParameters: {'token': token});
  }

  // ── Accept Invite ──────────────────────────────────────────────────────────

  Future<AuthUser> acceptInvite({
    required String token,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/accept-invite',
      data: {
        'token': token,
        // Backend accept-invite expects `name` (full name) + `confirmPassword`
        'name': '$firstName $lastName'.trim(),
        'password': password,
        'confirmPassword': password,
      },
    );
    return _persistAndReturn(response.data!);
  }

  // ── Profile & Subscription ─────────────────────────────────────────────────

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    await _dio.put('/auth/profile', data: fields);
  }

  Future<void> upgradePlan(String planSlug) async {
    await _dio.post(
      '/billing/subscription/upgrade',
      data: {'plan_slug': planSlug},
    );
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  Future<AuthUser?> _refreshAndRestore(String refreshToken) async {
    try {
      final tokens = await refreshTokens(refreshToken);
      if (tokens == null) {
        await clearSession();
        return null;
      }
      return await _fetchAndCacheProfile(tokens.accessToken);
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  /// Calls the refresh endpoint and updates stored tokens.
  /// Returns the new token pair, or null on failure.
  Future<TokenPair?> refreshTokens(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        // Send refresh_token in body for mobile (backend also accepts from cookie on web)
        data: {'refresh_token': refreshToken},
      );
      final body = response.data!;
      final newAccessToken = body['access_token'] as String? ?? '';
      final newRefreshToken = body['refresh_token'] as String? ?? '';

      if (newAccessToken.isEmpty) return null;

      await _secureStorage.write(_kAccessTokenKey, newAccessToken);
      if (newRefreshToken.isNotEmpty) {
        await _secureStorage.write(_kRefreshTokenKey, newRefreshToken);
      }

      return TokenPair(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken.isNotEmpty
            ? newRefreshToken
            : refreshToken,
      );
    } catch (_) {
      return null;
    }
  }

  /// GET /auth/me — backend returns the JWT payload directly (no `data` wrapper).
  Future<AuthUser> _fetchAndCacheProfile(String accessToken) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    // /auth/me returns req.user directly — no `data` wrapper
    final user = AuthUser.fromJson(response.data!);
    await _secureStorage.write(_kUserKey, jsonEncode(user.toJson()));
    return user;
  }
}

/// Thrown by [AuthRemoteDataSource.signIn] when the backend requires
/// a TOTP code to complete login (MFA enabled on account).
class MfaRequiredException implements Exception {
  const MfaRequiredException({
    required this.challengeToken,
    required this.email,
  });

  final String challengeToken;
  final String email;
}

/// A simple pair of access + refresh tokens.
class TokenPair {
  const TokenPair({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;
}

/// Exported token key constants for use in the interceptor.
const kAccessTokenKey = _kAccessTokenKey;
const kRefreshTokenKey = _kRefreshTokenKey;
