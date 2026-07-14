import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/core/services/storage_service.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/features/auth/domain/services/auth_service.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';

class RouteGuard {
  final Ref _ref;

  const RouteGuard(this._ref);

  String? handleRedirection(BuildContext context, GoRouterState state) {
    final storageService = _ref.read(storageServiceProvider);
    final authService = _ref.read(authServiceProvider);

    final path = state.uri.path;
    AppLogger.debug('Evaluating Route Guard for path: $path');

    // 1. Splash check (Always allow Splash view to load first)
    if (path == RoutePaths.splash) {
      return null;
    }

    // 2. Onboarding check (Redirect to Onboarding if not completed)
    final onboardingDone = storageService.isOnboardingCompleted();
    if (!onboardingDone) {
      if (path != RoutePaths.onboarding) {
        AppLogger.warning('Access denied: onboarding incomplete. Redirecting to onboarding.');
        return RoutePaths.onboarding;
      }
      return null; // Let them see onboarding
    }

    // If onboarding is done, but they are trying to visit onboarding page, skip to login/dashboard
    if (path == RoutePaths.onboarding) {
      final isLoggedIn = authService.isUserLoggedIn();
      return isLoggedIn ? RoutePaths.dashboard : RoutePaths.login;
    }

    // 3. Authentication Check
    final isLoggedIn = authService.isUserLoggedIn();
    final isAuthRoute = path == RoutePaths.login ||
        path == RoutePaths.forgotPassword ||
        path == RoutePaths.otpVerify ||
        path == RoutePaths.resetPassword;

    if (!isLoggedIn) {
      // If user is not logged in and is trying to access a protected page, force Login
      if (!isAuthRoute) {
        AppLogger.warning('Access denied: unauthenticated session. Redirecting to login.');
        return RoutePaths.login;
      }
      return null; // Let them view login / OTP pages
    }

    // If user IS logged in:
    final currentUser = authService.getCurrentUser();

    // 4. Force Change Password Check
    if (currentUser?.mustChangePassword == true) {
      if (path != RoutePaths.forceChangePassword) {
        AppLogger.warning('User must change password. Redirecting to force change password view.');
        return RoutePaths.forceChangePassword;
      }
      return null; // Let them view the change password page
    }

    // If user tries to visit auth pages, direct to dashboard
    if (isAuthRoute || path == RoutePaths.forceChangePassword) {
      final currentUser = authService.getCurrentUser();
      AppLogger.info('User is already logged in. Bypassing auth views to role-specific dashboard.');
      if (currentUser != null) {
        switch (currentUser.role) {
          case UserRole.admin:
            return RoutePaths.adminDashboard;
          case UserRole.teacher:
            return RoutePaths.teacherDashboard;
          case UserRole.student:
            return RoutePaths.studentDashboard;
          default:
            return RoutePaths.dashboard;
        }
      }
      return RoutePaths.dashboard;
    }

    // 4. Role-Based Navigation Authorization
    if (currentUser != null) {
      if (path.startsWith(RoutePaths.adminDashboard) && 
          currentUser.role != UserRole.admin && 
          currentUser.role != UserRole.superAdmin) {
        return RoutePaths.error;
      }
      if (path.startsWith(RoutePaths.teacherDashboard) && currentUser.role != UserRole.teacher) {
        return RoutePaths.error;
      }
      if (path.startsWith(RoutePaths.studentDashboard) && currentUser.role != UserRole.student) {
        return RoutePaths.error;
      }

      // Block non-admins from Admin-only views
      if ((path.startsWith(RoutePaths.manageUsers) || 
           path.startsWith(RoutePaths.manageBranches) || 
           path.startsWith(RoutePaths.academicsConfig)) && 
          currentUser.role != UserRole.admin && 
          currentUser.role != UserRole.superAdmin) {
        AppLogger.warning('Unauthorized role access to admin-only areas.');
        return RoutePaths.error;
      }
      // Example role restriction: simulate a scenario where only Accountant or Admin can reach specific routes
      if (path.contains('/billing') && 
          currentUser.role != UserRole.accountant && 
          currentUser.role != UserRole.admin &&
          currentUser.role != UserRole.superAdmin) {
        AppLogger.warning('Unauthorized role access to Billing registry.');
        return RoutePaths.error;
      }
    }

    return null; // Allow navigation to proceed
  }
}

// Route Guard Provider
final routeGuardProvider = Provider<RouteGuard>((ref) {
  return RouteGuard(ref);
});
