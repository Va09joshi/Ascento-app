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
  final String? submissionUrl;
  final String? teacherName;
  final int? marks;
  final int? totalMarks;

  const HomeworkItem({
    required this.id, required this.title, required this.subject,
    required this.description, required this.dueDate, required this.status,
    this.attachmentUrl, this.submissionUrl, this.teacherName, this.marks, this.totalMarks,
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
      attachmentUrl: json['file_url'] as String? ?? json['attachmentUrl'] as String?,
      submissionUrl: json['submissionUrl'] as String?,
      teacherName: json['teacherName'] as String?,
      marks: json['marks'] as int?,
      totalMarks: json['totalMarks'] as int?,
    );
  }

  bool get isOverdue => status == HomeworkStatus.pending && DateTime.now().isAfter(dueDate);
}

class HomeworkSubmission {
  final String id;
  final String homeworkId;
  final String studentId;
  final String? studentName;
  final String? studentEmail;
  final String fileUrl;
  final String status;
  final DateTime submittedAt;
  final int? grade;
  final String? remarks;

  const HomeworkSubmission({
    required this.id, required this.homeworkId, required this.studentId,
    this.studentName, this.studentEmail, required this.fileUrl, required this.status,
    required this.submittedAt, this.grade, this.remarks,
  });

  factory HomeworkSubmission.fromJson(Map<String, dynamic> json) {
    return HomeworkSubmission(
      id: json['id'] as String? ?? '',
      homeworkId: json['homework_id'] as String? ?? '',
      studentId: json['student_id'] as String? ?? '',
      studentName: json['users']?['full_name'] as String?,
      studentEmail: json['users']?['email'] as String?,
      fileUrl: json['file_url'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      submittedAt: DateTime.tryParse(json['submitted_at'] as String? ?? '') ?? DateTime.now(),
      grade: json['grade'] as int?,
      remarks: json['remarks'] as String?,
    );
  }
}

// =============================================================================
// Content Models
// =============================================================================

class ContentItem {
  final String id;
  final String title;
  final String description;
  final String type; // 'pdf', 'image', 'video'
  final String publicUrl;
  final DateTime createdAt;
  final String? classId;
  final String? sectionId;
  final String? className;
  final String? sectionName;
  final String? creatorRole;

  const ContentItem({
    required this.id, required this.title, required this.description,
    required this.type, required this.publicUrl, required this.createdAt,
    this.classId, this.sectionId, this.className, this.sectionName, this.creatorRole,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'document',
      publicUrl: json['public_url'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      classId: json['class_id'] as String?,
      sectionId: json['section_id'] as String?,
      className: json['class_name'] as String?,
      sectionName: json['section_name'] as String?,
      creatorRole: json['creator_role'] as String?,
    );
  }
}

// =============================================================================
// Meeting Models
// =============================================================================

class MeetingItem {
  final String id;
  final String title;
  final String meetLink;
  final DateTime meetDate;
  final String startTime;
  final String endTime;
  final String? className;
  final String? sectionName;
  final String? classId;
  final String? sectionId;

  const MeetingItem({
    required this.id, required this.title, required this.meetLink,
    required this.meetDate, required this.startTime, required this.endTime,
    this.className, this.sectionName, this.classId, this.sectionId,
  });

  factory MeetingItem.fromJson(Map<String, dynamic> json) {
    return MeetingItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      meetLink: json['meet_link'] as String? ?? '',
      meetDate: DateTime.tryParse(json['meet_date'] as String? ?? '') ?? DateTime.now(),
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      className: json['classes']?['name'] as String?,
      sectionName: json['sections']?['name'] as String?,
      classId: json['class_id'] as String?,
      sectionId: json['section_id'] as String?,
    );
  }
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
  final String? type;
  final String? classId;
  final String? academicYearId;

  const ExamSchedule({
    required this.id, required this.examName, required this.subject,
    required this.date, required this.time, required this.room,
    required this.totalMarks, this.type, this.classId, this.academicYearId
  });

