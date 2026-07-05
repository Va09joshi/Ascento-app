import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/core/services/storage_service.dart';

/// Centralised JWT token manager for Ascento Abacus.
///
/// Provides a single source-of-truth for reading, writing, and validating
/// access & refresh tokens. Every interceptor, guard, and service reads
/// tokens through this manager instead of hitting SharedPreferences directly.
///
/// Token storage keys are private constants to prevent accidental key
/// drift across the codebase.
class TokenManager {
  final StorageService _storage;

  static const String _accessTokenKey  = 'secure_jwt_access_token';
  static const String _refreshTokenKey = 'secure_jwt_refresh_token';
  static const String _tokenExpiryKey  = 'secure_jwt_token_expiry';

  const TokenManager(this._storage);

  // ---------------------------------------------------------------------------
  // Access Token
  // ---------------------------------------------------------------------------

  /// Retrieves the current JWT access token, or null if not stored.
  String? get accessToken => _storage.getString(_accessTokenKey);

  /// Persists a new access token after login or refresh.
  Future<void> saveAccessToken(String token) async {
    await _storage.setString(_accessTokenKey, token);
    AppLogger.debug('Access token saved to secure storage.');
  }

  /// Whether a non-empty access token is present in local storage.
  bool get hasAccessToken {
    final token = accessToken;
    return token != null && token.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // Refresh Token
  // ---------------------------------------------------------------------------

  /// Retrieves the current JWT refresh token, or null if not stored.
  String? get refreshToken => _storage.getString(_refreshTokenKey);

  /// Persists a new refresh token after login.
  Future<void> saveRefreshToken(String token) async {
    await _storage.setString(_refreshTokenKey, token);
    AppLogger.debug('Refresh token saved to secure storage.');
  }

  /// Whether a non-empty refresh token is available for session renewal.
  bool get hasRefreshToken {
    final token = refreshToken;
    return token != null && token.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // Token Expiry
  // ---------------------------------------------------------------------------

  /// Persists token expiry as ISO 8601 string for downstream checks.
  Future<void> saveTokenExpiry(DateTime expiry) async {
    await _storage.setString(_tokenExpiryKey, expiry.toIso8601String());
    AppLogger.debug('Token expiry saved: ${expiry.toIso8601String()}');
  }

  /// Parses the stored expiry timestamp, or null if not saved.
  DateTime? get tokenExpiry {
    final raw = _storage.getString(_tokenExpiryKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  /// Whether the access token has expired based on the stored expiry.
  /// 
  /// Includes a 30-second safety buffer to allow proactive refresh
  /// before the server rejects the token.
  bool get isTokenExpired {
    final expiry = tokenExpiry;
    if (expiry == null) return true; // No expiry stored → assume expired
    return DateTime.now().isAfter(expiry.subtract(const Duration(seconds: 30)));
  }

  /// Whether the stored session can be renewed (has refresh token + access expired).
  bool get shouldRefresh => isTokenExpired && hasRefreshToken;

  // ---------------------------------------------------------------------------
  // Session Lifecycle
  // ---------------------------------------------------------------------------

  /// Saves both tokens and optional expiry in a single call.
  /// Used after successful login or token refresh.
  Future<void> saveTokenPair({
    required String accessToken,
    required String refreshToken,
    DateTime? expiresAt,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    if (expiresAt != null) {
      await saveTokenExpiry(expiresAt);
    }
    AppLogger.info('Token pair saved to secure storage.');
  }

  /// Wipes all token data from local storage. Called on explicit logout
  /// or when the refresh token itself has expired.
  Future<void> clearTokens() async {
    await _storage.remove(_accessTokenKey);
    await _storage.remove(_refreshTokenKey);
    await _storage.remove(_tokenExpiryKey);
    AppLogger.warning('All tokens cleared from secure storage.');
  }

  /// Debug summary for diagnostics / logging (never log raw tokens!).
  @override
  String toString() {
    return 'TokenManager('
        'hasAccess: $hasAccessToken, '
        'hasRefresh: $hasRefreshToken, '
        'expired: $isTokenExpired)';
  }
}

// ---------------------------------------------------------------------------
// Riverpod Provider
// ---------------------------------------------------------------------------

final tokenManagerProvider = Provider<TokenManager>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return TokenManager(storage);
});
