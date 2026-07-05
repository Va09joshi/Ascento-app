/// Generic API response wrapper for Ascento Abacus
/// 
/// Standardises all backend responses into a predictable envelope.
/// Every repository method should parse raw JSON through this model
/// before handing data to the domain layer.
/// 
/// Supports:
///   - Typed data deserialization via [fromJsonT]
///   - Paginated list responses via [PaginatedApiResponse]
///   - Error/success discrimination without exceptions
class ApiResponse<T> {
  /// Whether the API call was logically successful (HTTP 2xx + success flag)
  final bool success;

  /// Human-readable server message (e.g. "Login successful", "Validation failed")
  final String message;

  /// Parsed data payload — null when [success] is false
  final T? data;

  /// Raw HTTP status code echoed back for downstream logic
  final int? statusCode;

  /// Optional server-side error code for programmatic handling
  /// e.g. "TOKEN_EXPIRED", "INVALID_ROLE", "RATE_LIMITED"
  final String? errorCode;

  /// Server timestamp (ISO 8601) when the response was generated
  final String? timestamp;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.errorCode,
    this.timestamp,
  });

  /// Factory constructor that parses a raw JSON map.
  /// 
  /// [fromJsonT] is a converter callback that turns the `data` field
  /// into the target type [T]. Pass `null` when the endpoint returns
  /// no data payload (e.g. DELETE, logout).
  /// 
  /// Backend envelope contract:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Fetched successfully",
  ///   "data": { ... },
  ///   "errorCode": null,
  ///   "timestamp": "2026-05-20T15:00:00Z"
  /// }
  /// ```
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic json)? fromJsonT,
  }) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      statusCode: json['statusCode'] as int?,
      errorCode: json['errorCode'] as String?,
      timestamp: json['timestamp'] as String?,
    );
  }

  /// Convenience factory for wrapping a successful result programmatically
  factory ApiResponse.success({required T data, String message = 'Success'}) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: 200,
    );
  }

  /// Convenience factory for creating an error response without exceptions
  factory ApiResponse.error({
    required String message,
    int? statusCode,
    String? errorCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
    );
  }

  /// Whether this response represents a failure state
  bool get isError => !success;

  @override
  String toString() => 'ApiResponse(success: $success, message: $message, '
      'statusCode: $statusCode, errorCode: $errorCode)';
}

/// Extended response model for paginated list endpoints.
/// 
/// Backend pagination contract:
/// ```json
/// {
///   "success": true,
///   "message": "Fetched page 1",
///   "data": [ ... ],
///   "pagination": {
///     "page": 1,
///     "limit": 20,
///     "totalItems": 145,
///     "totalPages": 8
///   }
/// }
/// ```
class PaginatedApiResponse<T> extends ApiResponse<List<T>> {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int limit;

  const PaginatedApiResponse({
    required super.success,
    required super.message,
    required List<T>? data,
    super.statusCode,
    super.errorCode,
    super.timestamp,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.limit,
  }) : super(data: data);

  factory PaginatedApiResponse.fromJson(
    Map<String, dynamic> json, {
    required T Function(dynamic json) fromJsonT,
  }) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return PaginatedApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: rawList.map((item) => fromJsonT(item)).toList(),
      statusCode: json['statusCode'] as int?,
      errorCode: json['errorCode'] as String?,
      timestamp: json['timestamp'] as String?,
      currentPage: pagination['page'] as int? ?? 1,
      totalPages: pagination['totalPages'] as int? ?? 1,
      totalItems: pagination['totalItems'] as int? ?? 0,
      limit: pagination['limit'] as int? ?? 20,
    );
  }

  /// Whether there are more pages available to fetch
  bool get hasNextPage => currentPage < totalPages;

  /// Whether this is the first page of results
  bool get isFirstPage => currentPage == 1;

  @override
  String toString() => 'PaginatedApiResponse(page: $currentPage/$totalPages, '
      'items: ${data?.length ?? 0}/$totalItems)';
}
