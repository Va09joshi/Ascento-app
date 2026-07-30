import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/features/dashboard/presentation/widgets/student_drawer.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/widgets/premium_data_table.dart';

import 'package:ascento_abacus/shared/providers/feature_providers.dart';

class StudentAttendanceView extends ConsumerStatefulWidget {
  const StudentAttendanceView({super.key});

  @override
  ConsumerState<StudentAttendanceView> createState() => _StudentAttendanceViewState();
}

class _StudentAttendanceViewState extends ConsumerState<StudentAttendanceView> {
  DateTime _currentDate = DateTime.now();

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final attendanceAsync = ref.watch(monthlyAttendanceProvider((month: _currentDate.month, year: _currentDate.year)));
    final summaryAsync = ref.watch(attendanceSummaryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
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
              
              // Today's Status Banner (Only show for current month)
              if (_currentDate.month == now.month && _currentDate.year == now.year && attendanceAsync.valueOrNull != null)
                Builder(builder: (context) {
                  final today = DateTime(now.year, now.month, now.day);
                  final todayRecord = attendanceAsync.valueOrNull!.cast<AttendanceRecord?>().firstWhere(
                    (record) => record != null && record.date.year == today.year && record.date.month == today.month && record.date.day == today.day,
                    orElse: () => null,
                  );

                  if (todayRecord == null) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 24.h),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.blue, size: 28.r),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Attendance Not Marked Yet', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16.sp)),
                                Text('Your teacher has not marked attendance for today.', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13.sp)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final isPresent = todayRecord.status == AttendanceStatus.present;
                  final color = isPresent ? AppColors.success : AppColors.error;
                  final icon = isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded;
                  final title = isPresent ? 'You are Present Today!' : 'You are Absent Today';

                  return Container(
                    margin: EdgeInsets.only(bottom: 24.h),
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: color, size: 32.r),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18.sp)),
                              SizedBox(height: 2.h),
                              Text('Recorded on ${_formatDate(todayRecord.date)}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13.sp)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    icon: Icon(Icons.chevron_left, color: isDark ? Colors.white : Colors.black),
                    style: IconButton.styleFrom(backgroundColor: isDark ? AppColors.darkSurface : Colors.white),
                  ),
                  Text(
                    '${_getMonthName(_currentDate.month)} ${_currentDate.year}',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: Icon(Icons.chevron_right, color: isDark ? Colors.white : Colors.black),
                    style: IconButton.styleFrom(backgroundColor: isDark ? AppColors.darkSurface : Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              if (attendanceAsync.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                _buildCalendarView(context, attendanceAsync.valueOrNull ?? [], isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, List<AttendanceRecord> records, bool isDark) {
    final daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    
    // Map records by day for easy lookup
    final Map<int, AttendanceRecord> recordMap = {};
    for (var record in records) {
      recordMap[record.date.day] = record;
    }

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Overview',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              _buildLegendRow(isDark),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: daysInMonth + firstWeekday - 1,
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) {
                return const SizedBox.shrink(); // Empty slot before the 1st
              }
              final day = index - firstWeekday + 2;
              final record = recordMap[day];
              
              Color bgColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100;
              Color textColor = isDark ? Colors.white70 : Colors.black87;
              
              if (record != null) {
                switch (record.status) {
                  case AttendanceStatus.present:
                    bgColor = AppColors.success.withValues(alpha: 0.2);
                    textColor = AppColors.success;
                    break;
                  case AttendanceStatus.absent:
                    bgColor = AppColors.error.withValues(alpha: 0.2);
                    textColor = AppColors.error;
                    break;
                  case AttendanceStatus.late:
                    bgColor = AppColors.warning.withValues(alpha: 0.2);
                    textColor = AppColors.warning;
                    break;
                  case AttendanceStatus.halfDay:
                    bgColor = Colors.orange.withValues(alpha: 0.2);
                    textColor = Colors.orange;
                    break;
                  case AttendanceStatus.holiday:
                    bgColor = Colors.blue.withValues(alpha: 0.2);
                    textColor = Colors.blue;
                    break;
                }
              }

              // Highlight today if in current month
              final now = DateTime.now();
              final isToday = now.year == _currentDate.year && now.month == _currentDate.month && now.day == day;
              
              if (isToday && record == null) {
                bgColor = AppColors.primary.withValues(alpha: 0.2);
                textColor = AppColors.primary;
              }

              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isToday || record != null ? FontWeight.bold : FontWeight.normal,
                      color: textColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(bool isDark) {
    return Row(
      children: [
        _buildLegendDot(AppColors.success, 'P', isDark),
        SizedBox(width: 8.w),
        _buildLegendDot(AppColors.error, 'A', isDark),
      ],
    );
  }
  
  Widget _buildLegendDot(Color color, String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.white70 : Colors.black54),
        ),
      ],
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

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}
