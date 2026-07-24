import 'package:ascento_abacus/features/dashboard/presentation/views/teacher_students_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/widgets/error_view.dart';
import 'package:ascento_abacus/features/attendance/presentation/views/attendance_management_view.dart';
import 'package:ascento_abacus/features/dashboard/presentation/views/dashboard_view.dart';
import 'package:ascento_abacus/features/dashboard/presentation/views/admin_dashboard_view.dart';
import 'package:ascento_abacus/features/dashboard/presentation/views/teacher_dashboard_view.dart';
import 'package:ascento_abacus/features/enquiry/presentation/views/enquiry_view.dart';
import 'package:ascento_abacus/features/exams/presentation/views/student_exams_view.dart';
import 'package:ascento_abacus/features/exams/presentation/views/exams_management_view.dart';
import 'package:ascento_abacus/features/exams/presentation/views/exam_form_view.dart';
import 'package:ascento_abacus/features/fees/presentation/views/fees_view.dart';
import 'package:ascento_abacus/features/homework/presentation/views/homework_student_view.dart';
import 'package:ascento_abacus/features/homework/presentation/views/homework_teacher_view.dart';
import 'package:ascento_abacus/features/meetings/presentation/views/meetings_view.dart';
import 'package:ascento_abacus/features/content/presentation/views/content_view.dart';
import 'package:ascento_abacus/features/content/presentation/views/upload_content_view.dart';
import 'package:ascento_abacus/features/content/presentation/views/study_mode_view.dart';
import 'package:ascento_abacus/features/meetings/presentation/views/live_session_view.dart';
import 'package:ascento_abacus/features/notifications/presentation/views/notices_management_view.dart';
import 'package:ascento_abacus/features/notifications/presentation/views/notice_form_view.dart';
import 'package:ascento_abacus/features/notifications/presentation/views/notice_details_view.dart';
import 'package:ascento_abacus/features/notifications/presentation/views/admin_notice_details_view.dart';
import 'package:ascento_abacus/features/splash/presentation/views/splash_view.dart';
import 'package:ascento_abacus/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:ascento_abacus/features/attendance/presentation/views/student_attendance_view.dart';
import 'package:ascento_abacus/features/attendance/presentation/views/teacher_mark_attendance_view.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ascento_abacus/features/auth/presentation/views/login_view.dart';
import 'package:ascento_abacus/features/auth/presentation/views/force_change_password_view.dart';
import 'package:ascento_abacus/features/dashboard/presentation/views/student_dashboard_view.dart';
import 'package:ascento_abacus/features/auth/presentation/views/forgot_password_view.dart';
import 'package:ascento_abacus/features/auth/presentation/views/otp_verification_view.dart';
import 'package:ascento_abacus/features/auth/presentation/views/reset_password_view.dart';
import 'package:ascento_abacus/features/profile/presentation/views/profile_view.dart';
import 'package:ascento_abacus/features/timetable/presentation/views/timetable_management_view.dart';
import 'package:ascento_abacus/features/timetable/presentation/views/timetable_view.dart';
import 'package:ascento_abacus/features/courses/presentation/views/courses_management_view.dart';
import 'package:ascento_abacus/features/users/presentation/views/users_management_view.dart';
import 'package:ascento_abacus/features/users/presentation/views/teachers_management_view.dart';
import 'package:ascento_abacus/features/users/presentation/widgets/user_form_view.dart';
import 'package:ascento_abacus/features/domains/presentation/views/domains_management_view.dart';
import 'package:ascento_abacus/features/users/presentation/views/user_details_view.dart';

import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/shared/router/route_guard.dart';
import 'package:ascento_abacus/shared/router/navigation_shell.dart';

import '../../features/academics/presentation/views/academics_management_view.dart';
import '../../features/academics/presentation/views/academic_year_form_view.dart';
import '../../features/academics/presentation/views/class_form_view.dart';
import '../../features/academics/presentation/views/section_form_view.dart';
import '../../features/academics/presentation/views/subject_form_view.dart';
import '../../features/branches/presentation/views/branches_management_view.dart';
import '../../features/branches/presentation/views/branch_form_view.dart';
import '../models/notice_model.dart';
import '../models/user_model.dart';
import '../models/branch_model.dart';
import '../models/academic_year_model.dart';
import '../models/class_model.dart';
import '../models/section_model.dart';
import '../models/subject_model.dart';

