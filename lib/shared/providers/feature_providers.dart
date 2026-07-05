import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/repositories/feature_repository.dart';

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

final studentProfileProvider = FutureProvider<StudentProfile>((ref) {
  return ref.watch(featureRepositoryProvider).getStudentProfile();
});
