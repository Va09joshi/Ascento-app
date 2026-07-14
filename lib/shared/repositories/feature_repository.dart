import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/core/constants/api_endpoints.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';

import '../models/user_model.dart';

/// Centralised feature repository with API-ready architecture and mock fallback.
class FeatureRepository {
  final DioClient _client;
  const FeatureRepository(this._client);

  // ===========================================================================
  // ATTENDANCE
  // ===========================================================================

  Future<AttendanceSummary> getAttendanceSummary() async {
    final response = await _client.get(ApiEndpoints.attendanceReport);
    return AttendanceSummary.fromJson(response.data);
  }

  Future<List<AttendanceRecord>> getMonthlyAttendance(int month, int year) async {
    final response = await _client.get(ApiEndpoints.attendance, queryParameters: {'month': month, 'year': year});
    return (response.data['data'] as List).map((e) => AttendanceRecord.fromJson(e)).toList();
  }

  // ===========================================================================
  // HOMEWORK
  // ===========================================================================

  Future<List<HomeworkItem>> getHomeworkList({String? subject}) async {
    final response = await _client.get(ApiEndpoints.homework, queryParameters: subject != null ? {'subject': subject} : null);
    return (response.data['data'] as List).map((e) => HomeworkItem.fromJson(e)).toList();
  }

  // ===========================================================================
  // FEES
  // ===========================================================================

  Future<List<FeeRecord>> getFeeHistory() async {
    try {
      final response = await _client.get(ApiEndpoints.feeHistory);
      return (response.data['data'] as List).map((e) => FeeRecord.fromJson(e)).toList();
    } catch (_) {
      AppLogger.warning('Using mock fee records');
      return [
        FeeRecord(id: 'f1', title: 'Tuition Fee - Q1', amount: 25000, paidAmount: 25000, status: PaymentStatus.paid, dueDate: DateTime(2026, 4, 15), paidDate: DateTime(2026, 4, 10), transactionId: 'TXN001'),
        FeeRecord(id: 'f2', title: 'Tuition Fee - Q2', amount: 25000, paidAmount: 12000, status: PaymentStatus.partial, dueDate: DateTime(2026, 7, 15)),
        FeeRecord(id: 'f3', title: 'Lab & Activity Fee', amount: 8000, status: PaymentStatus.pending, dueDate: DateTime(2026, 8, 1)),
        FeeRecord(id: 'f4', title: 'Transport Fee', amount: 6000, status: PaymentStatus.overdue, dueDate: DateTime(2026, 3, 1)),
      ];
    }
  }

  // ===========================================================================
  // EXAMS & RESULTS
  // ===========================================================================

  Future<List<ExamSchedule>> getExamSchedule() async {
    final response = await _client.get('/exams');
    return (response.data['data'] as List).map((e) {
      return ExamSchedule(
        id: e['id']?.toString() ?? '',
        examName: e['title']?.toString() ?? 'Exam',
        subject: (e['subjects'] != null && e['subjects'] is Map) 
            ? e['subjects']['name']?.toString() ?? 'Unknown' 
            : 'Unknown',
        date: DateTime.tryParse(e['exam_date']?.toString() ?? '') ?? DateTime.now(),
        time: e['start_time']?.toString() ?? 'TBD',
        room: 'TBD',
        totalMarks: (e['total_marks'] as num?)?.toInt() ?? 100,
      );
    }).toList();
  }

  Future<ReportCard> getReportCard(String examId) async {
    try {
      final response = await _client.get('/exams/report/$examId');
      return ReportCard.fromJson(response.data['data']);
    } catch (_) {
      AppLogger.warning('Using mock report card');
      return const ReportCard(
        examName: 'Mid-Term Examination 2026',
        results: [
          SubjectResult(subject: 'Mathematics', marksObtained: 87, totalMarks: 100, grade: 'A'),
          SubjectResult(subject: 'Science', marksObtained: 92, totalMarks: 100, grade: 'A+'),
          SubjectResult(subject: 'English', marksObtained: 78, totalMarks: 100, grade: 'B+'),
          SubjectResult(subject: 'Hindi', marksObtained: 71, totalMarks: 80, grade: 'A'),
          SubjectResult(subject: 'Social Studies', marksObtained: 85, totalMarks: 100, grade: 'A'),
        ],
        overallPercentage: 86.0,
        overallGrade: 'A',
        gpa: 8.9,
      );
    }
  }

  // ===========================================================================
  // TIMETABLE
  // ===========================================================================

  Future<List<TimetableSlot>> getWeeklyTimetable() async {
    final response = await _client.get(ApiEndpoints.timetable);
    return (response.data['data'] as List).map((e) => TimetableSlot.fromJson(e)).toList();
  }

  // ===========================================================================
  // NOTIFICATIONS
  // ===========================================================================

  Future<List<NotificationItem>> getNotifications() async {
    final response = await _client.get(ApiEndpoints.notifications, queryParameters: {'target_role': 'student'});
    return (response.data['data'] as List).map((e) => NotificationItem.fromJson(e)).toList();
  }

  Future<void> markNotificationRead(String id) async {
    try {
      await _client.patch('${ApiEndpoints.notifications}/$id', data: {'isRead': true});
    } catch (_) {
      AppLogger.warning('Mock: notification $id marked as read');
    }
  }

  // ===========================================================================
  // PROFILE
  // ===========================================================================

  Future<StudentProfile> getStudentProfile() async {
    try {
      final response = await _client.get(ApiEndpoints.profile);
      return StudentProfile.fromJson(response.data['data']);
    } catch (_) {
      AppLogger.warning('Using mock student profile');
      return StudentProfile(
        user: const UserModel(id: 'ASC-2026-9841', name: 'Vaibhav Kumar', email: 'vaibhav@ascento.com', role: UserRole.student, starsCount: 15, completedLevels: 2),
        className: 'Class 8', section: 'A', rollNumber: '24',
        fatherName: 'Mr. Rajesh Kumar', motherName: 'Mrs. Sunita Kumar',
        phone: '9876543210', address: '42, Education Lane, New Delhi',
        bloodGroup: 'B+', dateOfBirth: DateTime(2013, 8, 15),
      );
    }
  }
}

// Riverpod Provider
final featureRepositoryProvider = Provider<FeatureRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return FeatureRepository(client);
});
