import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/shared/router/app_router.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ascento_abacus/shared/providers/feature_providers.dart';
import 'package:ascento_abacus/shared/widgets/drawer/admin_drawer.dart';
import 'package:ascento_abacus/shared/widgets/drawer/teacher_drawer.dart';
import 'package:ascento_abacus/shared/widgets/drawer/student_drawer.dart';
import 'package:ascento_abacus/shared/widgets/drawer/drawer_item.dart';

class _NavItem {
  final String label;
  final dynamic icon;
  final dynamic activeIcon;
  final String route;

  _NavItem(this.label, this.icon, this.activeIcon, this.route);
}

class NavigationShell extends ConsumerWidget {
  final Widget child;
  final String currentPath;

  const NavigationShell({
    super.key,
    required this.child,
    required this.currentPath,
  });

  List<_NavItem> _getNavItems(UserRole? role) {
    if (role == UserRole.admin || role == UserRole.superAdmin) {
      return [
        _NavItem('Overview', FontAwesomeIcons.chartPie, FontAwesomeIcons.chartPie, RoutePaths.adminDashboard),
        _NavItem('Users', FontAwesomeIcons.users, FontAwesomeIcons.users, RoutePaths.manageUsers),
        _NavItem('Profile', FontAwesomeIcons.user, FontAwesomeIcons.solidUser, RoutePaths.profile),
        _NavItem('Notices', FontAwesomeIcons.bullhorn, FontAwesomeIcons.bullhorn, RoutePaths.notifications),
      ];
    } else if (role == UserRole.teacher) {
      return [
        _NavItem('Dashboard', FontAwesomeIcons.house, FontAwesomeIcons.solidHouse, RoutePaths.teacherDashboard),
        _NavItem('Timetable', FontAwesomeIcons.clock, FontAwesomeIcons.solidClock, RoutePaths.timetable),
        _NavItem('Profile', FontAwesomeIcons.user, FontAwesomeIcons.solidUser, RoutePaths.profile),
        _NavItem('Notices', FontAwesomeIcons.bullhorn, FontAwesomeIcons.bullhorn, RoutePaths.notifications),
      ];
    } else {
      return [
        _NavItem('Home', FontAwesomeIcons.house, FontAwesomeIcons.solidHouse, RoutePaths.studentDashboard),
        _NavItem('Attendance', FontAwesomeIcons.calendarCheck, FontAwesomeIcons.solidCalendarCheck, RoutePaths.attendance),
        _NavItem('Exams', FontAwesomeIcons.fileLines, FontAwesomeIcons.filePen, RoutePaths.exams),
        _NavItem('Fees', FontAwesomeIcons.creditCard, FontAwesomeIcons.solidCreditCard, RoutePaths.fees),
      ];
    }
  }

  int _getSelectedIndex(List<_NavItem> items) {
    final index = items.indexWhere((item) => item.route == currentPath);
    return index >= 0 ? index : 0;
  }

