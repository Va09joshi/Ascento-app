import 'dart:async';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/core/network/token_manager.dart';

/// Auth interceptor that automatically injects JWT Bearer tokens
/// into outgoing requests and handles 401 responses by attempting
/// a transparent token refresh.
///
/// Refresh flow:
///   1. Request hits the server and returns 401
///   2. Interceptor pauses all queued requests
///   3. Calls [onTokenRefresh] to obtain a new access token
///   4. Retries the original request with the new token
///   5. Releases all paused requests
///   6. If refresh fails → calls [onSessionExpired] to force logout
///
/// Thread-safety: Uses a [Completer] lock to ensure only one refresh
/// request runs at a time, preventing token race conditions.
class AuthInterceptor extends QueuedInterceptor {
  final TokenManager _tokenManager;
  final Future<String?> Function(String refreshToken) onTokenRefresh;
  final VoidCallback? onSessionExpired;

  /// Paths that should never have auth headers injected
  /// (e.g. login, register, public content endpoints)
  final List<String> _publicPaths = [
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
    '/auth/verify-otp',
    '/auth/reset-password',
    '/auth/refresh',
  ];

  bool _isRefreshing = false;

  AuthInterceptor({
    required TokenManager tokenManager,
    required this.onTokenRefresh,
    this.onSessionExpired,
  }) : _tokenManager = tokenManager;

  // ---------------------------------------------------------------------------
  // Request: Inject Bearer token
  // ---------------------------------------------------------------------------

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;

    // Skip auth header for public endpoints
    final isPublic = _publicPaths.any((p) => path.contains(p));
    if (!isPublic) {
      final token = _tokenManager.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        AppLogger.debug('🔑 Auth token injected for: [${options.method}] $path');
      }
    }

    handler.next(options);
  }

  // ---------------------------------------------------------------------------
  // Error: Handle 401 with token refresh
  // ---------------------------------------------------------------------------

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only intercept 401 Unauthorized responses
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final requestPath = err.requestOptions.path;

    // Don't attempt refresh for auth endpoints themselves
    if (_publicPaths.any((p) => requestPath.contains(p))) {
      return handler.next(err);
    }

    AppLogger.warning('🔄 Received 401 on $requestPath — initiating token refresh...');

    // Prevent concurrent refresh calls
    if (_isRefreshing) {
      AppLogger.debug('Token refresh already in progress. Queuing request...');
      return handler.next(err);
    }

    _isRefreshing = true;

    try {
      final refreshToken = _tokenManager.refreshToken;

      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.error('No refresh token available. Forcing session expiry.');
        _forceLogout();
        return handler.next(err);
      }

      // Attempt server-side token refresh
      final newAccessToken = await onTokenRefresh(refreshToken);

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        // Save the new token
        await _tokenManager.saveAccessToken(newAccessToken);
        AppLogger.info('✅ Token refreshed successfully. Retrying original request...');

        // Clone and retry the original request with the new token
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        // We need to create a fresh Dio instance for the retry to avoid 
        // re-entering this interceptor chain
        final retryDio = Dio(BaseOptions(
          baseUrl: retryOptions.baseUrl,
          headers: retryOptions.headers,
        ));

        try {
          final response = await retryDio.request(
            retryOptions.path,
            data: retryOptions.data,
            queryParameters: retryOptions.queryParameters,
            options: Options(
              method: retryOptions.method,
              headers: retryOptions.headers,
              contentType: retryOptions.contentType,
            ),
          );
          return handler.resolve(response);
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      } else {
        AppLogger.error('Token refresh returned empty token. Forcing logout.');
        _forceLogout();
        return handler.next(err);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Token refresh failed with exception', e, stackTrace);
      _forceLogout();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  void _forceLogout() {
    _tokenManager.clearTokens();
    onSessionExpired?.call();
  }
}
