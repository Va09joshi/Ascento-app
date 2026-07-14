import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ascento_abacus/shared/providers/feature_providers.dart';

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
        _NavItem('Alerts', FontAwesomeIcons.bell, FontAwesomeIcons.solidBell, RoutePaths.notifications),
      ];
    } else if (role == UserRole.teacher) {
      return [
        _NavItem('Dashboard', FontAwesomeIcons.house, FontAwesomeIcons.solidHouse, RoutePaths.teacherDashboard),
        _NavItem('Timetable', FontAwesomeIcons.clock, FontAwesomeIcons.solidClock, RoutePaths.timetable),
        _NavItem('Profile', FontAwesomeIcons.user, FontAwesomeIcons.solidUser, RoutePaths.profile),
        _NavItem('Alerts', FontAwesomeIcons.bell, FontAwesomeIcons.solidBell, RoutePaths.notifications),
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
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF5B62E6), const Color(0xFF3D3FA8)]
                        : [const Color(0xFF5B67F4), const Color(0xFF7B4DE6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.school_rounded,
                              size: 26,
                              color: Colors.white,
                            ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            classLabel,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  children: [
                    if (user?.role == UserRole.admin || user?.role == UserRole.superAdmin) ...[
                      _DrawerSection(title: 'Admin Console'),
                      _DrawerItem(
                        icon: Icons.dashboard_rounded,
                        label: 'Overview',
                        active: currentPath == RoutePaths.adminDashboard,
                        accent: const Color(0xFF5B67F4),
                        onTap: () => _go(context, RoutePaths.adminDashboard),
                      ),
                      _DrawerItem(
                        icon: Icons.account_tree_rounded,
                        label: 'Manage Branches',
                        active: currentPath == RoutePaths.manageBranches,
                        accent: const Color(0xFFFF8A34),
                        onTap: () => _go(context, RoutePaths.manageBranches),
                      ),
                      _DrawerItem(
                        icon: Icons.manage_accounts_rounded,
                        label: 'Users & Roles',
                        active: currentPath == RoutePaths.manageUsers,
                        accent: const Color(0xFF2FAE78),
                        onTap: () => _go(context, RoutePaths.manageUsers),
                      ),
                      _DrawerItem(
                        icon: Icons.category_rounded,
                        label: 'Manage Domains',
                        active: currentPath == RoutePaths.manageDomains,
                        accent: const Color(0xFFD946EF),
                        onTap: () => _go(context, RoutePaths.manageDomains),
                      ),
                      _DrawerItem(
                        icon: Icons.school_rounded,
                        label: 'Academics Config',
                        active: currentPath == RoutePaths.academicsConfig,
                        accent: const Color(0xFF6C4ED9),
                        onTap: () => _go(context, RoutePaths.academicsConfig),
                      ),

                      _DrawerItem(
                        icon: Icons.co_present_rounded,
                        label: 'Attendance Data',
                        active: currentPath == RoutePaths.attendance,
                        accent: const Color(0xFFF9A826),
                        onTap: () => _go(context, RoutePaths.attendance),
                      ),
                      _DrawerItem(
                        icon: Icons.access_time_filled_rounded,
                        label: 'Timetable Setup',
                        active: currentPath == RoutePaths.timetable,
                        accent: const Color(0xFF00B4D8),
                        onTap: () => _go(context, RoutePaths.timetable),
                      ),
                      _DrawerItem(
                        icon: Icons.assignment_rounded,
                        label: 'Exams Config',
                        active: currentPath == RoutePaths.exams,
                        accent: const Color(0xFF9D4EDD),
                        onTap: () => _go(context, RoutePaths.exams),
                      ),
                      _DrawerItem(
                        icon: Icons.campaign_rounded,
                        label: 'Notices Board',
                        active: currentPath == RoutePaths.notifications,
                        accent: const Color(0xFFFF5400),
                        onTap: () => _go(context, RoutePaths.notifications),
                      ),
                    ] else if (user?.role == UserRole.teacher) ...[
                      _DrawerSection(title: 'Teacher Portal'),
                      _DrawerItem(
                        icon: Icons.dashboard_rounded,
                        label: 'My Dashboard',
                        active: currentPath == RoutePaths.teacherDashboard,
                        accent: const Color(0xFF5B67F4),
                        onTap: () => _go(context, RoutePaths.teacherDashboard),
                      ),
                      _DrawerItem(
                        icon: Icons.class_rounded,
                        label: 'My Classes',
                        active: false,
                        accent: const Color(0xFFFF8A34),
                        onTap: () => _showComingSoon(context),
                      ),
                      _DrawerItem(
                        icon: Icons.how_to_reg_rounded,
                        label: 'Mark Attendance',
                        active: currentPath == RoutePaths.attendance,
                        accent: const Color(0xFF2FAE78),
                        onTap: () => _go(context, RoutePaths.attendance),
                      ),
                      _DrawerItem(
                        icon: Icons.assignment_turned_in_rounded,
                        label: 'Exam Results',
                        active: false,
                        accent: const Color(0xFF6C4ED9),
                        onTap: () => _showComingSoon(context),
                      ),
                      _DrawerItem(
                        icon: Icons.access_time_rounded,
                        label: 'Timetable',
                        active: currentPath == RoutePaths.timetable,
                        accent: const Color(0xFFE85A9A),
                        onTap: () => _go(context, RoutePaths.timetable),
                      ),
                    ] else ...[
                      _DrawerSection(title: 'Student Portal'),
                      _DrawerItem(
                        icon: Icons.grid_view_rounded,
                        label: 'Overview',
                        active: currentPath == RoutePaths.studentDashboard,
                        accent: const Color(0xFF5B67F4),
                        onTap: () => _go(context, RoutePaths.studentDashboard),
                      ),
                      _DrawerItem(
                        icon: Icons.calendar_month_rounded,
                        label: 'My Timetable',
                        active: currentPath == RoutePaths.timetable,
                        accent: const Color(0xFF2FA2B9),
                        onTap: () => _go(context, RoutePaths.timetable),
                      ),
                      _DrawerItem(
                        icon: Icons.assignment_rounded,
                        label: 'My Exams',
                        active: currentPath == RoutePaths.exams,
                        accent: const Color(0xFFE85A9A),
                        onTap: () => _go(context, RoutePaths.exams),
                      ),
                      _DrawerItem(
                        icon: Icons.check_circle_rounded,
                        label: 'My Attendance',
                        active: currentPath == RoutePaths.attendance,
                        accent: const Color(0xFF2FAE78),
                        onTap: () => _go(context, RoutePaths.attendance),
                      ),
                      _DrawerItem(
                        icon: Icons.campaign_rounded,
                        label: 'Notice Board',
                        active: currentPath == RoutePaths.notifications,
                        accent: const Color(0xFFFF7A3A),
                        onTap: () => _go(context, RoutePaths.notifications),
                      ),
                      _DrawerItem(
                        icon: Icons.assignment_turned_in_rounded,
                        label: 'My Homework',
                        active: currentPath == RoutePaths.homework,
                        accent: const Color(0xFF8E44AD),
                        onTap: () => _go(context, RoutePaths.homework),
                      ),
                      _DrawerItem(
                        icon: Icons.video_camera_front_rounded,
                        label: 'Live Meetings',
                        active: currentPath == RoutePaths.meetings,
                        accent: const Color(0xFFE74C3C),
                        onTap: () => _go(context, RoutePaths.meetings),
                      ),
                      _DrawerItem(
                        icon: Icons.menu_book_rounded,
                        label: 'Study Materials',
                        active: currentPath == RoutePaths.content,
                        accent: const Color(0xFF3498DB),
                        onTap: () => _go(context, RoutePaths.content),
                      ),
                      _DrawerItem(
                        icon: Icons.receipt_long_rounded,
                        label: 'Fee Details',
                        active: currentPath == RoutePaths.fees,
                        accent: const Color(0xFF1ABC9C),
                        onTap: () => _go(context, RoutePaths.fees),
                      ),
                      SizedBox(height: 6.h),
                      _DrawerSection(title: 'Account'),
                      _DrawerItem(
                        icon: Icons.person_outline_rounded,
                        label: 'My Profile',
                        active: currentPath == RoutePaths.profile,
                        accent: const Color(0xFF6C5CE7),
                        onTap: () => _go(context, RoutePaths.profile),
                      ),
                    ],
                    SizedBox(height: 12.h),
                    const Divider(),
                    _DrawerItem(
                      icon: Icons.logout_rounded,
                      label: 'Sign Out',
                      active: false,
                      isDanger: true,
                      onTap: () {
                        Navigator.of(context).pop();
                        ref.read(authControllerProvider.notifier).logout(() {
                          context.go(RoutePaths.login);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    if (currentPath == RoutePaths.notifications) return 'Notifications';
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

class _DrawerSection extends StatelessWidget {
  final String title;
  const _DrawerSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, top: 8.h, bottom: 6.h),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 1.1,
          fontWeight: FontWeight.bold,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool isDanger;
  final Color? accent;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.isDanger = false,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color activeColor = isDanger
        ? AppColors.error
        : AppColors.primary;
    final Color iconColor = isDanger
        ? AppColors.error
        : (active
              ? activeColor
              : (isDark ? AppColors.darkTextMuted : AppColors.textMuted));
    final Color textColor = isDanger
        ? AppColors.error
        : (active
              ? activeColor
              : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        margin: EdgeInsets.only(bottom: 4.h),
        decoration: BoxDecoration(
          color: active
              ? activeColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.08),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: active 
                    ? activeColor.withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
