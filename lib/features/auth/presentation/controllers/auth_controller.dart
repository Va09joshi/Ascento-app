import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/features/auth/domain/services/auth_service.dart';

class AuthUIState {
  final bool isLoading;
  final String? errorMessage;
  final UserModel? currentUser;
  final String? otpEmail;
  final String? otpCode;

  const AuthUIState({
    this.isLoading = false,
    this.errorMessage,
    this.currentUser,
    this.otpEmail,
    this.otpCode,
  });

  AuthUIState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserModel? currentUser,
    String? otpEmail,
    String? otpCode,
  }) {
    return AuthUIState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Reset if null is passed explicitly
      currentUser: currentUser ?? this.currentUser,
      otpEmail: otpEmail ?? this.otpEmail,
      otpCode: otpCode ?? this.otpCode,
    );
  }
}

class AuthController extends StateNotifier<AuthUIState> {
  final AuthService _authService;

  AuthController(this._authService)
      : super(AuthUIState(currentUser: _authService.getCurrentUser()));

  // 1. Submit Sign-In validation
  Future<void> login(
    String email,
    String password,
    UserRole role,
    bool rememberMe,
    VoidCallback onSuccess,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.authenticate(email, password, role, rememberMe);
      state = state.copyWith(isLoading: false, currentUser: user);
      onSuccess();
    } catch (e) {
      AppLogger.error('Login action failure', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // 2. Forgot Password - Send Code
  Future<void> sendForgotPasswordOtp(
    String email,
    VoidCallback onSuccess,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.requestPasswordOtp(email);
      state = state.copyWith(isLoading: false, otpEmail: email);
      onSuccess();
    } catch (e) {
      AppLogger.error('Forgot password submission error', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // 3. OTP Verification
  Future<void> verifyOtp(
    String code,
    VoidCallback onSuccess,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final email = state.otpEmail ?? '';
    try {
      final isValid = await _authService.verifyResetOtp(email, code);
      if (isValid) {
        state = state.copyWith(isLoading: false, otpCode: code);
        onSuccess();
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'The verification code entered is incorrect.',
        );
      }
    } catch (e) {
      AppLogger.error('OTP code check error', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // 4. Finalize Password Reset
  Future<void> resetPassword(
    String newPassword,
    VoidCallback onSuccess,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final email = state.otpEmail ?? '';
    final code = state.otpCode ?? '';
    try {
      await _authService.submitNewPassword(email, code, newPassword);
      state = state.copyWith(isLoading: false, otpEmail: null, otpCode: null);
      onSuccess();
    } catch (e) {
      AppLogger.error('Password reset finalize error', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // 5. Force Change Password
  Future<void> changePassword(String newPassword) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.changePassword(newPassword);
      
      // Update local state to reflect the change
      final updatedUser = state.currentUser?.copyWith(mustChangePassword: false);
      state = state.copyWith(isLoading: false, currentUser: updatedUser);
    } catch (e) {
      AppLogger.error('Password change submission error', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  // 6. Logout Session
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authService.endSession();
    state = const AuthUIState();
  }
}

// Global Auth State Provider
final StateNotifierProvider<AuthController, AuthUIState> authControllerProvider = StateNotifierProvider<AuthController, AuthUIState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});
