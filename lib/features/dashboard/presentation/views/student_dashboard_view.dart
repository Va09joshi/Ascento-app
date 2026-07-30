import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ascento_abacus/shared/providers/feature_providers.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/meetings/presentation/providers/meetings_provider.dart';
import 'package:ascento_abacus/features/content/presentation/providers/content_provider.dart';
import 'package:url_launcher/url_launcher.dart';

final hasShownNoticePopupProvider = StateProvider<bool>((ref) => false);

class StudentDashboardView extends ConsumerWidget {
  const StudentDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authControllerProvider).currentUser;

    // Fetch live stats
    final notifAsync = ref.watch(notificationsProvider);
    final attendanceAsync = ref.watch(attendanceSummaryProvider);
    final examsAsync = ref.watch(examScheduleProvider);
    final feesAsync = ref.watch(feeHistoryProvider);
    final homeworkAsync = ref.watch(homeworkListProvider(null));

    // Calculate values safely
    final attendancePct = attendanceAsync.valueOrNull?.percentage ?? 0.0;
    
    // Count only upcoming exams (future dates)
    final now = DateTime.now();
    final upcomingExamsCount = examsAsync.valueOrNull?.where((e) => e.date.isAfter(now)).length ?? 0;
    
    // Sum pending/overdue fees
    final pendingFees = feesAsync.valueOrNull?.where((f) => f.balanceDue > 0).fold<double>(0, (sum, f) => sum + f.balanceDue) ?? 0.0;
    
    // Count pending homeworks
    final pendingHomeworkCount = homeworkAsync.valueOrNull?.where((h) => h.status == HomeworkStatus.pending).length ?? 0;
    final profileAsync = ref.watch(studentProfileProvider);
    final profile = profileAsync.valueOrNull;

    ref.listen(notificationsProvider, (previous, next) {
      if (next.hasValue && next.value != null && next.value!.isNotEmpty) {
        if (!ref.read(hasShownNoticePopupProvider)) {
          Future.microtask(() {
            if (context.mounted && !ref.read(hasShownNoticePopupProvider)) {
              ref.read(hasShownNoticePopupProvider.notifier).state = true;
              _showNoticePopup(context, next.value!.first, isDark);
            }
          });
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header Card
              _buildUserHeader(context, user, profile, isDark),
              SizedBox(height: 32.h),

              // Overview Section
              Text(
                'Overview',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.calendar_month_rounded,
                      iconColor: const Color(0xFF2FAE78),
                      iconBgColor: const Color(0xFFE8F6EF),
                      title: 'Attendance',
                      value: '${attendancePct.toStringAsFixed(0)}%',
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildOverviewCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.assignment_turned_in_rounded,
                      iconColor: const Color(0xFFFF7A59),
                      iconBgColor: const Color(0xFFFFF0EC),
                      title: 'Upcoming Exams',
                      value: '$upcomingExamsCount',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      iconBgColor: const Color(0xFFF3EDFF),
                      title: 'Pending Fees',
                      value: 'Rs ${pendingFees.toStringAsFixed(0)}',
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildOverviewCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.menu_book_rounded,
                      iconColor: const Color(0xFFE85A9A),
                      iconBgColor: const Color(0xFFFDEDF5),
                      title: 'Homework',
                      value: '$pendingHomeworkCount pending',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Quick Actions Section
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              
              Row(
                children: [
                  _buildQuickActionCard(
                    context: context,
                    icon: Icons.schedule_rounded,
                    color: const Color(0xFF6366F1), // Indigo
                    label: 'Timetable',
                    onTap: () => context.go(RoutePaths.timetable),
                  ),
                  SizedBox(width: 12.w),
                  _buildQuickActionCard(
                    context: context,
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFFF97316), // Orange
                    label: 'Homework',
                    onTap: () => context.go(RoutePaths.homework),
                  ),
                  SizedBox(width: 12.w),
                  _buildQuickActionCard(
                    context: context,
                    icon: Icons.person_rounded,
                    color: const Color(0xFF10B981), // Emerald
                    label: 'Profile',
                    onTap: () => context.go(RoutePaths.profile),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Learning Hub Section
              Text(
                'Learning Hub',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              
              // Up Next (Live Meetings)
              _buildSectionHeader(context, 'Up Next', 'Live sessions starting soon', isDark),
              SizedBox(height: 12.h),
              Builder(builder: (context) {
                final allMeetings = ref.watch(meetingsListProvider).valueOrNull ?? [];
                // Only show meetings for all students or specifically for this class/section
                final myMeetings = allMeetings.where((m) {
                  if (m.classId == null) return true; // All students
                  if (m.classId != profile?.classId) return false;
                  // If class matches, check section if specified
                  if (m.sectionId != null && m.sectionId != profile?.sectionId) return false;
                  return true;
                }).toList();
                
                if (myMeetings.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Center(
                      child: Text('No upcoming meetings scheduled.', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  );
                }
                return _buildMeetingCard(context, myMeetings.first, isDark);
              }),
              
              SizedBox(height: 24.h),
              
              // In Progress (Study Materials)
              _buildSectionHeader(context, 'Recent Study Material', 'Pick up where you left off', isDark),
              SizedBox(height: 12.h),
              Builder(builder: (context) {
                final allContent = ref.watch(contentListProvider).valueOrNull ?? [];
                
                if (allContent.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Center(
                      child: Text('No recent study material available.', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  );
                }
                return _buildStudyMaterialCard(context, allContent.first, isDark);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String subtitle, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text('View All', style: TextStyle(color: AppColors.primary, fontSize: 12.sp, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildMeetingCard(BuildContext context, MeetingItem item, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.video_camera_front_rounded, color: AppColors.error, size: 24.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                SizedBox(height: 4.h),
                Text('${item.meetDate.day}/${item.meetDate.month}/${item.meetDate.year} • ${item.startTime} - ${item.endTime}', style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp)),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: () {
              final uri = Uri.tryParse(item.meetLink);
              if (uri != null) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyMaterialCard(BuildContext context, ContentItem item, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              item.type.toLowerCase() == 'pdf' ? Icons.picture_as_pdf_rounded :
              item.type.toLowerCase() == 'video' ? Icons.play_arrow_rounded : Icons.image_rounded,
              color: AppColors.primary, size: 24.r
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                SizedBox(height: 4.h),
                Text('${item.type.toUpperCase()} • Added recently', style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp)),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          IconButton(
            onPressed: () => context.go(RoutePaths.content),
            icon: Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 20.r),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, dynamic user, StudentProfile? profile, bool isDark) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          user.avatarUrl!,
                          fit: BoxFit.cover,
                          width: 60.w,
                          height: 60.h,
                          errorBuilder: (_, __, ___) => Text(
                            user.name.isNotEmpty == true ? user.name[0].toUpperCase() : 'V',
                            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                          ),
                        ),
                      )
                    : Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'V',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      user?.name ?? 'Vaibhav Joshi',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      profile != null && (profile.className.isNotEmpty || profile.rollNumber.isNotEmpty)
                          ? [
                              if (profile.className.isNotEmpty) '${profile.className}${profile.section.isNotEmpty ? ' - ${profile.section}' : ''}',
                              if (profile.rollNumber.isNotEmpty) 'Roll No. ${profile.rollNumber}',
                            ].join(' | ')
                          : 'Not Assigned to Class',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 20),
                SizedBox(width: 8.w),
                Text(
                  'You ranked 3rd in class this month!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: isDark ? iconColor.withOpacity(0.15) : iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: isDark ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(height: 10.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showNoticePopup(BuildContext context, NotificationItem notice, bool isDark) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.campaign_rounded, color: AppColors.primary, size: 24.r),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Latest Notice',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, size: 24.r, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              
              // Notice Content
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black12 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: isDark ? AppColors.darkBorder : Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (notice.imageUrl != null && notice.imageUrl!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.network(
                          notice.imageUrl!,
                          width: double.infinity,
                          height: 140.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                    Text(
                      notice.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      notice.body,
                      maxLines: notice.imageUrl != null && notice.imageUrl!.isNotEmpty ? 3 : 5,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.white70 : Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push(RoutePaths.noticeDetails, extra: notice);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Read Full Notice',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
