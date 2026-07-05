import 'package:dio/dio.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/core/network/api_exception.dart';
import 'package:ascento_abacus/core/errors/failures.dart';

/// Centralised error handler that maps raw exceptions into typed [Failure]
/// objects and logs them appropriately.
///
/// Usage in repositories:
/// ```dart
/// try {
///   final response = await dioClient.safeGet<User>('/profile');
///   return Right(response.data!);
/// } catch (e) {
///   return Left(ErrorHandler.handle(e));
/// }
/// ```
class ErrorHandler {
  ErrorHandler._();

  /// Maps any exception into a typed [Failure] for the domain layer.
  static Failure handle(dynamic error, [StackTrace? stackTrace]) {
    AppLogger.error('ErrorHandler caught: $error', error, stackTrace);

    if (error is ApiException) {
      return _mapApiException(error);
    }

    if (error is DioException) {
      return _mapDioException(error);
    }

    if (error is FormatException) {
      return const ServerFailure(
        message: 'Invalid data format received from server.',
        code: 'FORMAT_ERROR',
      );
    }

    if (error is TypeError) {
      return const ServerFailure(
        message: 'Unexpected data type received. Please update the app.',
        code: 'TYPE_ERROR',
      );
    }

    return UnexpectedFailure(
      message: error?.toString() ?? 'An unknown error occurred.',
    );
  }

  /// Maps [ApiException] → typed [Failure] based on error code / status.
  static Failure _mapApiException(ApiException error) {
    // Auth failures
    if (error.isAuthError) {
      return AuthFailure(message: error.message);
    }

    // Timeout failures
    if (error.isTimeout) {
      return TimeoutFailure(message: error.message);
    }

    // Permission failures
    if (error.statusCode == 403) {
      return PermissionFailure(message: error.message);
    }

    // Network connectivity
    if (error.errorCode == 'CONNECTION_ERROR' || error.errorCode == 'NO_INTERNET') {
      return NetworkFailure(message: error.message);
    }

    // Server errors (5xx)
    if (error.statusCode != null && error.statusCode! >= 500) {
      return ServerFailure(
        message: error.message,
        statusCode: error.statusCode,
        code: error.errorCode,
      );
    }

    // Client errors (4xx)
    if (error.statusCode != null && error.statusCode! >= 400) {
      return ServerFailure(
        message: error.message,
        statusCode: error.statusCode,
        code: error.errorCode,
      );
    }

    return UnexpectedFailure(message: error.message);
  }

  /// Maps raw [DioException] → typed [Failure] (fallback for uncaught Dio errors).
  static Failure _mapDioException(DioException error) {
    return _mapApiException(ApiException.fromDioError(error));
  }

  /// Extracts a user-friendly message from any error object.
  /// Safe for direct display in SnackBars / dialogs.
  static String getUserMessage(dynamic error) {
    if (error is Failure) return error.message;
    if (error is ApiException) return error.message;
    if (error is Exception) return error.toString().replaceAll('Exception: ', '');
    return 'Something went wrong. Please try again.';
  }
}
