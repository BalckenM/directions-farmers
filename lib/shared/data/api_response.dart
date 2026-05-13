import '../models/pagination_meta.dart';

/// Generic API response envelope used throughout the data layer.
class ApiResponse<T> {
  const ApiResponse({
    required this.data,
    required this.success,
    this.message,
    this.pagination,
    this.errors,
  });

  final T data;
  final bool success;
  final String? message;
  final PaginationMeta? pagination;
  final List<String>? errors;

  // ── Factories ─────────────────────────────────────────────────────────────────

  /// Wraps a single item into a successful response.
  factory ApiResponse.single(T data, {String? message}) => ApiResponse(
        data: data,
        success: true,
        message: message,
      );

  /// Wraps a list with optional pagination into a successful response.
  factory ApiResponse.list(
    T data, {
    PaginationMeta? pagination,
    String? message,
  }) =>
      ApiResponse(
        data: data,
        success: true,
        message: message,
        pagination: pagination,
      );

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) =>
      ApiResponse(
        data: fromJsonT(json['data']),
        success: json['success'] as bool? ?? true,
        message: json['message'] as String?,
        pagination: json['pagination'] == null
            ? null
            : PaginationMeta.fromJson(
                json['pagination'] as Map<String, dynamic>),
        errors: (json['errors'] as List<dynamic>?)?.cast<String>(),
      );

  ApiResponse<R> map<R>(R Function(T) transform) => ApiResponse(
        data: transform(data),
        success: success,
        message: message,
        pagination: pagination,
        errors: errors,
      );

  @override
  String toString() =>
      'ApiResponse<$T>(success: $success, message: $message)';
}