  factory ExamSchedule.fromJson(Map<String, dynamic> json) {
    return ExamSchedule(
      id: json['id'] as String? ?? '',
      examName: json['title'] as String? ?? json['examName'] as String? ?? '',
      subject: json['subject_id'] as String? ?? json['subject'] as String? ?? 'General',
      date: DateTime.tryParse(json['exam_date'] as String? ?? json['date'] as String? ?? '') ?? DateTime.now(),
      time: json['start_time'] as String? ?? json['time'] as String? ?? '09:00',
      room: json['room'] as String? ?? 'Main Hall',
      totalMarks: json['total_marks'] as int? ?? json['totalMarks'] as int? ?? 100,
      type: json['type'] as String?,
      classId: json['class_id'] as String?,
      academicYearId: json['academic_year_id'] as String?,
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
    int parseDay(dynamic dayVal) {
      if (dayVal is int) return dayVal;
      if (dayVal is String) {
        switch (dayVal.toLowerCase()) {
          case 'monday': return 1;
          case 'tuesday': return 2;
          case 'wednesday': return 3;
          case 'thursday': return 4;
          case 'friday': return 5;
          case 'saturday': return 6;
          case 'sunday': return 7;
        }
      }
      return 1;
    }

    return TimetableSlot(
      id: json['id'] as String? ?? '',
      subject: json['subjects']?['name'] as String? ?? json['subject'] as String? ?? '',
      teacherName: json['users']?['full_name'] as String? ?? json['teacherName'] as String? ?? '',
      room: json['room_name'] as String? ?? json['room'] as String? ?? '',
      startTime: json['start_time'] as String? ?? json['startTime'] as String? ?? '',
      endTime: json['end_time'] as String? ?? json['endTime'] as String? ?? '',
      dayOfWeek: parseDay(json['day_of_week'] ?? json['dayOfWeek']),
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
  final String? imageUrl;

  const NotificationItem({
    required this.id, required this.title, required this.body,
    required this.type, required this.createdAt,
    this.isRead = false, this.actionUrl, this.imageUrl,
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
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

// =============================================================================
// Profile Models
// =============================================================================

class StudentProfile {
  final UserModel user;
  final String className;
  final String? classId;
  final String section;
  final String? sectionId;
  final String rollNumber;
  final String? fatherName;
  final String? motherName;
  final String? phone;
  final String? address;
  final String? bloodGroup;
  final DateTime? dateOfBirth;
  final String? avatarUrl;
  final String? timetablePdfUrl;

  const StudentProfile({
    required this.user, required this.className,
    this.classId,
    required this.section, this.sectionId, required this.rollNumber,
    this.fatherName, this.motherName, this.phone,
    this.address, this.bloodGroup, this.dateOfBirth, this.avatarUrl,
    this.timetablePdfUrl,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? json),
      className: json['className'] as String? ?? '',
      classId: json['classId'] as String?,
      section: json['section'] as String? ?? '',
      sectionId: json['sectionId'] as String?,
      rollNumber: json['rollNumber'] as String? ?? '',
      fatherName: json['fatherName'] as String?,
      motherName: json['motherName'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.tryParse(json['dateOfBirth']) : null,
      avatarUrl: json['avatarUrl'] as String?,
      timetablePdfUrl: json['timetablePdfUrl'] as String?,
    );
  }
}

// =============================================================================
// Teacher Models
// =============================================================================

class TeacherDashboardStats {
  final int totalStudents;
  final int pendingHomework;
  final int upcomingMeetings;
  final int unreadNotices;
  final List<TimetableSlot> upcomingClasses;

  const TeacherDashboardStats({
    required this.totalStudents,
    required this.pendingHomework,
    required this.upcomingMeetings,
    required this.unreadNotices,
    required this.upcomingClasses,
  });

  factory TeacherDashboardStats.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardStats(
      totalStudents: json['total_students'] as int? ?? 0,
      pendingHomework: json['pending_homework'] as int? ?? 0,
      upcomingMeetings: json['upcoming_meetings'] as int? ?? json['today_meetings'] as int? ?? 0,
      unreadNotices: json['unread_notices'] as int? ?? 0,
      upcomingClasses: (json['upcoming_classes'] as List? ?? []).map((e) => TimetableSlot.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class SectionStudent {
  final String studentId;
  final String? rollNumber;
  final String fullName;
  final String? email;
  final String? phone;
  final String? avatarUrl;

  const SectionStudent({
    required this.studentId,
    this.rollNumber,
    required this.fullName,
    this.email,
    this.phone,
    this.avatarUrl,
  });

  factory SectionStudent.fromJson(Map<String, dynamic> json) {
    return SectionStudent(
      studentId: json['student_id'] as String? ?? '',
      rollNumber: json['roll_number'] as String?,
      fullName: json['full_name'] as String? ?? 'Unknown',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class SectionStudentsModel {
  final String sectionId;
  final String sectionName;
  final String? className;
  final List<SectionStudent> students;

  const SectionStudentsModel({
    required this.sectionId,
    required this.sectionName,
    this.className,
    required this.students,
  });

  factory SectionStudentsModel.fromJson(Map<String, dynamic> json) {
    return SectionStudentsModel(
      sectionId: json['section_id'] as String? ?? '',
      sectionName: json['section_name'] as String? ?? '',
      className: json['class_name'] as String?,
      students: (json['students'] as List? ?? [])
          .map((e) => SectionStudent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
