import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/exams/data/repositories/exams_repository.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/shared/widgets/premium_data_table.dart';

// Note: Requires an examResultsProvider in exams_provider.dart
// For now we will mock the provider to demonstrate the UI
final mockExamResultsProvider = FutureProvider.autoDispose<List<ReportCard>>((ref) async {
  await Future.delayed(const Duration(seconds: 1));
  return [
    ReportCard(
      examName: 'Mid-Term 2024',
      results: [],
      overallPercentage: 85.5,
      overallGrade: 'A',
      gpa: 3.8,
    ),
    ReportCard(
      examName: 'Final 2024',
      results: [],
      overallPercentage: 92.0,
      overallGrade: 'A+',
      gpa: 4.0,
    ),
  ];
});

class ExamResultsManagementView extends ConsumerWidget {
  const ExamResultsManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final resultsAsync = ref.watch(mockExamResultsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PremiumDataTable<ReportCard>(
                title: 'Exam Results Management',
                subtitle: 'Manage and publish student report cards.',
                isLoading: resultsAsync.isLoading,
                data: resultsAsync.value ?? [],
                columns: const ['Exam Name', 'GPA', 'Percentage', 'Overall Grade', 'Actions'],
                rowBuilder: (report) => [
                  // Exam Name
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 16.sp),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        report.examName,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                      ),
                    ],
                  ),
                  // GPA
                  Text(report.gpa.toStringAsFixed(2)),
                  // Percentage
                  Text('${report.overallPercentage.toStringAsFixed(1)}%'),
                  // Grade
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      report.overallGrade,
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12.sp,
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
                        onPressed: () {
                          // TODO
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AppColors.error,
                        onPressed: () {
                          // TODO
                        },
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
          // TODO: Add result
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Result'),
      ),
    );
  }
}
