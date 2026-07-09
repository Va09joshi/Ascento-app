import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';

class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final authState = ref.watch(authControllerProvider);
    final userName = authState.currentUser?.name ?? 'Super Admin';
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20.h, bottom: 20.h, left: 20.w, right: 10.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceDarker : AppColors.surface,
              border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48.r,
                  height: 48.r,
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, color: AppColors.primary),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Super Administrator',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    child: Text(
                      'ADMIN CONSOLE',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  
                  _DrawerItem(
                    icon: Icons.grid_view_rounded,
                    title: 'Overview',
                    iconColor: const Color(0xFF5B67F4),
                    isSelected: currentRoute == RoutePaths.adminDashboard,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.adminDashboard);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.account_tree_rounded,
                    title: 'Manage Branches',
                    iconColor: const Color(0xFFFF8A34),
                    isSelected: currentRoute.startsWith(RoutePaths.manageBranches),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.manageBranches);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.manage_accounts_rounded,
                    title: 'Users & Roles',
                    iconColor: const Color(0xFF23B07D),
                    isSelected: currentRoute.startsWith(RoutePaths.manageUsers),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.manageUsers);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.school_rounded,
                    title: 'Academics Config',
                    iconColor: const Color(0xFF6C4ED9),
                    isSelected: currentRoute.startsWith(RoutePaths.academicsConfig),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.academicsConfig);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.calendar_month_rounded,
                    title: 'Timetable Setup',
                    iconColor: const Color(0xFF2FA2B9),
                    isSelected: currentRoute.startsWith(RoutePaths.timetable),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.timetable);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.assignment_rounded,
                    title: 'Exams Config',
                    iconColor: const Color(0xFFE85A9A),
                    isSelected: currentRoute.startsWith(RoutePaths.exams),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.exams);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.campaign_rounded,
                    title: 'Notices Board',
                    iconColor: const Color(0xFFFF7A3A),
                    isSelected: currentRoute.startsWith(RoutePaths.notifications),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.notifications);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Enquiries',
                    iconColor: const Color(0xFFFFC857),
                    isSelected: currentRoute.startsWith(RoutePaths.enquiry),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RoutePaths.enquiry);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          Divider(color: isDark ? AppColors.darkBorder : AppColors.border, height: 1),
          
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
              leading: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
              ),
              title: Text(
                'Sign Out',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(authControllerProvider.notifier).logout(() {
                  context.go('/login');
                });
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12.h),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isSelected;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        selected: isSelected,
        selectedTileColor: iconColor.withValues(alpha: 0.12),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
        leading: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: isSelected ? Colors.transparent : iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected 
                ? iconColor 
                : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
