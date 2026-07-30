import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/shared/router/app_router.dart';

class StudentDrawer extends ConsumerWidget {
  const StudentDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final authState = ref.watch(authControllerProvider);
    final user = authState.currentUser;
    final userName = user?.name ?? 'Student';
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      child: Column(
        children: [
          // ── Gradient Header ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16.h,
              bottom: 20.h,
              left: 20.w,
              right: 12.w,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A5568), Color(0xFF5B67F4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48.r,
                  height: 48.r,
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            user.avatarUrl!,
                            fit: BoxFit.cover,
                            width: 36.r,
                            height: 36.r,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, color: Colors.white),
                          ),
                        )
                      : const Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '- | Roll No.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // ── Scrollable Menu ──
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(title: 'STUDENT PORTAL'),

                  _DrawerTile(
                    icon: Icons.grid_view_rounded,
                    title: 'Overview',
                    iconColor: const Color(0xFF5B67F4),
                    isSelected: currentRoute == RoutePaths.studentDashboard,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.studentDashboard);
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.calendar_month_rounded,
                    title: 'My Timetable',
                    iconColor: const Color(0xFF2FA2B9),
                    isSelected: currentRoute.startsWith(RoutePaths.timetable),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.timetable);
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.assignment_rounded,
                    title: 'My Exams',
                    iconColor: const Color(0xFFE85A9A),
                    isSelected: currentRoute.startsWith(RoutePaths.exams),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.exams);
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.check_circle_rounded,
                    title: 'My Attendance',
                    iconColor: AppColors.success,
                    isSelected: currentRoute.startsWith(RoutePaths.attendance),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.attendance);
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.campaign_rounded,
                    title: 'Notice Board',
                    iconColor: const Color(0xFFFF7A3A),
                    isSelected: currentRoute.startsWith(RoutePaths.notifications),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.notifications);
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.assignment_turned_in_rounded,
                    title: 'My Homework',
                    iconColor: const Color(0xFF8E44AD),
                    isSelected: currentRoute.startsWith(RoutePaths.homework),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.homework);
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.video_camera_front_rounded,
                    title: 'Live Meetings',
                    iconColor: const Color(0xFFE74C3C),
                    isSelected: currentRoute.startsWith(RoutePaths.meetings),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.meetings);
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.person_rounded,
                    title: 'Profile',
                    iconColor: const Color(0xFF6C5CE7),
                    isSelected: currentRoute == RoutePaths.profile,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.profile);
                    },
                  ),
                  SizedBox(height: 8.h),
                  _DrawerTile(
                    icon: Icons.menu_book_rounded,
                    title: 'Study Materials',
                    iconColor: const Color(0xFF3498DB),
                    isSelected: currentRoute.startsWith(RoutePaths.content),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.content);
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.receipt_long_rounded,
                    title: 'Fee Details',
                    iconColor: const Color(0xFF1ABC9C),
                    isSelected: currentRoute.startsWith(RoutePaths.fees),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.fees);
                    },
                  ),

                  _SectionLabel(title: 'ACCOUNT'),
                  _DrawerTile(
                    icon: Icons.person_outline_rounded,
                    title: 'My Profile',
                    iconColor: const Color(0xFF6C5CE7),
                    isSelected: currentRoute.startsWith(RoutePaths.profile),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.profile);
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Sign Out ──
          Divider(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
            height: 1,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            child: _DrawerTile(
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              iconColor: AppColors.error,
              isSelected: false,
              isDestructive: true,
              onTap: () async {
                final authController = ref.read(authControllerProvider.notifier);
                await authController.logout(() {
                  ref.read(routerProvider).go(RoutePaths.login);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Label ──
class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, top: 20.h, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF94A3B8),
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ── Drawer Tile ──
class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final bool isSelected;
  final bool isDestructive;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color textColor = isDestructive
        ? AppColors.error
        : isSelected
            ? iconColor
            : (isDark ? AppColors.darkTextPrimary : const Color(0xFF334155));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isSelected ? iconColor.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? iconColor : iconColor.withValues(alpha: 0.7), size: 22.r),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.5.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
