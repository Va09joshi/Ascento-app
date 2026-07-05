class RouteNames {
  RouteNames._();

  // Root Boot Flow
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';

  // Authentication Flow
  static const String login = 'login';
  static const String forgotPassword = 'forgotPassword';
  static const String otpVerify = 'otpVerify';
  static const String resetPassword = 'resetPassword';

  // Shell Dashboard Tabs / Drawer
  static const String dashboard = 'dashboard';
  static const String adminDashboard = 'adminDashboard';
  static const String teacherDashboard = 'teacherDashboard';
  static const String studentDashboard = 'studentDashboard';
  static const String manageUsers = 'manageUsers';
  static const String simulator = 'simulator';
  static const String profile = 'profile';
  static const String attendance = 'attendance';
  static const String exams = 'exams';
  static const String fees = 'fees';
  static const String homework = 'homework';
  static const String notifications = 'notifications';
  static const String timetable = 'timetable';
  static const String enquiry = 'enquiry';
  static const String programs = 'programs';
  static const String content = 'content';

  // Nested Child / Leaf screens
  static const String error = 'error';
}

class RoutePaths {
  RoutePaths._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';

  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerify = '/otp-verify';
  static const String resetPassword = '/reset-password';

  static const String dashboard = '/dashboard'; // default fallback
  static const String adminDashboard = '/admin-dashboard';
  static const String teacherDashboard = '/teacher-dashboard';
  static const String studentDashboard = '/student-dashboard';
  static const String manageUsers = '/manage-users';
  static const String simulator = '/simulator';
  static const String profile = '/profile';
  static const String attendance = '/attendance';
  static const String exams = '/exams';
  static const String fees = '/fees';
  static const String homework = '/homework';
  static const String notifications = '/notifications';
  static const String timetable = '/timetable';
  static const String enquiry = '/enquiry';
  static const String programs = '/programs';
  static const String content = '/content';

  static const String error = '/error';
}
