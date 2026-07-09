import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';
import 'package:ascento_abacus/features/users/presentation/providers/users_provider.dart';
import 'package:ascento_abacus/features/timetable/data/repositories/timetable_repository.dart';
import 'package:ascento_abacus/features/timetable/presentation/providers/timetable_provider.dart';

class TimetableSlotFormDialog extends ConsumerStatefulWidget {
  final String sectionId;

  const TimetableSlotFormDialog({super.key, required this.sectionId});

  @override
  ConsumerState<TimetableSlotFormDialog> createState() => _TimetableSlotFormDialogState();
}

class _TimetableSlotFormDialogState extends ConsumerState<TimetableSlotFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedSubjectId;
  String? _selectedTeacherId;
  int? _selectedDayOfWeek;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _isLoading = false;

  final List<Map<String, dynamic>> _days = [
    {'value': 1, 'label': 'Monday'},
    {'value': 2, 'label': 'Tuesday'},
    {'value': 3, 'label': 'Wednesday'},
    {'value': 4, 'label': 'Thursday'},
    {'value': 5, 'label': 'Friday'},
    {'value': 6, 'label': 'Saturday'},
    {'value': 7, 'label': 'Sunday'},
  ];

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end time'), backgroundColor: Colors.red)
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payload = {
        'section_id': widget.sectionId,
        'subject_id': _selectedSubjectId,
        'teacher_id': _selectedTeacherId,
        'day_of_week': _selectedDayOfWeek,
        'start_time': _formatTimeOfDay(_startTime!),
        'end_time': _formatTimeOfDay(_endTime!),
      };

      await ref.read(timetableRepositoryProvider).createTimetableSlot(payload);
      ref.invalidate(sectionTimetableProvider);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Slot added successfully'), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final subjectsAsync = ref.watch(subjectsListProvider);
    final teachersAsync = ref.watch(usersListProvider('teacher'));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Timetable Slot',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24.h),

                // Subject
                subjectsAsync.when(
                  data: (subjects) => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Subject',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    initialValue: _selectedSubjectId,
                    items: subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (val) => setState(() => _selectedSubjectId = val),
                    validator: (val) => val == null ? 'Required' : null,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Error loading subjects'),
                ),
                SizedBox(height: 16.h),

                // Teacher
                teachersAsync.when(
                  data: (teachers) => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Teacher',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    initialValue: _selectedTeacherId,
                    items: teachers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                    onChanged: (val) => setState(() => _selectedTeacherId = val),
                    validator: (val) => val == null ? 'Required' : null,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Error loading teachers'),
                ),
                SizedBox(height: 16.h),

                // Day of Week
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Select Day',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  initialValue: _selectedDayOfWeek,
                  items: _days.map((d) => DropdownMenuItem<int>(value: d['value'], child: Text(d['label']))).toList(),
                  onChanged: (val) => setState(() => _selectedDayOfWeek = val),
                  validator: (val) => val == null ? 'Required' : null,
                ),
                SizedBox(height: 16.h),

                // Time Pickers
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context, true),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Start Time',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(_startTime?.format(context) ?? 'Select Time'),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context, false),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'End Time',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(_endTime?.format(context) ?? 'Select Time'),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    SizedBox(width: 12.w),
                    CustomButton(
                      text: 'Add Slot',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
