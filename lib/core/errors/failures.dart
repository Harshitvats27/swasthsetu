import 'package:equatable/equatable.dart';

/// Base failure class for use with [dartz.Either] in the data/domain layers.
/// Every feature should extend this to define its own concrete failures.
///
/// Usage:
/// ```dart
/// Either<Failure, User> result = await repository.login(phone, otp);
/// result.fold(
///   (failure) => emit(AuthError(failure.message)),
///   (user)    => emit(AuthSuccess(user)),
/// );
/// ```
abstract class Failure extends Equatable {
  const Failure({required this.message, this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message];
}

// ── Common failures ───────────────────────────────────────────────────────────

/// Thrown when there is no internet connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.stackTrace,
  });
}

/// Thrown on unexpected server / HTTP errors.
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Something went wrong. Please try again later.',
    super.stackTrace,
    this.statusCode,
  });

  final int? statusCode;

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Thrown when a local cache read/write fails.
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to read/write local data.',
    super.stackTrace,
  });
}

/// Thrown on Firebase Auth specific errors.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.stackTrace, this.code});

  final String? code;

  @override
  List<Object?> get props => [...super.props, code];
}

/// Thrown when validation rules are not met.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Thrown when a requested resource is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'The requested resource was not found.'});
}

/// Thrown when the user does not have permission.
class PermissionFailure extends Failure {
  const PermissionFailure({super.message = 'Permission denied.'});
}

/// Catch-all for unexpected failures.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred.',
    super.stackTrace,
  });
}
