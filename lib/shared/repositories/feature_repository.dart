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
    try {
      final response = await _client.get(ApiEndpoints.attendanceReport);
      return AttendanceSummary.fromJson(response.data);
    } catch (_) {
      AppLogger.warning('Using mock attendance summary');
      return const AttendanceSummary(
        totalDays: 120, presentDays: 108, absentDays: 5,
        lateDays: 3, holidays: 4, percentage: 90.0,
      );
    }
  }

  Future<List<AttendanceRecord>> getMonthlyAttendance(int month, int year) async {
    try {
      final response = await _client.get(ApiEndpoints.attendance, queryParameters: {'month': month, 'year': year});
      return (response.data['data'] as List).map((e) => AttendanceRecord.fromJson(e)).toList();
    } catch (_) {
      AppLogger.warning('Using mock monthly attendance');
      return List.generate(30, (i) => AttendanceRecord(
        id: 'att_$i', date: DateTime(year, month, i + 1),
        status: i % 7 == 0 ? AttendanceStatus.holiday : (i % 5 == 0 ? AttendanceStatus.absent : AttendanceStatus.present),
      ));
    }
  }

  // ===========================================================================
  // HOMEWORK
  // ===========================================================================

  Future<List<HomeworkItem>> getHomeworkList({String? subject}) async {
    try {
      final response = await _client.get(ApiEndpoints.homework, queryParameters: subject != null ? {'subject': subject} : null);
      return (response.data['data'] as List).map((e) => HomeworkItem.fromJson(e)).toList();
    } catch (_) {
      AppLogger.warning('Using mock homework list');
      return [
        HomeworkItem(id: 'hw1', title: 'Chapter 5 Exercises', subject: 'Mathematics', description: 'Complete Q1-Q15 from NCERT', dueDate: DateTime.now().add(const Duration(days: 2)), status: HomeworkStatus.pending, teacherName: 'Mrs. Sharma'),
        HomeworkItem(id: 'hw2', title: 'Essay on Environment', subject: 'English', description: 'Write 500 words essay', dueDate: DateTime.now().add(const Duration(days: 4)), status: HomeworkStatus.pending, teacherName: 'Mr. Verma'),
        HomeworkItem(id: 'hw3', title: 'Science Lab Report', subject: 'Science', description: 'Photosynthesis experiment', dueDate: DateTime.now().subtract(const Duration(days: 1)), status: HomeworkStatus.submitted, teacherName: 'Ms. Patel', marks: 18, totalMarks: 20),
        HomeworkItem(id: 'hw4', title: 'Hindi Poem Recitation', subject: 'Hindi', description: 'Learn and record poem', dueDate: DateTime.now().subtract(const Duration(days: 3)), status: HomeworkStatus.graded, teacherName: 'Mrs. Gupta', marks: 9, totalMarks: 10),
      ];
    }
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
    try {
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
    } catch (e) {
      AppLogger.warning('Using mock exam schedule due to error: $e');
      return [
        ExamSchedule(id: 'e1', examName: 'Mid-Term', subject: 'Mathematics', date: DateTime(2026, 6, 15), time: '09:00 AM', room: 'Hall A', totalMarks: 100),
        ExamSchedule(id: 'e2', examName: 'Mid-Term', subject: 'Science', date: DateTime(2026, 6, 17), time: '09:00 AM', room: 'Hall B', totalMarks: 100),
        ExamSchedule(id: 'e3', examName: 'Mid-Term', subject: 'English', date: DateTime(2026, 6, 19), time: '10:00 AM', room: 'Hall A', totalMarks: 100),
        ExamSchedule(id: 'e4', examName: 'Mid-Term', subject: 'Hindi', date: DateTime(2026, 6, 21), time: '09:00 AM', room: 'Room 12', totalMarks: 80),
      ];
    }
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
    try {
      final response = await _client.get(ApiEndpoints.timetable);
      return (response.data['data'] as List).map((e) => TimetableSlot.fromJson(e)).toList();
    } catch (_) {
      AppLogger.warning('Using mock timetable');
      return [
        const TimetableSlot(id: 't1', subject: 'Mathematics', teacherName: 'Mrs. Sharma', room: 'Room 12', startTime: '08:00', endTime: '08:45', dayOfWeek: 1),
        const TimetableSlot(id: 't2', subject: 'English', teacherName: 'Mr. Verma', room: 'Room 14', startTime: '08:50', endTime: '09:35', dayOfWeek: 1),
        const TimetableSlot(id: 't3', subject: 'Science', teacherName: 'Ms. Patel', room: 'Lab 2', startTime: '09:40', endTime: '10:25', dayOfWeek: 1),
        const TimetableSlot(id: 't4', subject: 'Hindi', teacherName: 'Mrs. Gupta', room: 'Room 12', startTime: '10:45', endTime: '11:30', dayOfWeek: 1),
        const TimetableSlot(id: 't5', subject: 'Social Studies', teacherName: 'Mr. Khan', room: 'Room 16', startTime: '11:35', endTime: '12:20', dayOfWeek: 1),
        const TimetableSlot(id: 't6', subject: 'Art & Craft', teacherName: 'Ms. Jain', room: 'Art Room', startTime: '01:00', endTime: '01:45', dayOfWeek: 1),
        const TimetableSlot(id: 't7', subject: 'Mathematics', teacherName: 'Mrs. Sharma', room: 'Room 12', startTime: '08:00', endTime: '08:45', dayOfWeek: 2),
        const TimetableSlot(id: 't8', subject: 'Science', teacherName: 'Ms. Patel', room: 'Lab 2', startTime: '08:50', endTime: '09:35', dayOfWeek: 2),
      ];
    }
  }

  // ===========================================================================
  // NOTIFICATIONS
  // ===========================================================================

  Future<List<NotificationItem>> getNotifications() async {
    try {
      final response = await _client.get(ApiEndpoints.notifications);
      return (response.data['data'] as List).map((e) => NotificationItem.fromJson(e)).toList();
    } catch (_) {
      AppLogger.warning('Using mock notifications');
      return [
        NotificationItem(id: 'n1', title: 'Fee Reminder', body: 'Q2 tuition fee of ₹25,000 is due by July 15.', type: NotificationType.fees, createdAt: DateTime.now().subtract(const Duration(hours: 2))),
        NotificationItem(id: 'n2', title: 'New Homework', body: 'Mathematics: Chapter 5 exercises due in 2 days.', type: NotificationType.homework, createdAt: DateTime.now().subtract(const Duration(hours: 5)), isRead: true),
        NotificationItem(id: 'n3', title: 'PTM Scheduled', body: 'Parent-Teacher meeting on June 10th at 10 AM.', type: NotificationType.event, createdAt: DateTime.now().subtract(const Duration(days: 1))),
        NotificationItem(id: 'n4', title: 'Attendance Alert', body: 'Your ward was marked absent on May 18.', type: NotificationType.attendance, createdAt: DateTime.now().subtract(const Duration(days: 2)), isRead: true),
        NotificationItem(id: 'n5', title: 'Exam Schedule Released', body: 'Mid-term examination starts June 15.', type: NotificationType.academic, createdAt: DateTime.now().subtract(const Duration(days: 3))),
      ];
    }
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
