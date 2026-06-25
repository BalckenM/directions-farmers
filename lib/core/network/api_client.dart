import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_app/core/config/app_environment.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/providers/secure_storage_provider.dart';
import 'package:mobile_app/features/auth/data/auth_remote_data_source.dart';

/// Signals that the backend returned 402 (subscription inactive).
/// The router watches this and redirects to [AppRoutes.billingInactive].
final subscriptionInactiveProvider =
    NotifierProvider<_SubscriptionInactiveNotifier, bool>(
      _SubscriptionInactiveNotifier.new,
    );

class _SubscriptionInactiveNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setInactive() => state = true;
  void reset() => state = false;
}

/// Dio HTTP client with automatic Bearer-token injection and 401 handling.
///
/// Use [apiClientProvider] to obtain an instance from Riverpod.
/// Use [apiDioProvider] when you only need the raw [Dio] (e.g. in data sources).
class ApiClient {
  ApiClient(this.dio);

  /// The shared [Dio] instance — pre-configured with base URL, timeout, and auth.
  final Dio dio;

  // ── Convenience accessors ────────────────────────────────────────────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {Object? data}) =>
      dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(String path, {Object? data}) =>
      dio.put<T>(path, data: data);

  Future<Response<T>> patch<T>(String path, {Object? data}) =>
      dio.patch<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => dio.delete<T>(path);
}

/// Provides the single, shared [Dio] instance for the entire app.
/// Configured with:
///   • Base URL from [AppEnvironment.apiBaseUrl] (single source of truth)
///   • Timeouts from [AppConstants]
///   • Auth token injection via secure storage
///   • Automatic 401 → token refresh → retry
final apiDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppEnvironment.apiBaseUrl,
      connectTimeout: AppConstants.apiConnectTimeout,
      receiveTimeout: AppConstants.apiReceiveTimeout,
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(_AuthInterceptor(ref, dio));

  return dio;
});

/// Riverpod provider for [ApiClient] (wraps the shared Dio).
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(apiDioProvider));
});

// ── Internal auth interceptor with auto-refresh ───────────────────────────────

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._ref, this._dio);

  final Ref _ref;
  final Dio _dio;

  /// Completer used to queue requests while a token refresh is in progress.
  Completer<String?>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final secure = _ref.read(secureStorageProvider);
    final token = await secure.read(kAccessTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;

    // 402 → subscription inactive; signal the app and let the error propagate
    if (statusCode == 402) {
      _ref.read(subscriptionInactiveProvider.notifier).setInactive();
      return handler.next(err);
    }

    if (statusCode != 401) {
      return handler.next(err);
    }

    // Don't retry auth endpoints to avoid infinite loops
    final path = err.requestOptions.path;
    if (path.contains('/auth/refresh') ||
        path.contains('/auth/login') ||
        path.contains('/auth/register')) {
      _ref.read(secureStorageProvider).delete(kAccessTokenKey);
      _ref.read(secureStorageProvider).delete(kRefreshTokenKey);
      return handler.next(err);
    }

    // Attempt token refresh
    final newToken = await _attemptRefresh();
    if (newToken == null) {
      // Refresh failed — clear tokens, let 401 propagate
      await _ref.read(secureStorageProvider).delete(kAccessTokenKey);
      await _ref.read(secureStorageProvider).delete(kRefreshTokenKey);
      return handler.next(err);
    }

    // Retry the original request with the new token
    final opts = err.requestOptions;
    opts.headers['Authorization'] = 'Bearer $newToken';
    try {
      final response = await _dio.fetch(opts);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// Performs a single token refresh, queuing concurrent callers.
  Future<String?> _attemptRefresh() async {
    // If a refresh is already in progress, wait for it
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String?>();

    try {
      final secure = _ref.read(secureStorageProvider);
      final refreshToken = await secure.read(kRefreshTokenKey);

      if (refreshToken == null || refreshToken.isEmpty) {
        _refreshCompleter!.complete(null);
        return null;
      }

      // Use a separate Dio instance to avoid interceptor loops
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppEnvironment.apiBaseUrl,
          connectTimeout: AppConstants.apiTimeout,
          receiveTimeout: AppConstants.apiTimeout,
          headers: {'Accept': 'application/json'},
        ),
      );

      final response = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      // Backend returns flat { access_token, refresh_token, user } — no data wrapper
      final data = response.data!;
      final newAccessToken = data['access_token'] as String;
      final newRefreshToken = data['refresh_token'] as String;

      await secure.write(kAccessTokenKey, newAccessToken);
      await secure.write(kRefreshTokenKey, newRefreshToken);

      _refreshCompleter!.complete(newAccessToken);
      return newAccessToken;
    } catch (_) {
      _refreshCompleter!.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }
}