  void _onItemTapped(int index, BuildContext context, List<_NavItem> items) {
    if (index >= 0 && index < items.length) {
      context.go(items[index].route);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authControllerProvider).currentUser;
    final profileAsync = ref.watch(studentProfileProvider);
    final profile = profileAsync.asData?.value;
    String name = 'Guest User';
    String classLabel = '- | Roll No. -';
    if (user != null && user.role != UserRole.student && user.role != UserRole.parent) {
      name = user.name.isNotEmpty ? user.name : 'Staff';
      classLabel = user.role == UserRole.superAdmin 
          ? 'Super Administrator' 
          : (user.role.name.isNotEmpty ? user.role.name[0].toUpperCase() + user.role.name.substring(1) : 'Staff');
    } else if (profile != null) {
      name = profile.user.name;
      classLabel = '${profile.className} - ${profile.section} | Roll No. ${profile.rollNumber}';
    } else if (user != null) {
      name = user.name;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      // --- School Management Drawer Menu ---
      drawer: Drawer(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        child: Column(
          children: [
            // Modern Header Profile Card
            Container(
              padding: EdgeInsets.fromLTRB(24.w, MediaQuery.of(context).padding.top + 24.h, 24.w, 24.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF5B62E6).withValues(alpha: 0.15), Colors.transparent]
                      : [const Color(0xFF5B67F4).withValues(alpha: 0.1), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56.r,
                    height: 56.r,
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B67F4).withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        )
                      ],
                      border: Border.all(
                        color: const Color(0xFF5B67F4).withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(
                            Icons.school_rounded,
                            size: 28.r,
                            color: const Color(0xFF5B67F4),
                          ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            fontSize: 16.sp,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5B67F4).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            classLabel,
                            style: TextStyle(
                              color: const Color(0xFF5B67F4),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black45, size: 24.r),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                children: [
                  if (user?.role == UserRole.admin || user?.role == UserRole.superAdmin)
                    AdminDrawer(
                      currentPath: currentPath,
                      onNavigate: (route) => _go(context, route),
                    )
                  else if (user?.role == UserRole.teacher)
                    TeacherDrawer(
                      currentPath: currentPath,
                      onNavigate: (route) => _go(context, route),
                    )
                  else
                    StudentDrawer(
                      currentPath: currentPath,
                      onNavigate: (route) => _go(context, route),
                    ),
                ],
              ),
            ),
            
            // Persistent Footer for Sign Out
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, MediaQuery.of(context).padding.bottom + 16.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : const Color(0xFF5B67F4)).withValues(alpha: 0.04),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  )
                ],
              ),
              child: Builder(
                builder: (innerContext) {
                  return DrawerItem(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    active: false,
                    isDanger: true,
                    onTap: () {
                      final router = ref.read(routerProvider);
                      Navigator.of(innerContext).pop();
                      ref.read(authControllerProvider.notifier).logout(() {
                        router.go(RoutePaths.login);
                      });
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
      // We wrap the nested sub-views in an app bar holding drawer triggers
      appBar: AppBar(
        title: Text(
          _getTabTitle(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (currentPath != RoutePaths.notifications)
            IconButton(
              onPressed: () => context.go(RoutePaths.notifications),
              icon: Stack(
                alignment: Alignment.topRight,
                children: [
                  const Icon(Icons.notifications_none_rounded),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 2, right: 2),
                    decoration: const BoxDecoration(
                      color: AppColors.info,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: child,
      // --- Bottom Navigation Bar ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black45 : const Color(0xFF1F2328).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 68.h,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final navItems = _getNavItems(user?.role);
                final tabWidth = constraints.maxWidth / navItems.length;
                final selectedIndex = _getSelectedIndex(navItems);
                final indicatorColor = isDark ? AppColors.darkPrimary : AppColors.primary;

                return Stack(
                  children: [
                    // Animated Line Indicator at the top
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      top: 0,
                      left: selectedIndex * tabWidth,
                      child: Container(
                        width: tabWidth,
                        alignment: Alignment.center,
                        child: Container(
                          width: 44.w,
                          height: 3.h,
                          decoration: BoxDecoration(
                            color: indicatorColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(4.r),
                              bottomRight: Radius.circular(4.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // The Nav Items
                    Row(
                      children: List.generate(navItems.length, (index) {
                        final item = navItems[index];
                        return _buildNavItem(
                          context: context, 
                          index: index, 
                          label: item.label, 
                          icon: item.icon, 
                          activeIcon: item.activeIcon, 
                          width: tabWidth, 
                          activeColor: indicatorColor,
                          navItems: navItems,
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context, 
    required int index, 
    required String label, 
    required dynamic icon, 
    required dynamic activeIcon, 
    required double width, 
    required Color activeColor,
    required List<_NavItem> navItems,
  }) {
    final isSelected = _getSelectedIndex(navItems) == index;
    final theme = Theme.of(context);
    final color = isSelected ? activeColor : AppColors.textMuted;

    return GestureDetector(
      onTap: () => _onItemTapped(index, context, navItems),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 4.h),
            FaIcon(
              isSelected ? activeIcon : icon,
              size: 20.r,
              color: color,
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: color,
                fontSize: 10.5.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTabTitle() {
    if (currentPath == RoutePaths.dashboard) return 'Ascento Abacus';
    if (currentPath == RoutePaths.manageUsers) return 'Users & Roles';
    if (currentPath == RoutePaths.manageDomains) return 'Manage Domains';
    if (currentPath == RoutePaths.programs) return 'Flagship Programs';
    if (currentPath == RoutePaths.attendance) return 'Attendance';
    if (currentPath == RoutePaths.exams) return 'Exams';
    if (currentPath == RoutePaths.fees) return 'Fees';
    if (currentPath == RoutePaths.profile) return 'Profile';
    if (currentPath == RoutePaths.homework) return 'Homework';
    if (currentPath == RoutePaths.notifications) return 'Notices';
    if (currentPath == RoutePaths.timetable) return 'Timetable';
    if (currentPath == RoutePaths.enquiry) return 'Enquiry Form';
    if (currentPath == RoutePaths.content) return 'Notes & Materials';
    return 'Ascento Abacus';
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Feature coming soon')));
  }

  void _go(BuildContext context, String route) {
    Navigator.of(context).pop();
    context.go(route);
  }
}
