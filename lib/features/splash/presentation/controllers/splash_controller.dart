import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/core/services/storage_service.dart';
import 'package:ascento_abacus/features/splash/data/splash_service.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';

enum SplashStatus {
  initializing,
  checkingVersion,
  checkingNetwork,
  checkingToken,
  checkingRole,
  error,
  completed,
}

class SplashState {
  final SplashStatus status;
  final String statusMessage;
  final String? errorMessage;
  final String? targetRoute;

  const SplashState({
    required this.status,
    required this.statusMessage,
    this.errorMessage,
    this.targetRoute,
  });

  SplashState copyWith({
    SplashStatus? status,
    String? statusMessage,
    String? errorMessage,
    String? targetRoute,
  }) {
    return SplashState(
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      targetRoute: targetRoute ?? this.targetRoute,
    );
  }
}

class SplashController extends StateNotifier<SplashState> {
  final SplashService _splashService;
  final StorageService _storageService;

  SplashController(this._splashService, this._storageService)
      : super(const SplashState(
          status: SplashStatus.initializing,
          statusMessage: 'Preparing educational workspace...',
        )) {
    runBootSequence();
  }

  // Orchestrate sequential boot checks
  Future<void> runBootSequence() async {
    AppLogger.info('Initializing Ascento Abacus boot sequence...');
    state = const SplashState(
      status: SplashStatus.initializing,
      statusMessage: 'Loading educational engines...',
    );

    try {
      // 1. Minimum Animation Breathing Room (ensure logo animations render first)
      await Future.delayed(const Duration(milliseconds: 1200));

      // 2. Version Checking
      state = state.copyWith(
        status: SplashStatus.checkingVersion,
        statusMessage: 'Checking app updates...',
      );
      final isCompatible = await _splashService.isAppVersionValid();
      if (!isCompatible) {
        throw Exception('This app version is no longer supported. Please update to the latest version.');
      }

      // 3. Internet Connectivity Verification
      state = state.copyWith(
        status: SplashStatus.checkingNetwork,
        statusMessage: 'Connecting to school servers...',
      );
      final isOnline = await _splashService.checkInternet();
      if (!isOnline) {
        // Production: In case offline learning is enabled, we can proceed. Otherwise fail.
        AppLogger.warning('Offline status detected. Launching local classroom mode.');
      }

      // 4. Onboarding Verification Check
      final isOnboardingDone = _storageService.isOnboardingCompleted();
      if (!isOnboardingDone) {
        AppLogger.info('Onboarding incomplete. Directing to onboarding guide.');
        state = state.copyWith(
          status: SplashStatus.completed,
          statusMessage: 'Launching school guide...',
          targetRoute: '/onboarding',
        );
        return;
      }

      // 5. Decrypt Secure Storage Access Token
      state = state.copyWith(
        status: SplashStatus.checkingToken,
        statusMessage: 'Restoring secure credentials...',
      );
      final token = await _splashService.getAuthToken();
      if (token == null || token.isEmpty) {
        AppLogger.warning('Access token invalid or expired. Redirecting to auth portal.');
        state = state.copyWith(
          status: SplashStatus.completed,
          statusMessage: 'Opening login portal...',
          targetRoute: '/login',
        );
        return;
      }

      // 6. User Access Rights & Role Resolution
      state = state.copyWith(
        status: SplashStatus.checkingRole,
        statusMessage: 'Configuring classroom dashboard...',
      );
      final role = await _splashService.getUserRole();
      
      // Determine target destination based on educational access privilege
      String route;
      switch (role) {
        case UserRole.admin:
          AppLogger.info('Role resolved: Administrator.');
          route = '/dashboard';
          break;
        case UserRole.teacher:
          AppLogger.info('Role resolved: Instructor.');
          route = '/dashboard';
          break;
        case UserRole.student:
          AppLogger.info('Role resolved: Student.');
          route = '/dashboard';
          break;
        case UserRole.parent:
          AppLogger.info('Role resolved: Parent.');
          route = '/dashboard';
          break;
        case UserRole.accountant:
          AppLogger.info('Role resolved: Accountant.');
          route = '/dashboard';
          break;
        case UserRole.superAdmin:
          // TODO: Handle this case.
          throw UnimplementedError();
      }

      // 7. Successful Handshake
      state = state.copyWith(
        status: SplashStatus.completed,
        statusMessage: 'Bootloader successful. Launching classroom...',
        targetRoute: route,
      );
      
    } catch (e, stack) {
      AppLogger.error('Critical failure in bootloader validation!', e, stack);
      state = state.copyWith(
        status: SplashStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
        statusMessage: 'Bootloader validation failed.',
      );
    }
  }
}

// Global Controller Provider
final splashControllerProvider = StateNotifierProvider<SplashController, SplashState>((ref) {
  final splashService = ref.watch(splashServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return SplashController(splashService, storageService);
});
