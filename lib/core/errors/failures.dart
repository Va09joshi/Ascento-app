/// Typed failure hierarchy for Ascento Abacus domain layer.
///
/// Failures represent expected error states that the UI layer can
/// handle gracefully. Unlike exceptions, failures are values — they
/// don't unwind the call stack and can be passed through [Either] or
/// result types.
///
/// Every failure carries a user-friendly [message] for direct display
/// and an optional machine-readable [code] for programmatic handling.
abstract class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Server returned an error response (4xx, 5xx).
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });
}

/// Network connectivity is unavailable.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network and try again.',
    super.code = 'NETWORK_FAILURE',
  });
}

/// JWT session has expired or token is invalid.
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Your session has expired. Please log in again.',
    super.code = 'AUTH_FAILURE',
  });
}

/// Local storage read/write operation failed.
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to load saved data. Please restart the app.',
    super.code = 'CACHE_FAILURE',
  });
}

/// Form or business logic validation failed.
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_FAILURE',
    this.fieldErrors,
  });
}

/// User does not have the required role or permission.
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'You do not have permission to access this feature.',
    super.code = 'PERMISSION_FAILURE',
  });
}

/// Request timed out.
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'The request timed out. Please try again.',
    super.code = 'TIMEOUT_FAILURE',
  });
}

/// Catch-all for unexpected errors.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code = 'UNEXPECTED_FAILURE',
  });
}
