import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/providers/feature_providers.dart';

class AttendanceView extends ConsumerWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final summaryAsync = ref.watch(attendanceSummaryProvider);
    final now = DateTime.now();
    final month = now.month;
    final year = now.year;
    final monthlyAsync = ref.watch(
      monthlyAttendanceProvider((month: month, year: year)),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: summaryAsync.when(
        loading: () => ListView(
          padding: EdgeInsets.all(24.w),
          children: List.generate(4, (_) => Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: AppShimmer.card(),
          )),
        ),
        error: (e, _) => EmptyStateWidget(
          title: 'Failed to load',
          subtitle: e.toString(),
          icon: Icons.error_outline,
        ),
        data: (summary) => SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryGrid(context, summary, isDark),
              SizedBox(height: 32.h),
              
              Text(
                'Recent Classes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),

              monthlyAsync.when(
                loading: () => SizedBox(height: 300.h, child: AppShimmer.card()),
                error: (e, _) => EmptyStateWidget(
                  title: 'Monthly data failed',
                  subtitle: e.toString(),
                  icon: Icons.error_outline,
                ),
                data: (records) {
                  if (records.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'No recent classes',
                      subtitle: 'You have no attendance records for this month.',
                      icon: Icons.history_rounded,
                    );
                  }
                  
                  // Sort records by date descending
                  final sortedRecords = List<AttendanceRecord>.from(records)
                    ..sort((a, b) => b.date.compareTo(a.date));

                  return _RecentClassesList(records: sortedRecords, isDark: isDark);
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(BuildContext context, AttendanceSummary summary, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust for mobile vs tablet/web.
        final bool isWide = constraints.maxWidth > 500;
        
        if (isWide) {
          return Row(
            children: [
              Expanded(child: _StatCard(title: 'PRESENT', value: '${summary.presentDays}', color: const Color(0xFF00BFA5), bgColor: const Color(0xFFEFFFFB), isDark: isDark)),
              SizedBox(width: 12.w),
              Expanded(child: _StatCard(title: 'ABSENT', value: '${summary.absentDays}', color: const Color(0xFFFF5252), bgColor: const Color(0xFFFFF0F2), isDark: isDark)),
              SizedBox(width: 12.w),
              Expanded(child: _StatCard(title: 'LATE', value: '${summary.lateDays}', color: const Color(0xFFFF9800), bgColor: const Color(0xFFFFF8F0), isDark: isDark)),
              SizedBox(width: 12.w),
              Expanded(child: _StatCard(title: 'OVERALL', value: '${summary.percentage.toStringAsFixed(0)}%', color: const Color(0xFF7E57C2), bgColor: const Color(0xFFF4F0FF), isDark: isDark)),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _StatCard(title: 'PRESENT', value: '${summary.presentDays}', color: const Color(0xFF00BFA5), bgColor: const Color(0xFFEFFFFB), isDark: isDark)),
                  SizedBox(width: 12.w),
                  Expanded(child: _StatCard(title: 'ABSENT', value: '${summary.absentDays}', color: const Color(0xFFFF5252), bgColor: const Color(0xFFFFF0F2), isDark: isDark)),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(child: _StatCard(title: 'LATE', value: '${summary.lateDays}', color: const Color(0xFFFF9800), bgColor: const Color(0xFFFFF8F0), isDark: isDark)),
                  SizedBox(width: 12.w),
                  Expanded(child: _StatCard(title: 'OVERALL', value: '${summary.percentage.toStringAsFixed(0)}%', color: const Color(0xFF7E57C2), bgColor: const Color(0xFFF4F0FF), isDark: isDark)),
                ],
              ),
            ],
          );
        }
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final Color bgColor;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.bgColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = isDark ? color.withAlpha(25) : bgColor;
    final effectiveBorder = isDark ? color.withAlpha(50) : color.withAlpha(40);
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: effectiveBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentClassesList extends StatelessWidget {
  final List<AttendanceRecord> records;
  final bool isDark;

  const _RecentClassesList({required this.records, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFF0F0F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: records.length,
        padding: EdgeInsets.zero,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: isDark ? AppColors.darkBorder : const Color(0xFFF6F6F6),
        ),
        itemBuilder: (context, index) {
          final record = records[index];
          return _ClassListItem(record: record, isDark: isDark);
        },
      ),
    );
  }
}

class _ClassListItem extends StatelessWidget {
  final AttendanceRecord record;
  final bool isDark;

  const _ClassListItem({required this.record, required this.isDark});

  String _monthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _weekdayAbbr(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final monthStr = _monthAbbr(record.date.month);
    final dayStr = record.date.day.toString();
    final weekdayStr = _weekdayAbbr(record.date.weekday);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          // Date Column
          SizedBox(
            width: 48.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$monthStr $dayStr',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  weekdayStr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: 16.w),
          
          // Class Name
          Expanded(
            child: Text(
              record.remark ?? 'Abacus Speed Practice',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.textPrimary.withAlpha(200),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          SizedBox(width: 8.w),
          
          // Status Pill
          _StatusPill(status: record.status, isDark: isDark),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final AttendanceStatus status;
  final bool isDark;

  const _StatusPill({required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    String label;
    IconData icon;

    switch (status) {
      case AttendanceStatus.present:
        color = const Color(0xFF00BFA5);
        bgColor = const Color(0xFFEFFFFB);
        label = 'Present';
        icon = Icons.check_rounded;
        break;
      case AttendanceStatus.absent:
        color = const Color(0xFFFF5252);
        bgColor = const Color(0xFFFFF0F2);
        label = 'Absent';
        icon = Icons.close_rounded;
        break;
      case AttendanceStatus.late:
        color = const Color(0xFFFF9800);
        bgColor = const Color(0xFFFFF8F0);
        label = 'Late';
        icon = Icons.access_time_rounded;
        break;
      case AttendanceStatus.holiday:
      case AttendanceStatus.halfDay:
        color = const Color(0xFF7E57C2);
        bgColor = const Color(0xFFF4F0FF);
        label = status == AttendanceStatus.holiday ? 'Holiday' : 'Half Day';
        icon = Icons.event_rounded;
        break;
    }

    final effectiveBg = isDark ? color.withAlpha(25) : bgColor;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
