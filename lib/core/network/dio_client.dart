import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/env/app_env.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/core/network/api_exception.dart';
import 'package:ascento_abacus/core/network/models/api_response.dart';
import 'package:ascento_abacus/core/network/token_manager.dart';
import 'package:ascento_abacus/core/network/interceptors/auth_interceptor.dart';
import 'package:ascento_abacus/core/network/interceptors/retry_interceptor.dart';
import 'package:ascento_abacus/core/network/interceptors/logging_interceptor.dart';
import 'package:ascento_abacus/core/network/services/token_refresh_service.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ascento_abacus/shared/router/app_router.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';

/// Production-grade Dio HTTP client for Ascento Abacus.
///
/// Features:
///   - Environment-driven base URL and timeouts
///   - Pluggable interceptor chain: Logging → Auth → Retry
///   - Typed response parsing via [safeRequest] and [safeGet]/[safePost]
///   - Multipart file upload support
///   - Centralised exception mapping to [ApiException]
///
/// Interceptor execution order (per Dio convention):
///   Request:  Logging → Auth → Retry
///   Response: Retry → Auth → Logging
///   Error:    Retry → Auth → Logging
class DioClient {
  final Dio _dio;
  final AppEnv _env;

  DioClient(
    this._dio,
    this._env, {
    AuthInterceptor? authInterceptor,
    RetryInterceptor? retryInterceptor,
    bool enableLogging = true,
  }) {
    // Base configuration from environment
    _dio
      ..options.baseUrl = _env.apiBaseUrl
      ..options.connectTimeout = Duration(milliseconds: _env.connectTimeoutMs)
      ..options.receiveTimeout = Duration(milliseconds: _env.receiveTimeoutMs)
      ..options.sendTimeout = const Duration(seconds: 30)
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

    // --- Interceptor Chain ---
    // Order matters: Logging first (captures raw request), then Auth, then Retry
    
    // 1. Structured logging interceptor
    if (_env.enableLogging && enableLogging) {
      _dio.interceptors.add(AppLoggingInterceptor(
        enabled: true,
        maxBodyLogLength: 3000,
        redactAuth: true,
      ));
    }

    // 2. Auth interceptor (Bearer token injection + 401 refresh)
    if (authInterceptor != null) {
      _dio.interceptors.add(authInterceptor);
    }

    // 3. Retry interceptor (exponential backoff for transient failures)
    if (retryInterceptor != null) {
      _dio.interceptors.add(retryInterceptor);
    }
  }

  /// Exposes the raw Dio instance for advanced use cases.
  Dio get dio => _dio;

  // ===========================================================================
  // CORE HTTP METHODS
  // ===========================================================================

  /// Sends a GET request to [path].
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Sends a POST request to [path].
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Sends a PUT request to [path].
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Sends a PATCH request to [path].
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Sends a DELETE request to [path].
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ===========================================================================
  // TYPED SAFE REQUEST WRAPPERS
  // ===========================================================================

