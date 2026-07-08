import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/widgets/premium_data_table.dart';

import 'package:ascento_abacus/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';

class TimetableManagementView extends ConsumerWidget {
  const TimetableManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedClassId = ref.watch(selectedClassIdProvider);
    final selectedSectionId = ref.watch(selectedSectionIdProvider);
    
    final classesAsync = ref.watch(classesListProvider);
    final sectionsAsync = ref.watch(sectionsListProvider);
    final timetableAsync = ref.watch(sectionTimetableProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filters Section
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Select Class'),
                        value: selectedClassId,
                        isExpanded: true,
                        items: classesAsync.valueOrNull?.map((c) {
                          return DropdownMenuItem(value: c.id, child: Text(c.name));
                        }).toList() ?? [],
                        onChanged: (value) {
                          ref.read(selectedClassIdProvider.notifier).state = value;
                          ref.read(selectedSectionIdProvider.notifier).state = null; // reset section
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Select Section'),
                        value: selectedSectionId,
                        isExpanded: true,
                        items: sectionsAsync.valueOrNull
                            ?.where((s) => s.classId == selectedClassId)
                            .map((s) {
                          return DropdownMenuItem(value: s.id, child: Text(s.name));
                        }).toList() ?? [],
                        onChanged: selectedClassId == null ? null : (value) {
                          ref.read(selectedSectionIdProvider.notifier).state = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              
              if (selectedSectionId == null)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Text(
                      'Please select a Class and Section to view the timetable.',
                      style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                    ),
                  ),
                )
              else
              PremiumDataTable<TimetableSlot>(
                title: 'Timetable Management',
                subtitle: 'Manage class schedules, assigned teachers, and rooms.',
                isLoading: timetableAsync.isLoading,
                data: timetableAsync.value ?? [],
                columns: const ['Subject & Teacher', 'Time', 'Room', 'Day', 'Actions'],
                rowBuilder: (slot) => [
                  // Subject & Teacher
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: (slot.subjectColor ?? AppColors.primary).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.book_rounded, color: slot.subjectColor ?? AppColors.primary, size: 16.sp),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slot.subject,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                          ),
                          Text(
                            slot.teacherName,
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Time
                  Text('${slot.startTime} - ${slot.endTime}'),
                  // Room
                  Text(slot.room),
                  // Day
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      _getDayName(slot.dayOfWeek),
                      style: TextStyle(
                        color: AppColors.info,
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
          // TODO: Add Slot
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Slot'),
      ),
    );
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1: return 'MONDAY';
      case 2: return 'TUESDAY';
      case 3: return 'WEDNESDAY';
      case 4: return 'THURSDAY';
      case 5: return 'FRIDAY';
      case 6: return 'SATURDAY';
      case 7: return 'SUNDAY';
      default: return 'UNKNOWN';
    }
  }
}
