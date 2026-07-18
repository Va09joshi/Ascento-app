import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/shared/providers/feature_providers.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:go_router/go_router.dart';

class TeacherStudentsView extends ConsumerStatefulWidget {
  const TeacherStudentsView({super.key});

  @override
  ConsumerState<TeacherStudentsView> createState() => _TeacherStudentsViewState();
}

class _TeacherStudentsViewState extends ConsumerState<TeacherStudentsView> {
  final Map<String, bool> _expandedSections = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final asyncData = ref.watch(teacherStudentsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Students',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: asyncData.when(
          data: (sections) {
            if (sections.isEmpty) return _buildEmptyState(theme, isDark);
            
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(teacherStudentsProvider),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return _buildSectionAccordion(section, theme, isDark);
                },
              ),
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error, theme),
        ),
      ),
    );
  }

  Widget _buildSectionAccordion(SectionStudentsModel section, ThemeData theme, bool isDark) {
    final isExpanded = _expandedSections[section.sectionId] ?? false;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () {
              setState(() {
                _expandedSections[section.sectionId] = !isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        section.sectionName.isNotEmpty ? section.sectionName[0] : 'S',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${section.className ?? 'Class'} - ${section.sectionName}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${section.students.length} Students',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
              ),
              child: section.students.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Center(
                        child: Text(
                          'No students assigned to this section yet.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: section.students.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                      itemBuilder: (context, idx) {
                        final student = section.students[idx];
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          leading: CircleAvatar(
                            radius: 20.r,
                            backgroundColor: (isDark ? AppColors.darkPrimary : AppColors.primary).withValues(alpha: 0.1),
                            backgroundImage: student.avatarUrl != null ? NetworkImage(student.avatarUrl!) : null,
                            child: student.avatarUrl == null
                                ? Text(
                                    student.fullName[0].toUpperCase(),
                                    style: TextStyle(
                                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            student.fullName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            student.rollNumber != null ? 'Roll: ${student.rollNumber}' : 'No Roll No.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.info_outline_rounded, color: AppColors.textMuted, size: 20),
                            onPressed: () {
                              // Optional: View student details
                            },
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.group_off_rounded, size: 48, color: AppColors.primary),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Students Assigned',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You have not been assigned to any sections.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: 4,
      itemBuilder: (context, index) {
        return AppShimmer(
          width: double.infinity,
          height: 80.h,
          borderRadius: 16.r,
          margin: EdgeInsets.only(bottom: 16.h),
        );
      },
    );
  }

  Widget _buildErrorState(Object error, ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
            SizedBox(height: 16.h),
            Text(
              'Failed to load students',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => ref.invalidate(teacherStudentsProvider),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
