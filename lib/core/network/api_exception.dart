import 'package:dio/dio.dart';

/// Unified exception hierarchy for the Ascento Abacus networking layer.
///
/// All network/API errors are normalised into this class before reaching
/// the presentation layer. This guarantees that UI code never needs to
/// handle raw [DioException], platform socket errors, or JSON parsing
/// failures directly.
///
/// Usage in repositories:
/// ```dart
/// try {
///   final response = await dioClient.get('/endpoint');
///   return ApiResponse.fromJson(response.data);
/// } on DioException catch (e) {
///   throw ApiException.fromDioError(e);
/// }
/// ```
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorType;
  final String? errorCode;
  final dynamic rawData;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorType,
    this.errorCode,
    this.rawData,
  });

  // ---------------------------------------------------------------------------
  // Factory: DioException → ApiException
  // ---------------------------------------------------------------------------

  factory ApiException.fromDioError(DioException dioException) {
    String message = 'An unexpected network error occurred. Please try again.';
    int? statusCode = dioException.response?.statusCode;
    String? errorType = dioException.type.toString();
    String? errorCode;
    dynamic rawData;

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timed out. Please check your internet connection.';
        errorCode = 'CONNECTION_TIMEOUT';
        break;

      case DioExceptionType.sendTimeout:
        message = 'Request send timeout. Please try again later.';
        errorCode = 'SEND_TIMEOUT';
        break;

      case DioExceptionType.receiveTimeout:
        message = 'Server response timeout. Please try again later.';
        errorCode = 'RECEIVE_TIMEOUT';
        break;

      case DioExceptionType.badResponse:
        rawData = dioException.response?.data;
        final parsed = _parseBadResponse(dioException.response);
        message = parsed.message;
        errorCode = parsed.errorCode;
        break;

      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        errorCode = 'REQUEST_CANCELLED';
        break;

      case DioExceptionType.connectionError:
        message = 'Unable to connect to the server. Please check your internet.';
        errorCode = 'CONNECTION_ERROR';
        break;

      case DioExceptionType.badCertificate:
        message = 'Secure connection could not be established (bad certificate).';
        errorCode = 'BAD_CERTIFICATE';
        break;

      case DioExceptionType.unknown:
        if (dioException.message != null &&
            dioException.message!.contains('SocketException')) {
          message = 'No internet connection. Please connect to a stable network.';
          errorCode = 'NO_INTERNET';
        } else {
          message = dioException.message ?? 'Unknown connection issue.';
          errorCode = 'UNKNOWN';
        }
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      errorType: errorType,
      errorCode: errorCode,
      rawData: rawData,
    );
  }

  // ---------------------------------------------------------------------------
  // HTTP Status Code Factories
  // ---------------------------------------------------------------------------

  /// 400 — Bad Request / validation error
  factory ApiException.badRequest([String? detail]) => ApiException(
        message: detail ?? 'The server could not process this request. Please check your input.',
        statusCode: 400,
        errorCode: 'BAD_REQUEST',
      );

  /// 401 — Unauthorized / session expired
  factory ApiException.unauthorized([String? detail]) => ApiException(
        message: detail ?? 'Your session has expired. Please log in again.',
        statusCode: 401,
        errorCode: 'UNAUTHORIZED',
      );

  /// 403 — Forbidden / role restriction
  factory ApiException.forbidden([String? detail]) => ApiException(
        message: detail ?? 'You do not have permission to access this resource.',
        statusCode: 403,
        errorCode: 'FORBIDDEN',
      );

  /// 404 — Not Found
  factory ApiException.notFound([String? detail]) => ApiException(
        message: detail ?? 'The requested resource could not be found.',
        statusCode: 404,
        errorCode: 'NOT_FOUND',
      );

  /// 409 — Conflict (duplicate resource)
  factory ApiException.conflict([String? detail]) => ApiException(
        message: detail ?? 'A resource with the same identifier already exists.',
        statusCode: 409,
        errorCode: 'CONFLICT',
      );

  /// 422 — Unprocessable Entity (semantic validation)
  factory ApiException.unprocessable([String? detail]) => ApiException(
        message: detail ?? 'The submitted data could not be processed.',
        statusCode: 422,
        errorCode: 'UNPROCESSABLE_ENTITY',
      );

  /// 429 — Rate Limit Exceeded
  factory ApiException.rateLimited([String? detail]) => ApiException(
        message: detail ?? 'Too many requests. Please wait a moment and try again.',
        statusCode: 429,
        errorCode: 'RATE_LIMITED',
      );

  /// 500 — Internal Server Error
  factory ApiException.serverError([String? detail]) => ApiException(
        message: detail ?? 'A server error occurred. Our team has been notified.',
        statusCode: 500,
        errorCode: 'SERVER_ERROR',
      );

  /// 503 — Service Unavailable / maintenance window
  factory ApiException.serviceUnavailable([String? detail]) => ApiException(
        message: detail ?? 'Service is temporarily unavailable. Please try again later.',
        statusCode: 503,
        errorCode: 'SERVICE_UNAVAILABLE',
      );

  /// Generic unexpected error catch-all
  factory ApiException.unexpected([dynamic error]) => ApiException(
        message: error?.toString() ?? 'An unexpected error occurred.',
        errorCode: 'UNEXPECTED',
      );

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Whether this error was caused by an expired or invalid auth token
  bool get isAuthError => statusCode == 401 || errorCode == 'UNAUTHORIZED';

  /// Whether this error is a timeout variant (connect/send/receive)
  bool get isTimeout =>
      errorCode == 'CONNECTION_TIMEOUT' ||
      errorCode == 'SEND_TIMEOUT' ||
      errorCode == 'RECEIVE_TIMEOUT';

  /// Whether this error is a connectivity issue worth retrying
  bool get isRetryable =>
      isTimeout ||
      errorCode == 'CONNECTION_ERROR' ||
      errorCode == 'NO_INTERNET' ||
      statusCode == 503;

  /// Severity classification for analytics / crash reporting
  ApiExceptionSeverity get severity {
    if (statusCode != null && statusCode! >= 500) return ApiExceptionSeverity.critical;
    if (isAuthError) return ApiExceptionSeverity.warning;
    if (isTimeout) return ApiExceptionSeverity.warning;
    return ApiExceptionSeverity.info;
  }

  @override
  String toString() => 'ApiException(code: $errorCode, status: $statusCode, message: $message)';
}

