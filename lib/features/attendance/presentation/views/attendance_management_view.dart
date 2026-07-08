import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/shared/widgets/premium_data_table.dart';

// Mock Provider for UI demonstration until API is connected
final mockAttendanceProvider = FutureProvider.autoDispose<List<AttendanceRecord>>((ref) async {
  await Future.delayed(const Duration(seconds: 1));
  return [
    AttendanceRecord(
      id: '1', date: DateTime.now(), status: AttendanceStatus.present, remark: 'On time'
    ),
    AttendanceRecord(
      id: '2', date: DateTime.now().subtract(const Duration(days: 1)), status: AttendanceStatus.absent, remark: 'Sick leave'
    ),
  ];
});

class AttendanceManagementView extends ConsumerWidget {
  const AttendanceManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final attendanceAsync = ref.watch(mockAttendanceProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PremiumDataTable<AttendanceRecord>(
                title: 'Attendance Management',
                subtitle: 'Mark and review daily attendance records.',
                isLoading: attendanceAsync.isLoading,
                data: attendanceAsync.value ?? [],
                columns: const ['Record ID', 'Date', 'Status', 'Remarks', 'Actions'],
                rowBuilder: (record) => [
                  // ID
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: _getStatusColor(record.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.co_present_rounded, color: _getStatusColor(record.status), size: 16.sp),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '#${record.id.padLeft(4, '0')}',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                      ),
                    ],
                  ),
                  // Date
                  Text(record.date.toIso8601String().split('T')[0]),
                  // Status
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(record.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      record.status.name.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(record.status),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Remarks
                  Text(record.remark ?? 'N/A'),
                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: AppColors.info,
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AppColors.error,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add Attendance
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Mark Attendance'),
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present: return AppColors.success;
      case AttendanceStatus.absent: return AppColors.error;
      case AttendanceStatus.late: return AppColors.warning;
      case AttendanceStatus.holiday: return AppColors.info;
      case AttendanceStatus.halfDay: return AppColors.secondary;
      default: return AppColors.textPrimary;
    }
  }
}