// Decoupled, centralized GoRouter configuration driving Ascento Abacus application navigation
final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  final guard = ref.watch(routeGuardProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    redirect: (context, state) => guard.handleRedirection(context, state),

    // Global fallback error page override
    errorBuilder: (context, state) {
      debugPrint('GoRouter Error: ${state.error}');
      return Scaffold(
        body: ErrorView(
          message: 'The screen you requested does not exist or has been relocated.\nError: ${state.error}',
          onRetry: () => context.go(RoutePaths.dashboard),
        ),
      );
    },

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
        path: RoutePaths.forceChangePassword,
        name: RouteNames.forceChangePassword,
        builder: (context, state) => const ForceChangePasswordView(),
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
            path: RoutePaths.teacherStudents,
            name: RouteNames.teacherStudents,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const TeacherStudentsView(),
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
              child: const StudentDashboardView(),
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
            path: RoutePaths.manageTeachers,
            name: RouteNames.manageTeachers,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const TeachersManagementView(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: RoutePaths.manageBranches,
            name: RouteNames.manageBranches,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const BranchesManagementView(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: RoutePaths.manageDomains,
            name: RouteNames.manageDomains,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DomainsManagementView(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: RoutePaths.academicsConfig,
            name: RouteNames.academicsConfig,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AcademicsManagementView(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),


          GoRoute(
            path: RoutePaths.attendance,
            name: RouteNames.attendance,
            pageBuilder: (context, state) {
              final authState = ref.watch(authControllerProvider);
              final role = authState.currentUser?.role;
              final isStudent = role == UserRole.student;
              final isTeacher = role == UserRole.teacher;
              
              Widget view = const AttendanceManagementView();
              if (isStudent) {
                view = const StudentAttendanceView();
              } else if (isTeacher) {
                view = const TeacherMarkAttendanceView();
              }

              return CustomTransitionPage(
                key: state.pageKey,
                child: view,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
              );
            },
          ),
          GoRoute(
            path: RoutePaths.exams,
            name: RouteNames.exams,
            pageBuilder: (context, state) {
              final authState = ref.watch(authControllerProvider);
              final isStudent = authState.currentUser?.role == UserRole.student;
              
              return CustomTransitionPage(
                key: state.pageKey,
                child: isStudent ? const StudentExamsView() : const ExamsManagementView(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
              );
            },
          ),
          GoRoute(
            path: RoutePaths.addExam,
            name: RouteNames.addExam,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ExamFormView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          ),
          GoRoute(
            path: RoutePaths.editExam,
            name: RouteNames.editExam,
            pageBuilder: (context, state) {
              final exam = state.extra as ExamSchedule;
              return CustomTransitionPage(
                key: state.pageKey,
                child: ExamFormView(examToEdit: exam),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
              );
            },
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
              pageBuilder: (context, state) {
                final authState = ref.watch(authControllerProvider);
                final isStudent = authState.currentUser?.role == UserRole.student;
                
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: isStudent ? const HomeworkStudentView() : const HomeworkTeacherView(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                );
              },
            ),
            GoRoute(
              path: RoutePaths.meetings,
              name: RouteNames.meetings,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const MeetingsView(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
              ),
            ),
              GoRoute(
                path: RoutePaths.uploadContent,
                name: RouteNames.uploadContent,
                pageBuilder: (context, state) {
                  final content = state.extra as ContentItem?;
                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: UploadContentView(content: content),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                  );
                },
              ),
            GoRoute(
              path: RoutePaths.content,
              name: RouteNames.content,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ContentView(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
              ),
            ),
            GoRoute(
              path: RoutePaths.studyMode,
              name: RouteNames.studyMode,
              pageBuilder: (context, state) {
                final content = state.extra as ContentItem;
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: StudyModeView(item: content),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                );
              },
            ),
            GoRoute(
              path: RoutePaths.liveSession,
              name: RouteNames.liveSession,
              pageBuilder: (context, state) {
                final meeting = state.extra as MeetingItem;
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: LiveSessionView(item: meeting),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                );
              },
            ),
          GoRoute(
            path: RoutePaths.notifications,
            name: RouteNames.notifications,
            pageBuilder: (context, state) {
              final authState = ref.watch(authControllerProvider);
              final isStudent = authState.currentUser?.role == UserRole.student;
              
              return CustomTransitionPage(
                key: state.pageKey,
                child: NoticesManagementView(isReadOnly: isStudent),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
              );
            },
          ),
          GoRoute(
            path: RoutePaths.timetable,
            name: RouteNames.timetable,
            pageBuilder: (context, state) {
              final authState = ref.watch(authControllerProvider);
              final isStudent = authState.currentUser?.role == UserRole.student;
              
              return CustomTransitionPage(
                key: state.pageKey,
                child: isStudent ? const TimetableView() : const TimetableManagementView(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
              );
            },
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
              child: const CoursesManagementView(),
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
        ],
      ),

      GoRoute(
        path: RoutePaths.addUser,
        name: RouteNames.addUser,
        pageBuilder: (context, state) {
          final role = state.extra as String? ?? 'student';
          return CustomTransitionPage(
            key: state.pageKey,
            child: UserFormView(initialRole: role),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.userDetails,
        name: RouteNames.userDetails,
        pageBuilder: (context, state) {
          final user = state.extra as UserModel;
          return CustomTransitionPage(
            key: state.pageKey,
            child: UserDetailsView(user: user),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.editUser,
        name: RouteNames.editUser,
        pageBuilder: (context, state) {
          final user = state.extra as UserModel;
          return CustomTransitionPage(
            key: state.pageKey,
            child: UserFormView(initialRole: user.role.name, userToEdit: user),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.addBranch,
        name: RouteNames.addBranch,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const BranchFormView(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.editBranch,
        name: RouteNames.editBranch,
        pageBuilder: (context, state) {
          final branch = state.extra as BranchModel;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BranchFormView(branch: branch),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),

      GoRoute(
        path: RoutePaths.addAcademicYear,
        name: RouteNames.addAcademicYear,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const AcademicYearFormView(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.editAcademicYear,
        name: RouteNames.editAcademicYear,
        pageBuilder: (context, state) {
          final year = state.extra as AcademicYearModel;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AcademicYearFormView(academicYear: year),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),

      GoRoute(
        path: RoutePaths.addClass,
        name: RouteNames.addClass,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const ClassFormView(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.editClass,
        name: RouteNames.editClass,
        pageBuilder: (context, state) {
          final classModel = state.extra as ClassModel;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ClassFormView(classModel: classModel),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),

      GoRoute(
        path: RoutePaths.addSection,
        name: RouteNames.addSection,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SectionFormView(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.editSection,
        name: RouteNames.editSection,
        pageBuilder: (context, state) {
          final section = state.extra as SectionModel;
          return CustomTransitionPage(
            key: state.pageKey,
            child: SectionFormView(section: section),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),

      GoRoute(
        path: RoutePaths.addSubject,
        name: RouteNames.addSubject,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SubjectFormView(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.editSubject,
        name: RouteNames.editSubject,
        pageBuilder: (context, state) {
          final subject = state.extra as SubjectModel;
          return CustomTransitionPage(
            key: state.pageKey,
            child: SubjectFormView(subject: subject),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      
      GoRoute(
        path: RoutePaths.addNotice,
        name: RouteNames.addNotice,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const NoticeFormView(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.editNotice,
        name: RouteNames.editNotice,
        pageBuilder: (context, state) {
          final notice = state.extra as NoticeModel;
          return CustomTransitionPage(
            key: state.pageKey,
            child: NoticeFormView(notice: notice),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.noticeDetails,
        name: RouteNames.noticeDetails,
        pageBuilder: (context, state) {
          final notice = state.extra as NotificationItem;
          return CustomTransitionPage(
            key: state.pageKey,
            child: NoticeDetailsView(notice: notice),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.adminNoticeDetails,
        name: RouteNames.adminNoticeDetails,
        pageBuilder: (context, state) {
          final notice = state.extra as NoticeModel;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AdminNoticeDetailsView(notice: notice),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
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
