/// Centralised API endpoint constants for Ascento Abacus.
///
/// All server paths are defined here to prevent string duplication
/// and make endpoint changes a single-point-of-update operation.
///
/// Usage:
/// ```dart
/// final response = await dioClient.post(ApiEndpoints.login, data: body);
/// ```
class ApiEndpoints {
  ApiEndpoints._();

  // -------------------------------------------------------------------------
  // Base URL
  // -------------------------------------------------------------------------
  static const String baseUrl = 'https://ascento-backend-private.onrender.com/api/v1';

  // -------------------------------------------------------------------------
  // Authentication
  // -------------------------------------------------------------------------
  static const String login          = '/auth/login';
  static const String register       = '/auth/register';
  static const String logout         = '/auth/logout';
  static const String profile        = '/auth/me';
  static const String refreshToken   = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp      = '/auth/verify-otp';
  static const String resetPassword  = '/auth/reset-password';

  // -------------------------------------------------------------------------
  // Admin & Core Entities
  // -------------------------------------------------------------------------
  static const String branches       = '/branches';
  static const String academicYears  = '/academic-years';
  static const String classes        = '/classes';
  static const String sections       = '/sections';
  static const String manageUsers    = '/admin/users';

  // -------------------------------------------------------------------------
  // Abacus Levels & Lessons
  // -------------------------------------------------------------------------
  static const String levels      = '/abacus/levels';
  static const String lessons     = '/abacus/lessons';
  static const String progress    = '/abacus/user-progress';
  static const String leaderboard = '/abacus/leaderboard';

  // -------------------------------------------------------------------------
  // Student Management
  // -------------------------------------------------------------------------
  static const String students      = '/students';
  static const String studentDetail = '/students/{id}';

  // -------------------------------------------------------------------------
  // Courses & Exams
  // -------------------------------------------------------------------------
  static const String courses        = '/courses';
  static const String courseEnroll   = '/courses/{id}/enroll';
  static const String exams          = '/exams';
  static const String examResults    = '/exams/{id}/results';
  static const String aiReport       = '/ai/student-report';

  // -------------------------------------------------------------------------
  // Attendance
  // -------------------------------------------------------------------------
  static const String attendance       = '/attendance';
  static const String attendanceBulk   = '/attendance/bulk';
  static const String attendanceReport = '/attendance/report';

  // -------------------------------------------------------------------------
  // Fees & Billing (Razorpay)
  // -------------------------------------------------------------------------
  static const String fees        = '/billing/fees';
  static const String createOrder = '/payments/create-order';
  static const String feeReceipt  = '/billing/receipt';
  static const String feeHistory  = '/billing/history';

  // -------------------------------------------------------------------------
  // Homework & Timetable
  // -------------------------------------------------------------------------
  static const String homework    = '/homework';
  static const String timetable   = '/timetable';

  // -------------------------------------------------------------------------
  // Notifications
  // -------------------------------------------------------------------------
  static const String notifications = '/notifications';

  // -------------------------------------------------------------------------
  // File Uploads
  // -------------------------------------------------------------------------
  static const String content        = '/content';
  static const String uploadAvatar   = '/uploads/avatar';
  static const String uploadDocument = '/uploads/document';

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Replaces `{id}` placeholder in endpoint paths with the actual value.
  static String withId(String endpoint, String id) {
    return endpoint.replaceAll('{id}', id);
  }
}
