import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/core/env/app_env.dart';
import 'package:ascento_abacus/core/network/token_manager.dart';
import 'package:ascento_abacus/core/constants/api_endpoints.dart';

/// Dedicated service for handling JWT access token renewal.
///
/// Separated from [AuthService] to break circular dependency:
///   - AuthInterceptor depends on refresh logic
///   - AuthService depends on DioClient (which has the interceptor)
///
/// By isolating refresh into its own service with a bare [Dio] instance
/// (no interceptors), we avoid infinite 401 ↔ refresh loops.
class TokenRefreshService {
  final Dio _plainDio;
  final TokenManager _tokenManager;

  /// Mutex flag to prevent concurrent refresh calls
  bool _isRefreshing = false;

  /// Completer for waiting requests during an active refresh
  Completer<String?>? _refreshCompleter;

  TokenRefreshService({
    required Dio plainDio,
    required TokenManager tokenManager,
  })  : _plainDio = plainDio,
        _tokenManager = tokenManager;

  /// Attempts to refresh the access token using the stored refresh token.
  ///
  /// Returns the new access token on success, or `null` on failure.
  /// Concurrent callers will wait on the same [Completer] so only one
  /// network call is made per refresh cycle.
  Future<String?> refreshAccessToken(String refreshToken) async {
    // If already refreshing, wait for the in-flight result
    if (_isRefreshing && _refreshCompleter != null) {
      AppLogger.debug('Refresh already in progress — waiting on existing call...');
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();

    try {
      AppLogger.info('🔄 Initiating token refresh request...');

      final response = await _plainDio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Empty refresh response body');
      }

      final newAccessToken = data['accessToken'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;
      final expiresIn = data['expiresIn'] as int?; // seconds

      if (newAccessToken == null || newAccessToken.isEmpty) {
        throw Exception('No access token in refresh response');
      }

      // Persist the new token pair
      await _tokenManager.saveTokenPair(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken ?? refreshToken,
        expiresAt: expiresIn != null
            ? DateTime.now().add(Duration(seconds: expiresIn))
            : null,
      );

      AppLogger.info('✅ Token refresh successful.');
      _refreshCompleter!.complete(newAccessToken);
      return newAccessToken;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Token refresh failed', e, stackTrace);

      // Clear tokens on irrecoverable refresh failure
      await _tokenManager.clearTokens();

      _refreshCompleter!.complete(null);
      return null;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }
}

// ---------------------------------------------------------------------------
// Riverpod Providers
// ---------------------------------------------------------------------------

/// A bare Dio instance with no interceptors, used exclusively for
/// token refresh calls to avoid interceptor loops.
final _plainDioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envProvider);
  return Dio(BaseOptions(
    baseUrl: env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
});

final tokenRefreshServiceProvider = Provider<TokenRefreshService>((ref) {
  final plainDio = ref.watch(_plainDioProvider);
  final tokenManager = ref.watch(tokenManagerProvider);
  return TokenRefreshService(
    plainDio: plainDio,
    tokenManager: tokenManager,
  );
});
