import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/exams/presentation/providers/exams_provider.dart';
import 'package:ascento_abacus/shared/widgets/premium_data_table.dart';
import 'package:ascento_abacus/features/dashboard/presentation/widgets/student_drawer.dart';

class StudentExamsView extends ConsumerWidget {
  const StudentExamsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final examsAsync = ref.watch(examsListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Upcoming Exams',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'View your upcoming exam schedules.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
              SizedBox(height: 24.h),
              
              PremiumDataTable<ExamSchedule>(
                title: 'Schedule',
                subtitle: 'Your scheduled exams and tests.',
                isLoading: examsAsync.isLoading,
                data: examsAsync.value ?? [],
                columns: const ['Exam Name', 'Subject', 'Date & Time', 'Room', 'Total Marks'],
                rowBuilder: (exam) => [
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
                        child: Icon(Icons.assignment_rounded, color: AppColors.primary, size: 16.sp),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        exam.examName,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                      ),
                    ],
                  ),
                  // Subject
                  Text(exam.subject),
                  // Date & Time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        exam.date.toIso8601String().split('T')[0],
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp),
                      ),
                      Text(
                        exam.time,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
                      ),
                    ],
                  ),
                  // Room
                  Text(exam.room),
                  // Marks
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '${exam.totalMarks}M',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
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
