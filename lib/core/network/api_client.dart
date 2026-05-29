import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_app/core/config/app_environment.dart';
import 'package:mobile_app/core/providers/secure_storage_provider.dart';

/// Dio HTTP client with automatic Bearer-token injection and 401 handling.
///
/// Use [apiClientProvider] to obtain an instance from Riverpod.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  // ── Convenience accessors ────────────────────────────────────────────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {Object? data}) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(String path, {Object? data}) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> patch<T>(String path, {Object? data}) =>
      _dio.patch<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);
}

/// Riverpod provider that builds a [Dio] instance with auth interceptor.
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppEnvironment.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );

  // Auth interceptor — injects the stored access token on every request.
  dio.interceptors.add(_AuthInterceptor(ref));

  return ApiClient(dio);
});

// ── Internal auth interceptor ─────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._ref);

  final Ref _ref;

  static const _tokenKey = 'session';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final secure = _ref.read(secureStorageProvider);
    final token = await secure.read(_tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token is invalid / expired — clear it so the router redirects to login.
      _ref.read(secureStorageProvider).delete(_tokenKey);
    }
    handler.next(err);
  }
}