// ---------------------------------------------------------------------------
// Private parser for DioException.badResponse
// ---------------------------------------------------------------------------

class _ParsedError {
  final String message;
  final String? errorCode;
  const _ParsedError(this.message, this.errorCode);
}

_ParsedError _parseBadResponse(Response? response) {
  if (response == null) {
    return const _ParsedError('No response received from the server.', null);
  }

  final statusCode = response.statusCode ?? 0;
  final data = response.data;

  // Attempt to extract structured message from JSON response body
  if (data is Map<String, dynamic>) {
    dynamic serverMessage = data['message'] ?? data['error'] ?? data['msg'];
    final serverCode = data['errorCode'] ?? data['code'];

    if (serverMessage is Map) {
      serverMessage = serverMessage['message'] ?? serverMessage['msg'] ?? serverMessage.toString();
    }

    if (serverMessage != null) {
      return _ParsedError(
        serverMessage.toString(),
        serverCode?.toString(),
      );
    }
  }

  // Fallback to HTTP status code mapping
  return _ParsedError(
    _httpStatusMessage(statusCode),
    'HTTP_$statusCode',
  );
}

String _httpStatusMessage(int statusCode) {
  switch (statusCode) {
    case 400:
      return 'Bad request. Please verify your input and try again.';
    case 401:
      return 'Authentication required. Please log in again.';
    case 403:
      return 'You do not have permission to perform this action.';
    case 404:
      return 'The requested resource was not found.';
    case 409:
      return 'This record already exists. Please review and try again.';
    case 422:
      return 'The submitted data is invalid.';
    case 429:
      return 'Too many requests. Please slow down.';
    case 500:
      return 'Internal server error. Please try again later.';
    case 502:
      return 'Bad gateway. The server is temporarily unreachable.';
    case 503:
      return 'Service under maintenance. Please try again shortly.';
    default:
      return 'Received unexpected response ($statusCode).';
  }
}

/// Severity levels for crash analytics and logging tiers
enum ApiExceptionSeverity {
  info,
  warning,
  critical,
}
