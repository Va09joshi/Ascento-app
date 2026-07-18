import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ascento_abacus/shared/providers/feature_providers.dart';

class TeacherDashboardView extends ConsumerWidget {
  const TeacherDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final authState = ref.watch(authControllerProvider);
    final userName = authState.currentUser?.name ?? 'Teacher';

    final statsAsync = ref.watch(teacherDashboardStatsProvider);

    if (statsAsync.isLoading && !statsAsync.hasValue) {
      return _buildShimmerSkeleton(context, isDark, theme, userName);
    }

    final stats = statsAsync.asData?.value;
    final totalStudents = stats?.totalStudents ?? 0;
    final pendingHomework = stats?.pendingHomework ?? 0;
    final upcomingMeetings = stats?.upcomingMeetings ?? 0;
    final unreadNotices = stats?.unreadNotices ?? 0;
    final upcomingClasses = stats?.upcomingClasses ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(teacherDashboardStatsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderCard(
                  isDark: isDark,
                  userName: userName,
                  subtitle: '${upcomingClasses.length} classes are scheduled for today.',
                ),
                SizedBox(height: 24.h),

                Text(
                  'My Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Students',
                        value: totalStudents.toString(),
                        icon: Icons.people_alt_rounded,
                        color: const Color(0xFF5B67F4),
                        isDark: isDark,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: _StatCard(
                        title: 'Pending Grades',
                        value: pendingHomework.toString(),
                        icon: Icons.assignment_rounded,
                        color: const Color(0xFFE85A9A),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Live Meetings',
                        value: upcomingMeetings.toString(),
                        icon: Icons.video_camera_front_rounded,
                        color: const Color(0xFFFF8A34),
                        isDark: isDark,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: _StatCard(
                        title: 'Unread Notices',
                        value: unreadNotices.toString(),
                        icon: Icons.campaign_rounded,
                        color: const Color(0xFF2FAE78),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28.h),

                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _QuickAction(
                      label: 'Attendance',
                      icon: Icons.how_to_reg_rounded,
                      color: const Color(0xFF23B07D),
                      onTap: () => context.push(RoutePaths.attendance),
                    ),
                    _QuickAction(
                      label: 'Timetable',
                      icon: Icons.calendar_month_rounded,
                      color: const Color(0xFF5B67F4),
                      onTap: () => context.push(RoutePaths.timetable),
                    ),
                    _QuickAction(
                      label: 'My Students',
                      icon: Icons.groups_rounded,
                      color: const Color(0xFFE85A9A),
                      onTap: () => context.push(RoutePaths.teacherStudents),
                    ),
                    _QuickAction(
                      label: 'Assignments',
                      icon: Icons.assignment_turned_in_rounded,
                      color: const Color(0xFFFF7A3A),
                      onTap: () => context.push(RoutePaths.homework),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                Text(
                  'Upcoming Classes Today',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 16.h),
                
                if (upcomingClasses.isEmpty)
                  _buildEmptyState(context, isDark)
                else
                  ...upcomingClasses.map((c) => _buildClassCard(context, c, isDark)),
                  
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, dynamic c, bool isDark) {
    final theme = Theme.of(context);
    final subject = c.subject.isNotEmpty ? c.subject : 'General Subject';
    final room = c.room.isNotEmpty ? c.room : 'N/A';
    
    // Parse time to format (e.g. "09:00 AM")
    String timeStr = c.startTime;
    try {
      final parsed = DateFormat('HH:mm:ss').parse(c.startTime);
      timeStr = DateFormat('hh:mm a').format(parsed);
    } catch (_) {}

    return AppCard(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.zero,
      // elevation: isDark ? 2 : 4,
      borderRadius: 16.r,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          width: 55.w,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5B67F4), Color(0xFF7A84F8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.schedule_rounded, color: Colors.white, size: 18.sp),
              SizedBox(height: 4.h),
              Text(
                timeStr.replaceAll(' ', '\n'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          subject,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Row(
            children: [
              Icon(Icons.meeting_room_rounded, size: 14, color: AppColors.textMuted),
              SizedBox(width: 4.w),
              Text(
                'Room $room',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        onTap: () {
          // Open details or navigate to attendance
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.primary).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.weekend_rounded,
              size: 40.sp,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No upcoming classes today',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You have a free schedule for the rest of the day. Enjoy your time!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSkeleton(BuildContext context, bool isDark, ThemeData theme, String userName) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(
                isDark: isDark,
                userName: userName,
                subtitle: 'Loading your dashboard...',
              ),
              SizedBox(height: 24.h),
              Text('My Overview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppShimmer(width: 44.w, height: 44.w, borderRadius: 14.r),
                          SizedBox(height: 16.h),
                          AppShimmer(width: 80.w, height: 12.h),
                          SizedBox(height: 8.h),
                          AppShimmer(width: 40.w, height: 20.h),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: AppCard(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppShimmer(width: 44.w, height: 44.w, borderRadius: 14.r),
                          SizedBox(height: 16.h),
                          AppShimmer(width: 80.w, height: 12.h),
                          SizedBox(height: 8.h),
                          AppShimmer(width: 40.w, height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        gradient: isDark 
          ? const LinearGradient(
              colors: [Color(0xFF2A2D3E), Color(0xFF1F212E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : const LinearGradient(
              colors: [Color(0xFF5B67F4), Color(0xFF3442E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF5B67F4)).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                ),
                child: CircleAvatar(
                  radius: 26.r,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'T',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      userName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 18,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
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
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: color.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              letterSpacing: -0.5,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: color, size: 28),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
