/// Base class for all FarmTrack exceptions.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a network request fails (no connectivity, timeout, HTTP error).
final class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause, this.statusCode});

  final int? statusCode;
}

/// Thrown when local cache/database operations fail.
final class CacheException extends AppException {
  const CacheException(super.message, {super.cause});
}

/// Thrown when input data fails validation.
final class ValidationException extends AppException {
  const ValidationException(super.message, {this.field});

  final String? field;
}

/// Thrown when a requested resource does not exist.
final class NotFoundException extends AppException {
  const NotFoundException(super.message, {this.id});

  final String? id;
}

/// Thrown when the user is not authorised to perform an action.
final class UnauthorisedException extends AppException {
  const UnauthorisedException([super.message = 'Unauthorised']);
}

/// Thrown for unexpected/unhandled error scenarios.
final class UnexpectedException extends AppException {
  const UnexpectedException(super.message, {super.cause});
}
