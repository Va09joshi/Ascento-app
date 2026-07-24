import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/features/users/presentation/providers/teachers_provider.dart';

class TeacherStudentsView extends ConsumerWidget {
  const TeacherStudentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final myStudentsAsync = ref.watch(myStudentsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Students',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'View students in your assigned classes.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: myStudentsAsync.when(
                loading: () => ListView(
                  padding: EdgeInsets.all(24.w),
                  children: List.generate(3, (_) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: AppShimmer(width: double.infinity, height: 200.h, borderRadius: 12.r),
                  )),
                ),
                error: (e, _) => EmptyStateWidget(
                  title: 'Load failed',
                  subtitle: e.toString(),
                  icon: Icons.error_outline,
                ),
                data: (sections) {
                  if (sections.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'No Assigned Classes',
                      subtitle: 'You do not have any active classes assigned to you.',
                      icon: Icons.school_outlined,
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 100.h),
                    itemCount: sections.length,
                    separatorBuilder: (_, __) => SizedBox(height: 24.h),
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      final students = section['students'] as List? ?? [];
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.surface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withOpacity(0.2) : AppColors.shadow.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                                border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.class_, color: AppColors.primary, size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '${section['class_name'] ?? 'Unknown Class'} - ${section['section_name'] ?? 'Section'}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      '${students.length} Students',
                                      style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (students.isEmpty)
                              Padding(
                                padding: EdgeInsets.all(24.w),
                                child: Center(
                                  child: Text('No students enrolled in this section.', style: TextStyle(color: AppColors.textMuted)),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: students.length,
                                separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.border),
                                itemBuilder: (context, sIndex) {
                                  final student = students[sIndex];
                                  return ListTile(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                    leading: CircleAvatar(
                                      backgroundColor: isDark ? AppColors.darkBorder : AppColors.border,
                                      backgroundImage: student['avatar_url'] != null ? NetworkImage(student['avatar_url']) : null,
                                      child: student['avatar_url'] == null ? Icon(Icons.person, color: AppColors.textMuted) : null,
                                    ),
                                    title: Text(
                                      student['full_name'] ?? 'Unknown',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary),
                                    ),
                                    subtitle: Text(
                                      'Roll No: ${student['roll_number'] ?? 'N/A'}\n${student['email'] ?? 'No email'}',
                                      style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted, fontSize: 12.sp),
                                    ),
                                    isThreeLine: true,
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
