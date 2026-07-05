import 'dart:ui';
import 'package:ascento_abacus/shared/models/user_model.dart';

// =============================================================================
// Attendance Models
// =============================================================================

enum AttendanceStatus { present, absent, late, holiday, halfDay }

class AttendanceRecord {
  final String id;
  final DateTime date;
  final AttendanceStatus status;
  final String? remark;

  const AttendanceRecord({required this.id, required this.date, required this.status, this.remark});

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      status: AttendanceStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String?),
        orElse: () => AttendanceStatus.absent,
      ),
      remark: json['remark'] as String?,
    );
  }
}

class AttendanceSummary {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int holidays;
  final double percentage;

  const AttendanceSummary({
    required this.totalDays, required this.presentDays,
    required this.absentDays, required this.lateDays,
    required this.holidays, required this.percentage,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalDays: json['totalDays'] as int? ?? 0,
      presentDays: json['presentDays'] as int? ?? 0,
      absentDays: json['absentDays'] as int? ?? 0,
      lateDays: json['lateDays'] as int? ?? 0,
      holidays: json['holidays'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// =============================================================================
// Homework Models
// =============================================================================

enum HomeworkStatus { pending, submitted, late, graded }

class HomeworkItem {
  final String id;
  final String title;
  final String subject;
  final String description;
  final DateTime dueDate;
  final HomeworkStatus status;
  final String? attachmentUrl;
  final String? teacherName;
  final int? marks;
  final int? totalMarks;

  const HomeworkItem({
    required this.id, required this.title, required this.subject,
    required this.description, required this.dueDate, required this.status,
    this.attachmentUrl, this.teacherName, this.marks, this.totalMarks,
  });

  factory HomeworkItem.fromJson(Map<String, dynamic> json) {
    return HomeworkItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
      status: HomeworkStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String?),
        orElse: () => HomeworkStatus.pending,
      ),
      attachmentUrl: json['attachmentUrl'] as String?,
      teacherName: json['teacherName'] as String?,
      marks: json['marks'] as int?,
      totalMarks: json['totalMarks'] as int?,
    );
  }

  bool get isOverdue => status == HomeworkStatus.pending && DateTime.now().isAfter(dueDate);
}

// =============================================================================
// Fees Models
// =============================================================================

enum PaymentStatus { paid, pending, overdue, partial }

class FeeRecord {
  final String id;
  final String title;
  final double amount;
  final double? paidAmount;
  final PaymentStatus status;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String? receiptUrl;
  final String? transactionId;

  const FeeRecord({
    required this.id, required this.title, required this.amount,
    this.paidAmount, required this.status, required this.dueDate,
    this.paidDate, this.receiptUrl, this.transactionId,
  });

  factory FeeRecord.fromJson(Map<String, dynamic> json) {
    return FeeRecord(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble(),
      status: PaymentStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String?),
        orElse: () => PaymentStatus.pending,
      ),
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
      paidDate: json['paidDate'] != null ? DateTime.tryParse(json['paidDate']) : null,
      receiptUrl: json['receiptUrl'] as String?,
      transactionId: json['transactionId'] as String?,
    );
  }

  double get balanceDue => amount - (paidAmount ?? 0);
}

// =============================================================================
// Exam & Result Models
// =============================================================================

class ExamSchedule {
  final String id;
  final String examName;
  final String subject;
  final DateTime date;
  final String time;
  final String room;
  final int totalMarks;

  const ExamSchedule({
    required this.id, required this.examName, required this.subject,
    required this.date, required this.time, required this.room,
    required this.totalMarks,
  });

  factory ExamSchedule.fromJson(Map<String, dynamic> json) {
    return ExamSchedule(
      id: json['id'] as String? ?? '',
      examName: json['examName'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      time: json['time'] as String? ?? '',
      room: json['room'] as String? ?? '',
      totalMarks: json['totalMarks'] as int? ?? 100,
    );
  }
}

class SubjectResult {
  final String subject;
  final int marksObtained;
  final int totalMarks;
  final String grade;

  const SubjectResult({
    required this.subject, required this.marksObtained,
    required this.totalMarks, required this.grade,
  });

  factory SubjectResult.fromJson(Map<String, dynamic> json) {
    return SubjectResult(
      subject: json['subject'] as String? ?? '',
      marksObtained: json['marksObtained'] as int? ?? 0,
      totalMarks: json['totalMarks'] as int? ?? 100,
      grade: json['grade'] as String? ?? 'N/A',
    );
  }

  double get percentage => totalMarks > 0 ? (marksObtained / totalMarks) * 100 : 0;
}

class ReportCard {
  final String examName;
  final List<SubjectResult> results;
  final double overallPercentage;
  final String overallGrade;
  final double gpa;

  const ReportCard({
    required this.examName, required this.results,
    required this.overallPercentage, required this.overallGrade,
    required this.gpa,
  });

  factory ReportCard.fromJson(Map<String, dynamic> json) {
    return ReportCard(
      examName: json['examName'] as String? ?? '',
      results: (json['results'] as List? ?? []).map((r) => SubjectResult.fromJson(r)).toList(),
      overallPercentage: (json['overallPercentage'] as num?)?.toDouble() ?? 0,
      overallGrade: json['overallGrade'] as String? ?? 'N/A',
      gpa: (json['gpa'] as num?)?.toDouble() ?? 0,
    );
  }
}

// =============================================================================
// Timetable Models
// =============================================================================

class TimetableSlot {
  final String id;
  final String subject;
  final String teacherName;
  final String room;
  final String startTime;
  final String endTime;
  final int dayOfWeek; // 1=Mon, 7=Sun
  final Color? subjectColor;

  const TimetableSlot({
    required this.id, required this.subject, required this.teacherName,
    required this.room, required this.startTime, required this.endTime,
    required this.dayOfWeek, this.subjectColor,
  });

  factory TimetableSlot.fromJson(Map<String, dynamic> json) {
    return TimetableSlot(
      id: json['id'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      teacherName: json['teacherName'] as String? ?? '',
      room: json['room'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      dayOfWeek: json['dayOfWeek'] as int? ?? 1,
    );
  }
}

// =============================================================================
// Notification Models
// =============================================================================

enum NotificationType { general, academic, fees, event, attendance, homework }

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;

  const NotificationItem({
    required this.id, required this.title, required this.body,
    required this.type, required this.createdAt,
    this.isRead = false, this.actionUrl,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: NotificationType.values.firstWhere(
        (t) => t.name == (json['type'] as String?),
        orElse: () => NotificationType.general,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
    );
  }
}

// =============================================================================
// Profile Models
// =============================================================================

class StudentProfile {
  final UserModel user;
  final String className;
  final String section;
  final String rollNumber;
  final String? fatherName;
  final String? motherName;
  final String? phone;
  final String? address;
  final String? bloodGroup;
  final DateTime? dateOfBirth;
  final String? avatarUrl;

  const StudentProfile({
    required this.user, required this.className,
    required this.section, required this.rollNumber,
    this.fatherName, this.motherName, this.phone,
    this.address, this.bloodGroup, this.dateOfBirth, this.avatarUrl,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      className: json['className'] as String? ?? '',
      section: json['section'] as String? ?? '',
      rollNumber: json['rollNumber'] as String? ?? '',
      fatherName: json['fatherName'] as String?,
      motherName: json['motherName'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.tryParse(json['dateOfBirth']) : null,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
