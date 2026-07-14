import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';

import 'package:ascento_abacus/features/dashboard/presentation/providers/admin_dashboard_provider.dart';

import 'package:ascento_abacus/features/notifications/presentation/providers/notices_provider.dart';
import 'package:ascento_abacus/shared/models/notice_model.dart';

class AdminDashboardView extends ConsumerWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final authState = ref.watch(authControllerProvider);
    final userName = authState.currentUser?.name ?? 'Admin';
    final statsAsync = ref.watch(adminDashboardProvider);
    final noticesAsync = ref.watch(noticesListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              Text(
                'School Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              
              statsAsync.when(
                loading: () => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildShimmerStatCard(isDark)),
                        SizedBox(width: 12.w),
                        Expanded(child: _buildShimmerStatCard(isDark)),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(child: _buildShimmerStatCard(isDark)),
                        SizedBox(width: 12.w),
                        Expanded(child: _buildShimmerStatCard(isDark)),
                      ],
                    ),
                  ],
                ),
                error: (error, stack) => AppCard(
                  child: Center(
                    child: Text('Failed to load stats: $error', style: const TextStyle(color: Colors.red)),
                  ),
                ),
                data: (stats) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Total Students',
                            value: '${stats.totalStudents}',
                            icon: Icons.people_alt_rounded,
                            color: const Color(0xFF5B67F4),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _StatCard(
                            title: 'Total Teachers',
                            value: '${stats.totalTeachers}',
                            icon: Icons.school_rounded,
                            color: const Color(0xFF2FAE78),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Total Branches',
                            value: '${stats.totalBranches}',
                            icon: Icons.account_tree_rounded,
                            color: const Color(0xFFFF8A34),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _StatCard(
                            title: 'Revenue (YTD)',
                            value: stats.revenueYTD,
                            icon: Icons.account_balance_wallet_rounded,
                            color: const Color(0xFF6C4ED9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              Text(
                'Admin Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickAction(
                    label: 'Manage Users',
                    icon: Icons.manage_accounts_rounded,
                    color: const Color(0xFF5B67F4),
                    onTap: () => context.go(RoutePaths.manageUsers),
                  ),
                  _QuickAction(
                    label: 'Timetables',
                    icon: Icons.calendar_month_rounded,
                    color: const Color(0xFF23B07D),
                    onTap: () => context.go(RoutePaths.timetable),
                  ),
                  _QuickAction(
                    label: 'Branches',
                    icon: Icons.account_tree_rounded,
                    color: const Color(0xFFFF8A34),
                    onTap: () => context.go(RoutePaths.manageBranches),
                  ),
                  _QuickAction(
                    label: 'Academics',
                    icon: Icons.school_rounded,
                    color: const Color(0xFF6C4ED9),
                    onTap: () => context.go(RoutePaths.academicsConfig),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              Text(
                'Recent Activity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              
              noticesAsync.when(
                loading: () => Column(
                  children: List.generate(2, (index) => _buildShimmerActivityCard(isDark)),
                ),
                error: (error, stack) => AppCard(
                  child: Center(
                    child: Text('Failed to load activity', style: TextStyle(color: AppColors.error)),
                  ),
                ),
                data: (notices) {
                  if (notices.isEmpty) {
                    return AppCard(
                      child: Center(
                        child: Text('No recent activity', style: TextStyle(color: AppColors.textMuted)),
                      ),
                    );
                  }
                  
                  // Show top 3 recent notices
                  final recentNotices = notices.take(3).toList();
                  
                  return SizedBox(
                    height: 240.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentNotices.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 16.w),
                          child: SizedBox(
                            width: 200.w,
                            child: _buildRecentNoticePosterCard(recentNotices[index], theme, isDark),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final bool isDark;
  final String userName;
  final String subtitle;

  const _HeaderCard({
    required this.isDark,
    required this.userName,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: (isDark ? AppColors.darkPrimary : AppColors.primary)
                    .withValues(alpha: 0.12),
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  size: 28,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Administrator',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      userName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                    .withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: isDark ? AppColors.info : const Color(0xFF23B07D),
                  size: 18,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.18),
                  color.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

Widget _buildShimmerStatCard(bool isDark) {
  return Shimmer.fromColors(
    baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
    highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
    child: Container(
      height: 110.h,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
    ),
  );
}

Widget _buildShimmerActivityCard(bool isDark) {
  return Shimmer.fromColors(
    baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
    highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
    child: Container(
      height: 72.h,
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
    ),
  );
}

Widget _buildRecentNoticePosterCard(NoticeModel notice, ThemeData theme, bool isDark) {
  Color typeColor;
  IconData iconData;
  
  switch (notice.type.toLowerCase()) {
    case 'general': typeColor = Colors.blue; iconData = Icons.notifications_rounded; break;
    case 'academic': typeColor = Colors.green; iconData = Icons.school_rounded; break;
    case 'fees': typeColor = Colors.orange; iconData = Icons.attach_money_rounded; break;
    case 'event': typeColor = Colors.purple; iconData = Icons.event_rounded; break;
    case 'update': typeColor = Colors.teal; iconData = Icons.update_rounded; break;
    case 'alert': typeColor = Colors.red; iconData = Icons.warning_rounded; break;
    default: typeColor = AppColors.primary; iconData = Icons.campaign_rounded;
  }

  return Container(
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Banner
        Expanded(
          flex: 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (notice.bannerUrl != null && notice.bannerUrl!.isNotEmpty)
                Image.network(notice.bannerUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildActivityPlaceholder(typeColor, iconData))
              else
                _buildActivityPlaceholder(typeColor, iconData),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                  ),
                ),
              ),
              Positioned(
                bottom: 8.h,
                left: 12.w,
                child: Text(
                  notice.type.toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notice.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Expanded(
                  child: Text(
                    notice.content,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildActivityPlaceholder(Color color, IconData icon) {
  return Container(
    color: color.withValues(alpha: 0.2),
    child: Center(child: Icon(icon, size: 48.sp, color: color)),
  );
}
