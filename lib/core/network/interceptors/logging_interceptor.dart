import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';

/// Production-grade structured logging interceptor for Dio.
///
/// Unlike Dio's built-in [LogInterceptor], this interceptor:
///   - Formats output as structured key-value logs
///   - Truncates large response bodies to prevent log flooding
///   - Calculates and logs request duration
///   - Redacts sensitive headers (Authorization, Cookie)
///   - Can be toggled globally via [enabled]
///
/// Logs are routed through [AppLogger] to maintain consistent formatting
/// across the entire Ascento Abacus application.
class AppLoggingInterceptor extends Interceptor {
  final bool enabled;
  final int maxBodyLogLength;
  final bool redactAuth;

  /// Headers whose values should be masked in logs
  static const _sensitiveHeaders = {'authorization', 'cookie', 'set-cookie'};

  AppLoggingInterceptor({
    this.enabled = true,
    this.maxBodyLogLength = 2000,
    this.redactAuth = true,
  });

  // ---------------------------------------------------------------------------
  // Request Logging
  // ---------------------------------------------------------------------------

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!enabled) return handler.next(options);

    // Store request start time for duration calculation
    options.extra['_requestStartTime'] = DateTime.now().millisecondsSinceEpoch;

    final buffer = StringBuffer();
    buffer.writeln('');
    buffer.writeln('┌─────────────────────────────────────────────────');
    buffer.writeln('│ 📤 REQUEST');
    buffer.writeln('│ Method:  ${options.method}');
    buffer.writeln('│ URL:     ${options.uri}');
    buffer.writeln('│ Headers: ${_formatHeaders(options.headers)}');

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('│ Query:   ${options.queryParameters}');
    }

    if (options.data != null) {
      buffer.writeln('│ Body:    ${_truncate(_formatBody(options.data))}');
    }

    buffer.writeln('└─────────────────────────────────────────────────');

    AppLogger.debug(buffer.toString());
    handler.next(options);
  }

  // ---------------------------------------------------------------------------
  // Response Logging
  // ---------------------------------------------------------------------------

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!enabled) return handler.next(response);

    final duration = _calculateDuration(response.requestOptions);
    final buffer = StringBuffer();

    buffer.writeln('');
    buffer.writeln('┌─────────────────────────────────────────────────');
    buffer.writeln('│ 📥 RESPONSE');
    buffer.writeln('│ Status:   ${response.statusCode} ${response.statusMessage}');
    buffer.writeln('│ URL:      [${response.requestOptions.method}] ${response.requestOptions.uri}');
    buffer.writeln('│ Duration: ${duration}ms');
    buffer.writeln('│ Body:     ${_truncate(_formatBody(response.data))}');
    buffer.writeln('└─────────────────────────────────────────────────');

    // Use info for success, warning for non-2xx success
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      AppLogger.debug(buffer.toString());
    } else {
      AppLogger.warning(buffer.toString());
    }

    handler.next(response);
  }

  // ---------------------------------------------------------------------------
  // Error Logging
  // ---------------------------------------------------------------------------

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enabled) return handler.next(err);

    final duration = _calculateDuration(err.requestOptions);
    final buffer = StringBuffer();

    buffer.writeln('');
    buffer.writeln('┌─────────────────────────────────────────────────');
    buffer.writeln('│ ❌ ERROR');
    buffer.writeln('│ Type:     ${err.type}');
    buffer.writeln('│ Status:   ${err.response?.statusCode ?? "N/A"}');
    buffer.writeln('│ URL:      [${err.requestOptions.method}] ${err.requestOptions.uri}');
    buffer.writeln('│ Duration: ${duration}ms');
    buffer.writeln('│ Message:  ${err.message}');

    if (err.response?.data != null) {
      buffer.writeln('│ Body:     ${_truncate(_formatBody(err.response?.data))}');
    }

    buffer.writeln('└─────────────────────────────────────────────────');

    AppLogger.error(buffer.toString());
    handler.next(err);
  }

  // ---------------------------------------------------------------------------
  // Formatting Helpers
  // ---------------------------------------------------------------------------

  /// Calculates elapsed time since request start (stored in extras).
  int _calculateDuration(RequestOptions options) {
    final startTime = options.extra['_requestStartTime'] as int?;
    if (startTime == null) return -1;
    return DateTime.now().millisecondsSinceEpoch - startTime;
  }

  /// Formats headers map, redacting sensitive values.
  String _formatHeaders(Map<String, dynamic> headers) {
    if (!redactAuth) return headers.toString();

    final sanitised = Map<String, dynamic>.from(headers);
    for (final key in sanitised.keys.toList()) {
      if (_sensitiveHeaders.contains(key.toLowerCase())) {
        sanitised[key] = '***REDACTED***';
      }
    }
    return sanitised.toString();
  }

  /// Formats request/response body for logging.
  String _formatBody(dynamic body) {
    if (body == null) return 'null';
    if (body is Map || body is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(body);
      } catch (_) {
        return body.toString();
      }
    }
    if (body is FormData) {
      return 'FormData(fields: ${body.fields.length}, files: ${body.files.length})';
    }
    return body.toString();
  }

  /// Truncates long strings to prevent log flooding.
  String _truncate(String text) {
    if (text.length <= maxBodyLogLength) return text;
    return '${text.substring(0, maxBodyLogLength)}... [TRUNCATED ${text.length - maxBodyLogLength} chars]';
  }
}
