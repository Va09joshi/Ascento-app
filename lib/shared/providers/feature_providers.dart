import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/repositories/feature_repository.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';

// =============================================================================
// ATTENDANCE PROVIDERS
// =============================================================================

final attendanceSummaryProvider = FutureProvider<AttendanceSummary>((ref) {
  return ref.watch(featureRepositoryProvider).getAttendanceSummary();
});

final monthlyAttendanceProvider = FutureProvider.family<List<AttendanceRecord>, ({int month, int year})>((ref, params) {
  return ref.watch(featureRepositoryProvider).getMonthlyAttendance(params.month, params.year);
});

// =============================================================================
// HOMEWORK PROVIDERS
// =============================================================================

final homeworkListProvider = FutureProvider.family<List<HomeworkItem>, String?>((ref, subject) {
  return ref.watch(featureRepositoryProvider).getHomeworkList(subject: subject);
});

// =============================================================================
// FEES PROVIDERS
// =============================================================================

final feeHistoryProvider = FutureProvider<List<FeeRecord>>((ref) {
  return ref.watch(featureRepositoryProvider).getFeeHistory();
});

// =============================================================================
// EXAM PROVIDERS
// =============================================================================

final examScheduleProvider = FutureProvider<List<ExamSchedule>>((ref) {
  return ref.watch(featureRepositoryProvider).getExamSchedule();
});

final reportCardProvider = FutureProvider.family<ReportCard, String>((ref, examId) {
  return ref.watch(featureRepositoryProvider).getReportCard(examId);
});

// =============================================================================
// TIMETABLE PROVIDERS
// =============================================================================

final weeklyTimetableProvider = FutureProvider<List<TimetableSlot>>((ref) {
  return ref.watch(featureRepositoryProvider).getWeeklyTimetable();
});

// =============================================================================
// NOTIFICATION PROVIDERS
// =============================================================================

final notificationsProvider = FutureProvider<List<NotificationItem>>((ref) {
  return ref.watch(featureRepositoryProvider).getNotifications();
});

// =============================================================================
// PROFILE PROVIDERS
// =============================================================================

final studentProfileProvider = FutureProvider<StudentProfile>((ref) async {
  final user = ref.read(authControllerProvider).currentUser;
  if (user == null || user.role != UserRole.student) {
    return StudentProfile(
      user: user ?? const UserModel(id: '', name: '', email: '', role: UserRole.student),
      className: '',
      section: '',
      rollNumber: '',
    );
  }
  return ref.watch(featureRepositoryProvider).getStudentProfile();
});

// =============================================================================
// TEACHER PROVIDERS
// =============================================================================

final teacherDashboardStatsProvider = FutureProvider<TeacherDashboardStats>((ref) async {
  return ref.watch(featureRepositoryProvider).getTeacherDashboardStats();
});

final teacherStudentsProvider = FutureProvider<List<SectionStudentsModel>>((ref) async {
  return ref.watch(featureRepositoryProvider).getTeacherStudents();
});
