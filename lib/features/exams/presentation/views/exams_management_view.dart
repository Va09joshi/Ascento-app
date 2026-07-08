import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/exams/data/repositories/exams_repository.dart';
import 'package:ascento_abacus/features/exams/presentation/providers/exams_provider.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/shared/widgets/premium_data_table.dart';

class ExamsManagementView extends ConsumerStatefulWidget {
  const ExamsManagementView({super.key});

  @override
  ConsumerState<ExamsManagementView> createState() => _ExamsManagementViewState();
}

class _ExamsManagementViewState extends ConsumerState<ExamsManagementView> {
  @override
  Widget build(BuildContext context) {
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
              PremiumDataTable<ExamSchedule>(
                title: 'Exams Management',
                subtitle: 'Manage examination schedules, subjects, and dates.',
                isLoading: examsAsync.isLoading,
                data: examsAsync.value ?? [],
                columns: const ['Exam Name', 'Subject', 'Date & Time', 'Room', 'Total Marks', 'Actions'],
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
                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: AppColors.info,
                        onPressed: () => context.push(RoutePaths.editExam, extra: exam),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AppColors.error,
                        onPressed: () => _showDeleteDialog(context, exam),
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
        onPressed: () => context.push(RoutePaths.addExam),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Exam'),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ExamSchedule exam) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Exam'),
        content: Text('Are you sure you want to delete ${exam.examName}? This action cannot be undone.'),
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
                await ref.read(examsRepositoryProvider).deleteExam(exam.id);
                ref.invalidate(examsListProvider);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exam deleted successfully')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete exam'), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
