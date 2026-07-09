import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/core/services/storage_service.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/features/auth/data/models/auth_response.dart';
import 'package:ascento_abacus/features/auth/data/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository;
  final StorageService _storageService;

  const AuthService(this._authRepository, this._storageService);

  // Checks if a student/parent/teacher/admin is currently authenticated
  bool isUserLoggedIn() {
    final token = _storageService.getString('secure_jwt_access_token');
    final user = _storageService.getCurrentUser();
    return token != null && token.isNotEmpty && user != null;
  }

  // Get active user model from persistent cache
  UserModel? getCurrentUser() {
    return _storageService.getCurrentUser();
  }

  // Submit sign in and cache token values
  Future<UserModel> authenticate(String email, String password, UserRole role, bool rememberMe) async {
    try {
      final response = await _authRepository.login(email, password, role);
      await _saveSession(response, rememberMe);
      return response.user;
    } catch (e) {
      AppLogger.error('Auth failure inside domain service', e);
      rethrow;
    }
  }

  // Send request for forgot password OTP
  Future<void> requestPasswordOtp(String email) async {
    try {
      await _authRepository.forgotPassword(email);
    } catch (e) {
      AppLogger.error('Forgot password OTP request failure', e);
      rethrow;
    }
  }

  // Verify numerical reset OTP
  Future<bool> verifyResetOtp(String email, String code) async {
    try {
      return await _authRepository.verifyOtp(email, code);
    } catch (e) {
      AppLogger.error('OTP code validation failure', e);
      rethrow;
    }
  }

  // Submit password replacement
  Future<void> submitNewPassword(String email, String code, String newPassword) async {
    try {
      await _authRepository.resetPassword(email, code, newPassword);
    } catch (e) {
      AppLogger.error('Password reset finalize failure', e);
      rethrow;
    }
  }

  // Clear current active session (logout)
  Future<void> endSession() async {
    AppLogger.info('Clearing session credentials and logging out.');
    await _storageService.remove('secure_jwt_access_token');
    await _storageService.remove('secure_jwt_refresh_token');
    await _storageService.removeUser();
  }

  // Private helper to save session values inside shared storage
  Future<void> _saveSession(AuthResponse response, bool rememberMe) async {
    await _storageService.setString('secure_jwt_access_token', response.accessToken);
    await _storageService.setString('secure_jwt_refresh_token', response.refreshToken);
    await _storageService.setCurrentUser(response.user);
    await _storageService.setRememberMe(rememberMe);
  }
}

// Global Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthService(authRepo, storageService);
});
