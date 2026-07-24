import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';

import 'package:ascento_abacus/shared/models/class_model.dart';
import 'package:ascento_abacus/shared/models/section_model.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';
import 'package:ascento_abacus/features/attendance/data/repositories/attendance_repository.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';

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

    final teacherSections = sectionsAsync.valueOrNull?.where((s) => s.teacherId == user?.id).toList() ?? [];
    final teacherClassIds = teacherSections.map((s) => s.classId).toSet();
    final teacherClasses = classesAsync.valueOrNull?.where((c) => teacherClassIds.contains(c.id)).toList() ?? [];

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
                      if (date != null) {
                        setState(() => _selectedDate = date);
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
                            value: c.id,
                            child: Text(c.name, overflow: TextOverflow.ellipsis),
                          )).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedClassId = val;
                              _selectedSectionId = null;
                              _attendanceState.clear();
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
                          items: teacherSections
                              .where((s) => s.classId == _selectedClassId)
                              .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name, overflow: TextOverflow.ellipsis),
                          )).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedSectionId = val;
                              _attendanceState.clear();
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
                        
                        // Initialize attendance state if empty (default to present)
                        if (_attendanceState.isEmpty) {
                          for (final student in students) {
                            _attendanceState[student.id] = true;
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
                                      
                                      return ListTile(
                                        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                                        leading: CircleAvatar(
                                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                          backgroundImage: student.avatarUrl != null ? NetworkImage(student.avatarUrl!) : null,
                                          child: student.avatarUrl == null
                                              ? Text(student.name.isNotEmpty ? student.name[0] : 'S', style: const TextStyle(color: AppColors.primary))
                                              : null,
                                        ),
                                        title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        subtitle: Text(student.email, style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted)),
                                        trailing: Switch(
                                          value: isPresent,
                                          activeColor: AppColors.success,
                                          inactiveThumbColor: AppColors.error,
                                          inactiveTrackColor: AppColors.error.withValues(alpha: 0.3),
                                          onChanged: (val) {
                                            setState(() {
                                              _attendanceState[student.id] = val;
                                            });
                                          },
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
            ],
      )


      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _selectedSectionId != null
          ? Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: CustomButton(
          text: 'Submit Attendance',
          isLoading: _isSubmitting,
          onPressed: _submitAttendance,
        ),
      )

          : null,
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
        _selectedSectionId!,
        _selectedDate,
        records,
      );
      
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
