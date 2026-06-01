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

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    final data = response.data!['data'] as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;

    // Persist tokens
    await _secureStorage.write(_kAccessTokenKey, accessToken);
    await _secureStorage.write(_kRefreshTokenKey, refreshToken);

    // Fetch full user profile
    return _fetchAndCacheProfile(accessToken);
  }

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
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        'farmName': farmName,
        'country': country,
        'province': province,
        'subscriptionPlan': subscriptionPlan,
        'activatedModules': activatedModules,
      },
    );

    final data = response.data!['data'] as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;

    // Persist tokens
    await _secureStorage.write(_kAccessTokenKey, accessToken);
    await _secureStorage.write(_kRefreshTokenKey, refreshToken);

    // Fetch full user profile
    return _fetchAndCacheProfile(accessToken);
  }

  @override
  Future<SocialLoginResult> socialLogin({
    required String provider,
    required String idToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/social',
      data: {'provider': provider, 'idToken': idToken},
    );

    final data = response.data!['data'] as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;
    final isNewUser = data['isNewUser'] as bool? ?? false;

    // Persist tokens
    await _secureStorage.write(_kAccessTokenKey, accessToken);
    await _secureStorage.write(_kRefreshTokenKey, refreshToken);

    // Fetch full user profile
    final user = await _fetchAndCacheProfile(accessToken);
    return SocialLoginResult(user: user, isNewUser: isNewUser);
  }

  @override
  Future<AuthUser?> restoreSession() async {
    final accessToken = await _secureStorage.read(_kAccessTokenKey);
    final refreshToken = await _secureStorage.read(_kRefreshTokenKey);

    if (accessToken == null || accessToken.isEmpty) {
      // Try refresh if we have a refresh token
      if (refreshToken != null && refreshToken.isNotEmpty) {
        return _refreshAndRestore(refreshToken);
      }
      return null;
    }

    // Try to use the current access token
    try {
      return await _fetchAndCacheProfile(accessToken);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 &&
          refreshToken != null &&
          refreshToken.isNotEmpty) {
        // Access token expired, try refresh
        return _refreshAndRestore(refreshToken);
      }
      // If refresh also fails, clear everything
      await clearSession();
      return null;
    }
  }

  @override
  Future<void> clearSession() async {
    final refreshToken = await _secureStorage.read(_kRefreshTokenKey);

    // Attempt to call logout endpoint
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
      } catch (_) {
        // Best-effort — don't block sign-out on network failure
      }
    }

    await _secureStorage.delete(_kAccessTokenKey);
    await _secureStorage.delete(_kRefreshTokenKey);
    await _secureStorage.delete(_kUserKey);
  }

  @override
  List<AuthUser> getTeamMembers(String farmOwnerId) {
    // This is now async via getTeamMembersAsync — return empty for sync interface
    return const [];
  }

  /// Async version that fetches team from the API.
  Future<List<AuthUser>> getTeamMembersAsync() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/farm/team');
      final data = response.data!['data'] as List<dynamic>;
      return data
          .map((item) => AuthUser.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Invite a new staff member to the farm.
  Future<void> inviteStaff({
    required String firstName,
    required String lastName,
    required String email,
    required String role,
  }) async {
    await _dio.post('/farm/staff', data: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
    });
  }

  /// Deactivate (revoke access for) a staff member.
  Future<void> deleteStaff(String staffId) async {
    await _dio.delete('/farm/staff/$staffId');
  }

  /// Forgot password — requests a reset email.
  Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/forgot-password', data: {'email': email});
  }

  /// Reset password using the token from the email link.
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await _dio.post(
      '/auth/reset-password',
      data: {'token': token, 'password': password},
    );
  }

  /// Verify email using the token from the verification link.
  Future<void> verifyEmail(String token) async {
    await _dio.get('/auth/verify-email', queryParameters: {'token': token});
  }

  /// Accept a staff invitation.
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
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
      },
    );

    final data = response.data!['data'] as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;

    await _secureStorage.write(_kAccessTokenKey, accessToken);
    await _secureStorage.write(_kRefreshTokenKey, refreshToken);

    return _fetchAndCacheProfile(accessToken);
  }

  /// Refresh tokens and return user profile, or null on failure.
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
        data: {'refreshToken': refreshToken},
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String;

      await _secureStorage.write(_kAccessTokenKey, newAccessToken);
      await _secureStorage.write(_kRefreshTokenKey, newRefreshToken);

      return TokenPair(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
    } catch (_) {
      return null;
    }
  }

  /// Fetches the user profile and caches it locally.
  Future<AuthUser> _fetchAndCacheProfile(String accessToken) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/auth/me',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );
    final userData = response.data!['data'] as Map<String, dynamic>;
    final user = AuthUser.fromJson(userData);

    // Cache the user JSON for fast cold-start fallback
    await _secureStorage.write(_kUserKey, jsonEncode(user.toJson()));

    return user;
  }

  /// Update the authenticated user's profile (farm details etc).
  Future<void> updateProfile(Map<String, dynamic> fields) async {
    await _dio.put('/auth/profile', data: fields);
  }

  /// Upgrade/create subscription plan (also activates plan modules).
  Future<void> upgradePlan(String planId) async {
    await _dio.put('/v1/subscription/upgrade', data: {'planId': planId});
  }
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
