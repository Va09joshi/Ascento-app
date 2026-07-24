import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/features/users/presentation/providers/teachers_provider.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/shared/widgets/premium_data_table.dart';

class TeachersManagementView extends ConsumerStatefulWidget {
  const TeachersManagementView({super.key});

  @override
  ConsumerState<TeachersManagementView> createState() => _TeachersManagementViewState();
}

class _TeachersManagementViewState extends ConsumerState<TeachersManagementView> {
  void _showAddTeacherSheet(BuildContext context) {
    context.push(RoutePaths.addUser, extra: 'teacher');
  }

  void _deactivateTeacher(UserModel teacher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Teacher?'),
        content: Text('Are you sure you want to deactivate ${teacher.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      ref.read(teachersNotifierProvider.notifier).deactivateTeacher(teacher.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final teachersAsync = ref.watch(teachersProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showAddTeacherSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Teacher', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teachers Management',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'View and manage all registered teachers in the system',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: teachersAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text('Error: $e', style: TextStyle(color: AppColors.error))),
                    data: (teachers) {
                      if (teachers.isEmpty) {
                        return const Center(child: Text('No teachers found.'));
                      }

                      return PremiumDataTable<UserModel>(
                        title: 'Teachers',
                        columns: const ['Teacher', 'Email', 'Status', 'Actions'],
                        data: teachers,
                        rowBuilder: (teacher) {
                          return [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16.r,
                                  backgroundImage: teacher.avatarUrl != null ? NetworkImage(teacher.avatarUrl!) : null,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  child: teacher.avatarUrl == null
                                      ? Text(teacher.name[0].toUpperCase(), style: TextStyle(color: AppColors.primary, fontSize: 12.sp, fontWeight: FontWeight.bold))
                                      : null,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(child: Text(teacher.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                              ],
                            ),
                            Text(teacher.email),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: (teacher.status == 'active' ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                (teacher.status ?? 'active').toUpperCase(),
                                style: TextStyle(
                                  color: teacher.status == 'active' ? AppColors.success : AppColors.error,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
                                  onPressed: () {
                                    context.push(RoutePaths.addUser, extra: teacher);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                  onPressed: () => _deactivateTeacher(teacher),
                                ),
                              ],
                            ),
                          ];
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
