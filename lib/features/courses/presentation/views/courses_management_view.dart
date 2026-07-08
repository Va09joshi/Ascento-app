import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/shared/widgets/premium_data_table.dart';

// Mock Course Model for UI
class CourseModel {
  final String id;
  final String name;
  final String description;
  final int durationWeeks;
  final double price;
  final String status;

  CourseModel({
    required this.id, required this.name, required this.description,
    required this.durationWeeks, required this.price, required this.status,
  });
}

final mockCoursesProvider = FutureProvider.autoDispose<List<CourseModel>>((ref) async {
  await Future.delayed(const Duration(seconds: 1));
  return [
    CourseModel(
      id: '1', name: 'Vedic Maths Basics', description: 'Introduction to Mental Math',
      durationWeeks: 4, price: 99.99, status: 'Active'
    ),
    CourseModel(
      id: '2', name: 'Advanced Abacus', description: 'Level 3-5 Abacus Techniques',
      durationWeeks: 12, price: 199.99, status: 'Active'
    ),
  ];
});

class CoursesManagementView extends ConsumerWidget {
  const CoursesManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final coursesAsync = ref.watch(mockCoursesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PremiumDataTable<CourseModel>(
                title: 'Courses & Programs',
                subtitle: 'Manage specialized programs like Vedic Maths and Abacus.',
                isLoading: coursesAsync.isLoading,
                data: coursesAsync.value ?? [],
                columns: const ['Course Name', 'Duration', 'Price', 'Status', 'Actions'],
                rowBuilder: (course) => [
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
                        child: Icon(Icons.school_rounded, color: AppColors.primary, size: 16.sp),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            course.name,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                          ),
                          Text(
                            course.description,
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Duration
                  Text('${course.durationWeeks} Weeks'),
                  // Price
                  Text('\$${course.price.toStringAsFixed(2)}'),
                  // Status
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      course.status.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.success,
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
          // TODO: Add Course
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Course'),
      ),
    );
  }
}
