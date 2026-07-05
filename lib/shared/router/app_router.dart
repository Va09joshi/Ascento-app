import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/widgets/error_view.dart';
import 'package:ascento_abacus/features/attendance/presentation/views/attendance_view.dart';
import 'package:ascento_abacus/features/dashboard/presentation/views/dashboard_view.dart';
import 'package:ascento_abacus/features/dashboard/presentation/views/admin_dashboard_view.dart';
import 'package:ascento_abacus/features/dashboard/presentation/views/teacher_dashboard_view.dart';
import 'package:ascento_abacus/features/enquiry/presentation/views/enquiry_view.dart';
import 'package:ascento_abacus/features/exams/presentation/views/exam_view.dart';
import 'package:ascento_abacus/features/fees/presentation/views/fees_view.dart';
import 'package:ascento_abacus/features/homework/presentation/views/homework_view.dart';
import 'package:ascento_abacus/features/notifications/presentation/views/notifications_view.dart';
import 'package:ascento_abacus/features/splash/presentation/views/splash_view.dart';
import 'package:ascento_abacus/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:ascento_abacus/features/auth/presentation/views/login_view.dart';
import 'package:ascento_abacus/features/auth/presentation/views/forgot_password_view.dart';
import 'package:ascento_abacus/features/auth/presentation/views/otp_verification_view.dart';
import 'package:ascento_abacus/features/auth/presentation/views/reset_password_view.dart';
import 'package:ascento_abacus/features/profile/presentation/views/profile_view.dart';
import 'package:ascento_abacus/features/timetable/presentation/views/timetable_view.dart';
import 'package:ascento_abacus/features/programs/presentation/views/programs_view.dart';
import 'package:ascento_abacus/features/lessons/presentation/views/lessons_view.dart';
import 'package:ascento_abacus/features/users/presentation/views/users_management_view.dart';

import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/shared/router/route_guard.dart';
import 'package:ascento_abacus/shared/router/navigation_shell.dart';

// Decoupled, centralized GoRouter configuration driving Ascento Abacus application navigation
final routerProvider = Provider<GoRouter>((ref) {
  final guard = ref.watch(routeGuardProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    redirect: (context, state) => guard.handleRedirection(context, state),

    // Global fallback error page override
    errorBuilder: (context, state) => Scaffold(
      body: ErrorView(
        message:
            'The screen you requested does not exist or has been relocated.',
        onRetry: () => context.go(RoutePaths.dashboard),
      ),
    ),

    routes: [
      // --- Root Sequence Routes ---
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // --- Authentication Route Group ---
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(
        path: RoutePaths.otpVerify,
        name: RouteNames.otpVerify,
        builder: (context, state) => const OtpVerificationView(),
      ),
      GoRoute(
        path: RoutePaths.resetPassword,
        name: RouteNames.resetPassword,
        builder: (context, state) => const ResetPasswordView(),
      ),

      // --- Nested Main Shell Navigation Tab Group ---
      ShellRoute(
        builder: (context, state, child) {
          return NavigationShell(currentPath: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            path: RoutePaths.dashboard,
            name: RouteNames.dashboard,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardView(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: RoutePaths.adminDashboard,
            name: RouteNames.adminDashboard,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AdminDashboardView(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: RoutePaths.teacherDashboard,
            name: RouteNames.teacherDashboard,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const TeacherDashboardView(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: RoutePaths.manageUsers,
            name: RouteNames.manageUsers,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const UsersManagementView(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: RoutePaths.studentDashboard,
            name: RouteNames.studentDashboard,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardView(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: RoutePaths.attendance,
            name: RouteNames.attendance,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AttendanceView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          ),
          GoRoute(
            path: RoutePaths.exams,
            name: RouteNames.exams,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ExamView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          ),
          GoRoute(
            path: RoutePaths.fees,
            name: RouteNames.fees,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const FeesView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          ),
          GoRoute(
            path: RoutePaths.homework,
            name: RouteNames.homework,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomeworkView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          ),
          GoRoute(
            path: RoutePaths.notifications,
            name: RouteNames.notifications,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const NotificationsView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          ),
          GoRoute(
            path: RoutePaths.timetable,
            name: RouteNames.timetable,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const TimetableView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          ),
          GoRoute(
            path: RoutePaths.enquiry,
            name: RouteNames.enquiry,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const EnquiryView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          ),
          GoRoute(
            path: RoutePaths.programs,
            name: RouteNames.programs,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProgramsView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          ),
          GoRoute(
            path: RoutePaths.profile,
            name: RouteNames.profile,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProfileView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          ),
          GoRoute(
            path: RoutePaths.content,
            name: RouteNames.content,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const LessonsView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          ),
        ],
      ),

      // --- Guarded Billing Sandbox Page ---
      GoRoute(
        path: '/billing',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Accounting Billing Register')),
          body: const Center(
            child: Text(
              'Success: You have authorized accountant permissions to view this system page.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),

      // --- Custom Guarded Error Landing Route ---
      GoRoute(
        path: RoutePaths.error,
        name: RouteNames.error,
        builder: (context, state) => Scaffold(
          body: ErrorView(
            message:
                'Security Alert: Your user role does not hold authorization rights to view this module.',
            onRetry: () => context.go(RoutePaths.dashboard),
          ),
        ),
      ),
    ],
  );
});