  /// Generic typed request wrapper that parses the response through [ApiResponse].
  ///
  /// Catches all [DioException] errors and maps them to [ApiException],
  /// so callers never need to import Dio directly.
  ///
  /// Usage:
  /// ```dart
  /// final response = await dioClient.safeGet<UserModel>(
  ///   '/auth/profile',
  ///   fromJson: (json) => UserModel.fromJson(json),
  /// );
  /// if (response.success) {
  ///   final user = response.data!;
  /// }
  /// ```
  Future<ApiResponse<T>> safeGet<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return _parseResponse<T>(response, fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.unexpected(e);
    }
  }

  /// Typed POST wrapper with automatic response parsing.
  Future<ApiResponse<T>> safePost<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await post(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return _parseResponse<T>(response, fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.unexpected(e);
    }
  }

  /// Typed PUT wrapper with automatic response parsing.
  Future<ApiResponse<T>> safePut<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await put(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return _parseResponse<T>(response, fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.unexpected(e);
    }
  }

  /// Typed PATCH wrapper with automatic response parsing.
  Future<ApiResponse<T>> safePatch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await patch(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return _parseResponse<T>(response, fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.unexpected(e);
    }
  }

  /// Typed DELETE wrapper with automatic response parsing.
  Future<ApiResponse<T>> safeDelete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await delete(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return _parseResponse<T>(response, fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.unexpected(e);
    }
  }

  // ===========================================================================
  // MULTIPART FILE UPLOAD
  // ===========================================================================

  /// Uploads a file using multipart/form-data encoding.
  ///
  /// [filePath] is the local filesystem path to the file.
  /// [fieldName] is the form field name expected by the server (default: 'file').
  /// Additional [fields] can be sent alongside the file.
  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required String filePath,
    String fieldName = 'file',
    Map<String, String>? fields,
    T Function(dynamic json)? fromJson,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (fields != null) ...fields,
      });

      final response = await post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );

      return _parseResponse<T>(response, fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.unexpected(e);
    }
  }

  // ===========================================================================
  // PAGINATED REQUEST
  // ===========================================================================

  /// Fetches a paginated list endpoint and parses into [PaginatedApiResponse].
  Future<PaginatedApiResponse<T>> getPaginated<T>(
    String path, {
    required T Function(dynamic json) fromJson,
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? extraParams,
    CancelToken? cancelToken,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (extraParams != null) ...extraParams,
      };

      final response = await get(
        path,
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );

      final body = response.data as Map<String, dynamic>? ?? {};
      return PaginatedApiResponse<T>.fromJson(body, fromJsonT: fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.unexpected(e);
    }
  }

  // ===========================================================================
  // PRIVATE HELPERS
  // ===========================================================================

  /// Parses a raw Dio [Response] into a typed [ApiResponse].
  ApiResponse<T> _parseResponse<T>(
    Response response,
    T Function(dynamic json)? fromJson,
  ) {
    final body = response.data;

    // If the response is already a Map with our envelope structure, parse it
    if (body is Map<String, dynamic>) {
      return ApiResponse<T>.fromJson(body, fromJsonT: fromJson);
    }

    // Fallback: wrap raw data as a success envelope
    return ApiResponse<T>(
      success: response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300,
      message: 'Request completed',
      data: fromJson != null ? fromJson(body) : null,
      statusCode: response.statusCode,
    );
  }
}

// =============================================================================
// RIVERPOD PROVIDERS
// =============================================================================

/// Raw Dio instance — no configuration, used as injection base.
final baseDioProvider = Provider<Dio>((ref) {
  return Dio();
});

/// Fully configured DioClient with interceptor chain.
final dioClientProvider = Provider<DioClient>((ref) {
  final dio = ref.watch(baseDioProvider);
  final env = ref.watch(envProvider);
  final tokenManager = ref.watch(tokenManagerProvider);
  final tokenRefreshService = ref.watch(tokenRefreshServiceProvider);

  // Build Auth Interceptor
  final authInterceptor = AuthInterceptor(
    tokenManager: tokenManager,
    onTokenRefresh: (refreshToken) async {
      return await tokenRefreshService.refreshAccessToken(refreshToken);
    },
    onSessionExpired: () {
      AppLogger.warning('🔒 Session expired — user must re-authenticate.');
      // 1. Force the auth controller to reflect the logged out state
      ref.read(authControllerProvider.notifier).logout();
      
      // 2. Force the global router to navigate to login immediately
      ref.read(routerProvider).go(RoutePaths.login);
    },
  );

  // Build Retry Interceptor
  final retryInterceptor = RetryInterceptor(
    dio: dio,
    maxRetries: 3,
    baseDelay: const Duration(seconds: 1),
    retryableStatusCodes: {500, 502, 503, 504},
  );

  return DioClient(
    dio,
    env,
    authInterceptor: authInterceptor,
    retryInterceptor: retryInterceptor,
    enableLogging: env.enableLogging,
  );
});
