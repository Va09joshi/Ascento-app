import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';

/// Retry interceptor with exponential backoff for transient network failures.
///
/// Automatically retries requests that fail due to:
///   - Connection timeouts
///   - Send/receive timeouts
///   - Connection errors (no internet)
///   - 5xx server errors (503 service unavailable, 502 bad gateway, etc.)
///
/// Behaviour:
///   - First retry after ~1 second, second after ~2s, third after ~4s
///   - Adds random jitter to prevent thundering-herd stampedes
///   - Skips retry for client errors (4xx), cancellations, and bad certs
///   - Respects an optional list of non-retryable HTTP methods (e.g. POST)
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;

  /// HTTP methods that should NOT be retried (to prevent duplicate side-effects).
  /// By default, POST is included since it's not idempotent.
  final Set<String> nonRetryableMethods;

  /// HTTP status codes that should trigger a retry.
  final Set<int> retryableStatusCodes;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
    Set<String>? nonRetryableMethods,
    Set<int>? retryableStatusCodes,
  })  : nonRetryableMethods = nonRetryableMethods ?? {},
        retryableStatusCodes = retryableStatusCodes ?? {500, 502, 503, 504};

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final attempt = _getRetryCount(err.requestOptions);
    final method = err.requestOptions.method.toUpperCase();

    // Check if this request method is non-retryable
    if (nonRetryableMethods.contains(method)) {
      AppLogger.debug('⏭️ Retry skipped: $method is non-retryable.');
      return handler.next(err);
    }

    // Check if the error type is retryable
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    // Check if max retries exhausted
    if (attempt >= maxRetries) {
      AppLogger.warning('❌ Max retries ($maxRetries) exhausted for '
          '[${err.requestOptions.method}] ${err.requestOptions.path}');
      return handler.next(err);
    }

    final nextAttempt = attempt + 1;
    final delay = _calculateDelay(nextAttempt);

    AppLogger.info('🔁 Retry $nextAttempt/$maxRetries for '
        '[${err.requestOptions.method}] ${err.requestOptions.path} '
        'after ${delay.inMilliseconds}ms');

    // Wait with exponential backoff + jitter
    await Future.delayed(delay);

    // Tag the request with the updated retry count
    err.requestOptions.extra['_retryCount'] = nextAttempt;

    try {
      final response = await dio.request(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
          contentType: err.requestOptions.contentType,
          extra: err.requestOptions.extra,
        ),
        cancelToken: err.requestOptions.cancelToken,
        onSendProgress: err.requestOptions.onSendProgress,
        onReceiveProgress: err.requestOptions.onReceiveProgress,
      );
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Determines whether a DioException should trigger retry logic.
  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        return retryableStatusCodes.contains(statusCode);

      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }

  /// Extracts the current retry count from the request's extra metadata.
  int _getRetryCount(RequestOptions options) {
    return options.extra['_retryCount'] as int? ?? 0;
  }

  /// Calculates exponential backoff with random jitter.
  /// 
  /// Formula: `baseDelay * 2^(attempt-1) + random(0..500ms)`
  Duration _calculateDelay(int attempt) {
    final exponential = baseDelay * pow(2, attempt - 1);
    final jitter = Duration(milliseconds: Random().nextInt(500));
    return exponential + jitter;
  }
}
