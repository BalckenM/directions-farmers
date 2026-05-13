import 'app_exception.dart';

/// Sealed failure hierarchy used in repository return types (Result pattern).
///
/// Repositories catch [AppException]s and convert them into [Failure]s so
/// that the domain/presentation layer remains decoupled from exception types.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';

  /// Factory to convert any [AppException] into the appropriate [Failure].
  factory Failure.fromException(AppException e) => switch (e) {
        NetworkException() => NetworkFailure(e.message, statusCode: e.statusCode),
        CacheException() => CacheFailure(e.message),
        ValidationException() => ValidationFailure(e.message, field: e.field),
        NotFoundException() => NotFoundFailure(e.message, id: e.id),
        UnauthorisedException() => UnauthorisedFailure(e.message),
        UnexpectedException() => UnexpectedFailure(e.message),
      };
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {this.statusCode});
  final int? statusCode;
}

final class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.field});
  final String? field;
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {this.id});
  final String? id;
}

final class UnauthorisedFailure extends Failure {
  const UnauthorisedFailure(super.message);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
