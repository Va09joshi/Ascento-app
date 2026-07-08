import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';
import 'package:ascento_abacus/features/academics/data/repositories/academics_repository.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/shared/models/academic_year_model.dart';
import 'package:ascento_abacus/shared/widgets/premium_data_table.dart';

class AcademicYearsTab extends ConsumerWidget {
  const AcademicYearsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearsAsync = ref.watch(academicYearsListProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: PremiumDataTable<AcademicYearModel>(
        title: 'Academic Years',
        subtitle: 'Manage school academic sessions and term dates.',
        isLoading: yearsAsync.isLoading,
        error: yearsAsync.hasError ? yearsAsync.error.toString() : null,
        data: yearsAsync.value ?? [],
        columns: const ['Session Name', 'Start Date', 'End Date', 'Status', 'Actions'],
        rowBuilder: (year) => [
          // Name
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 16.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                year.name,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
              ),
            ],
          ),
          // Start Date
          Text(year.startDate.split('T')[0]),
          // End Date
          Text(year.endDate.split('T')[0]),
          // Status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: year.isCurrent ? AppColors.success.withValues(alpha: 0.1) : AppColors.textMuted.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              year.isCurrent ? 'CURRENT' : 'PAST',
              style: TextStyle(
                color: year.isCurrent ? AppColors.success : AppColors.textSecondary,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.info,
                onPressed: () => context.push(RoutePaths.editAcademicYear, extra: year),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.error,
                onPressed: () => _showDeleteDialog(context, ref, year),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, AcademicYearModel year) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Academic Year'),
        content: Text('Are you sure you want to delete the academic year ${year.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(academicsRepositoryProvider).deleteAcademicYear(year.id);
                ref.invalidate(academicYearsListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Academic Year deleted successfully')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete academic year'), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
