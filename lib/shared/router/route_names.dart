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
  static const String forceChangePassword = 'forceChangePassword';

  // Shell Dashboard Tabs / Drawer
  static const String dashboard = 'dashboard';
  static const String adminDashboard = 'adminDashboard';
  static const String teacherDashboard = 'teacherDashboard';
  static const String studentDashboard = 'studentDashboard';
  static const String manageUsers = 'manageUsers';
  static const String manageBranches = 'manageBranches';
  static const String manageDomains = 'manageDomains';
  static const String academicsConfig = 'academicsConfig';
  static const String addUser = 'addUser';
  static const String editUser = 'editUser';
  static const String addBranch = 'addBranch';
  static const String editBranch = 'editBranch';
  
  static const String addAcademicYear = 'addAcademicYear';
  static const String editAcademicYear = 'editAcademicYear';
  static const String addClass = 'addClass';
  static const String editClass = 'editClass';
  static const String addSection = 'addSection';
  static const String editSection = 'editSection';
  static const String addSubject = 'addSubject';
  static const String editSubject = 'editSubject';
  static const String addExam = 'addExam';
  static const String editExam = 'editExam';

  static const String simulator = 'simulator';
  static const String profile = 'profile';
  static const String attendance = 'attendance';
  static const String exams = 'exams';
  static const String fees = 'fees';
  static const String homework = 'homework';
  static const String meetings = 'meetings';
  static const String notifications = 'notifications';
  static const String noticeDetails = 'noticeDetails';
  static const String adminNoticeDetails = 'adminNoticeDetails';
  static const String addNotice = 'addNotice';
  static const String editNotice = 'editNotice';
  static const String timetable = 'timetable';
  static const String teacherStudents = 'teacherStudents';
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
  static const String forceChangePassword = '/force-change-password';

  static const String dashboard = '/dashboard'; // default fallback
  static const String adminDashboard = '/admin-dashboard';
  static const String teacherDashboard = '/teacher-dashboard';
  static const String studentDashboard = '/student-dashboard';
  static const String manageUsers = '/manage-users';
  static const String manageBranches = '/manage-branches';
  static const String manageDomains = '/manage-domains';
  static const String academicsConfig = '/academics-config';
  static const String addUser = '/manage-users/add';
  static const String editUser = '/manage-users/edit';
  static const String addBranch = '/manage-branches/add';
  static const String editBranch = '/manage-branches/edit';
  
  static const String addAcademicYear = '/academics-config/years/add';
  static const String editAcademicYear = '/academics-config/years/edit';
  static const String addClass = '/academics-config/classes/add';
  static const String editClass = '/academics-config/classes/edit';
  static const String addSection = '/academics-config/sections/add';
  static const String editSection = '/academics-config/sections/edit';
  static const String addSubject = '/academics-config/subjects/add';
  static const String editSubject = '/academics-config/subjects/edit';

  static const String simulator = '/simulator';
  static const String profile = '/profile';
  static const String attendance = '/attendance';
  static const String exams = '/exams';
  static const String addExam = '/exams/add';
  static const String editExam = '/exams/edit';
  static const String fees = '/fees';
  static const String homework = '/homework';
  static const String meetings = '/meetings';
  static const String notifications = '/notifications';
  static const String noticeDetails = '/notifications/details';
  static const String adminNoticeDetails = '/notifications/admin-details';
  static const String addNotice = '/notifications/add';
  static const String editNotice = '/notifications/edit';
  static const String timetable = '/timetable';
  static const String teacherStudents = '/teacher-students';
  static const String enquiry = '/enquiry';
  static const String programs = '/programs';
  static const String content = '/content';

  static const String error = '/error';
}
