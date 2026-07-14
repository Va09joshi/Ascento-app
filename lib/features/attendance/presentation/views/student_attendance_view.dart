import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/features/dashboard/presentation/widgets/student_drawer.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/widgets/premium_data_table.dart';

import 'package:ascento_abacus/shared/providers/feature_providers.dart';

class StudentAttendanceView extends ConsumerWidget {
  const StudentAttendanceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final attendanceAsync = ref.watch(monthlyAttendanceProvider((month: now.month, year: now.year)));
    final summaryAsync = ref.watch(attendanceSummaryProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Attendance Record',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'View your daily attendance.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
              SizedBox(height: 24.h),
              
              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context, 
                      'Total Classes', 
                      summaryAsync.valueOrNull?.totalDays.toString() ?? '-', 
                      Icons.class_rounded, 
                      Colors.blue, 
                      isDark,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      context, 
                      'Present', 
                      summaryAsync.valueOrNull?.presentDays.toString() ?? '-', 
                      Icons.check_circle_rounded, 
                      AppColors.success, 
                      isDark,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      context, 
                      'Absent', 
                      summaryAsync.valueOrNull?.absentDays.toString() ?? '-', 
                      Icons.cancel_rounded, 
                      AppColors.error, 
                      isDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              PremiumDataTable<AttendanceRecord>(
                title: 'Recent Records',
                subtitle: 'Your recent attendance history.',
                isLoading: attendanceAsync.isLoading,
                columns: const ['Date', 'Status', 'Remarks'],
                data: attendanceAsync.valueOrNull ?? [],
                rowBuilder: (record) => [
                  Text(_formatDate(record.date), style: theme.textTheme.bodyMedium),
                  _buildStatusBadge(record.status, theme),
                  Text(record.remark ?? '-', style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 24.r),
          ),
          SizedBox(height: 16.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildStatusBadge(AttendanceStatus status, ThemeData theme) {
    Color color;
    String label;

    switch (status) {
      case AttendanceStatus.present:
        color = AppColors.success;
        label = 'Present';
        break;
      case AttendanceStatus.absent:
        color = AppColors.error;
        label = 'Absent';
        break;
      case AttendanceStatus.late:
        color = AppColors.warning;
        label = 'Late';
        break;
      case AttendanceStatus.holiday:
        color = Colors.blue;
        label = 'Holiday';
        break;
      case AttendanceStatus.halfDay:
        color = Colors.orange;
        label = 'Half Day';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
