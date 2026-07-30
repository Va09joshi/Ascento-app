import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';

import 'package:ascento_abacus/shared/models/class_model.dart';
import 'package:ascento_abacus/shared/models/section_model.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/users/presentation/providers/teachers_provider.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';
import 'package:ascento_abacus/features/attendance/data/repositories/attendance_repository.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';

final dailyAttendanceProvider = FutureProvider.autoDispose.family<List<AttendanceRecord>, ({String sectionId, DateTime date})>((ref, arg) async {
  return ref.watch(attendanceRepositoryProvider).getAttendanceSheet(arg.sectionId, arg.date, arg.date);
});

class TeacherMarkAttendanceView extends ConsumerStatefulWidget {
  const TeacherMarkAttendanceView({super.key});

  @override
  ConsumerState<TeacherMarkAttendanceView> createState() => _TeacherMarkAttendanceViewState();
}

class _TeacherMarkAttendanceViewState extends ConsumerState<TeacherMarkAttendanceView> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedClassId;
  String? _selectedSectionId;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Local state for attendance toggles before submission
  // studentId -> isPresent
  final Map<String, bool> _attendanceState = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final classesAsync = ref.watch(classesListProvider);
    final sectionsAsync = ref.watch(sectionsListProvider);
    final authState = ref.watch(authControllerProvider);
    final user = authState.currentUser;

    final myStudentsAsync = ref.watch(myStudentsProvider);
    final mySections = myStudentsAsync.valueOrNull ?? [];

    final uniqueClasses = <String, Map<String, String>>{};
    for (var s in mySections) {
      if (s['class_id'] != null && s['class_name'] != null) {
        uniqueClasses[s['class_id']] = {
          'id': s['class_id'].toString(),
          'name': s['class_name'].toString(),
        };
      }
    }
    final teacherClasses = uniqueClasses.values.toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Mark Attendance',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Select a class and section to mark attendance.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  
                  // Date Picker
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null && date != _selectedDate) {
                        setState(() {
                          _selectedDate = date;
                          _attendanceState.clear(); // Clear local state for new date
                          ref.invalidate(dailyAttendanceProvider);
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20.sp),
                          SizedBox(width: 12.w),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down_rounded, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  // Class & Section Dropdowns
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Class',
                            filled: true,
                            fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                            ),
                          ),
                          value: _selectedClassId,
                          items: teacherClasses.map((c) => DropdownMenuItem(
                            value: c['id'],
                            child: Text(c['name']!, overflow: TextOverflow.ellipsis),
                          )).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedClassId = val;
                              _selectedSectionId = null;
                              _attendanceState.clear();
                              ref.invalidate(dailyAttendanceProvider);
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Section',
                            filled: true,
                            fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                            ),
                          ),
                          value: _selectedSectionId,
                          items: mySections
                              .where((s) => s['class_id'] == _selectedClassId)
                              .map((s) => DropdownMenuItem(
                            value: s['section_id']?.toString(),
                            child: Text(s['section_name']?.toString() ?? '', overflow: TextOverflow.ellipsis),
                          )).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedSectionId = val;
                              _attendanceState.clear();
                              ref.invalidate(dailyAttendanceProvider);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_selectedSectionId != null) ...[
                    SizedBox(height: 16.h),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search student by name...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.toLowerCase();
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
            
            // Student List
            Expanded(
              child: _selectedSectionId == null
                  ? Center(
                      child: Text(
                        'Please select a class and section to view students.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                      ),
                    )
                  : ref.watch(sectionStudentsProvider(_selectedSectionId!)).when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      data: (students) {
                        if (students.isEmpty) {
                          return Center(
                            child: Text(
                              'No students found in this section.',
                              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                            ),
                          );
                        }
                        
                        // Fetch existing attendance for the selected date
                        final existingRecordsAsync = ref.watch(dailyAttendanceProvider((sectionId: _selectedSectionId!, date: _selectedDate)));
                        
                        // Map of studentId -> AttendanceRecord
                        final existingMap = <String, AttendanceRecord>{};
                        if (existingRecordsAsync.hasValue && existingRecordsAsync.value != null) {
                          for (var r in existingRecordsAsync.value!) {
                            if (r.studentId != null) {
                              existingMap[r.studentId!] = r;
                            }
                          }
                        }

                        // Initialize attendance state if empty
                        if (_attendanceState.isEmpty || _attendanceState.keys.length != students.length) {
                          for (final student in students) {
                            if (existingMap.containsKey(student.id)) {
                              _attendanceState[student.id] = existingMap[student.id]!.status == AttendanceStatus.present;
                            } else {
                              _attendanceState[student.id] = true;
                            }
                          }
                        }

                        final filteredStudents = students
                            .where((s) => s.name.toLowerCase().contains(_searchQuery))
                            .toList();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                                child: Text(
                                  'Total Students: ${students.length}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (filteredStudents.isEmpty && _searchQuery.isNotEmpty)
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'No students found matching "$_searchQuery".',
                                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                                    ),
                                  ),
                                )
                              else
                                Expanded(
                                  child: ListView.separated(
                                    padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 100.h),
                                    itemCount: filteredStudents.length,
                                    separatorBuilder: (_, __) => Divider(color: isDark ? AppColors.darkBorder : AppColors.border, height: 1),
                                    itemBuilder: (context, index) {
                                      final student = filteredStudents[index];
                                      final isPresent = _attendanceState[student.id] ?? true;
                                      
                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: 6.h),
                                        child: AppCard(
                                          padding: EdgeInsets.all(12.r),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 22.r,
                                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                                backgroundImage: student.avatarUrl != null ? NetworkImage(student.avatarUrl!) : null,
                                                child: student.avatarUrl == null
                                                    ? Text(student.name.isNotEmpty ? student.name[0] : 'S', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16.sp))
                                                    : null,
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(student.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                                                    if (existingMap.containsKey(student.id)) ...[
                                                      SizedBox(height: 4.h),
                                                      Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                                        decoration: BoxDecoration(
                                                          color: (existingMap[student.id]!.status == AttendanceStatus.present ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                                                          borderRadius: BorderRadius.circular(4.r),
                                                        ),
                                                        child: Text(
                                                          'Saved: ${existingMap[student.id]!.status == AttendanceStatus.present ? "Present" : "Absent"}',
                                                          style: TextStyle(
                                                            fontSize: 10.sp, 
                                                            fontWeight: FontWeight.w600,
                                                            color: existingMap[student.id]!.status == AttendanceStatus.present ? AppColors.success : AppColors.error,
                                                          ),
                                                        ),
                                                      ),
                                                    ] else
                                                      Text(student.email, style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted)),
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _attendanceState[student.id] = !isPresent;
                                                  });
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 200),
                                                  width: 72.w,
                                                  height: 36.h,
                                                  decoration: BoxDecoration(
                                                    color: isPresent ? AppColors.success.withValues(alpha: 0.15) : AppColors.error.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(20.r),
                                                    border: Border.all(
                                                      color: isPresent ? AppColors.success.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      AnimatedAlign(
                                                        duration: const Duration(milliseconds: 200),
                                                        curve: Curves.easeOut,
                                                        alignment: isPresent ? Alignment.centerRight : Alignment.centerLeft,
                                                        child: Container(
                                                          width: 32.w,
                                                          height: 32.h,
                                                          margin: EdgeInsets.all(2.w),
                                                          decoration: BoxDecoration(
                                                            color: isPresent ? AppColors.success : AppColors.error,
                                                            shape: BoxShape.circle,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: (isPresent ? AppColors.success : AppColors.error).withValues(alpha: 0.4),
                                                                blurRadius: 4,
                                                                offset: const Offset(0, 2),
                                                              )
                                                            ],
                                                          ),
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            isPresent ? 'P' : 'A',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 14.sp,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: isPresent ? Alignment.centerLeft : Alignment.centerRight,
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                          child: Text(
                                                            isPresent ? 'A' : 'P',
                                                            style: TextStyle(
                                                              color: isPresent ? AppColors.error : AppColors.success,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 12.sp,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
              ),
              if (_selectedSectionId != null)
                Container(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: CustomButton(
                      text: 'Submit Attendance',
                      isLoading: _isSubmitting,
                      onPressed: _submitAttendance,
                    ),
                  ),
                ),
            ],
          ),
        ),
    );
  }

  Future<void> _submitAttendance() async {
    if (_selectedSectionId == null) return;
    
    setState(() => _isSubmitting = true);
    try {
      final records = _attendanceState.entries.map((e) => {
        'student_id': e.key,
        'present': e.value,
      }).toList();
      
      await ref.read(attendanceRepositoryProvider).markBulkAttendance(
        _selectedClassId!,
        _selectedSectionId!,
        _selectedDate,
        records,
      );
      
      // Refresh the existing records so the UI updates with the 'Saved' badges
      ref.invalidate(dailyAttendanceProvider);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance marked successfully!'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit attendance: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
