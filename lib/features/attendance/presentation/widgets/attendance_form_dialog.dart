import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/users/presentation/providers/users_provider.dart';

class AttendanceFormDialog extends ConsumerStatefulWidget {
  const AttendanceFormDialog({super.key});

  @override
  ConsumerState<AttendanceFormDialog> createState() => _AttendanceFormDialogState();
}

class _AttendanceFormDialogState extends ConsumerState<AttendanceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedStudentId;
  DateTime _selectedDate = DateTime.now();
  AttendanceStatus _selectedStatus = AttendanceStatus.present;
  final _remarksController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    // Simulate API Call for marking attendance
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance marked successfully'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final studentsAsync = ref.watch(usersListProvider('student'));

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
                  'Mark Attendance',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24.h),

                // Student
                studentsAsync.when(
                  data: (students) => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Student',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    initialValue: _selectedStudentId,
                    items: students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (val) => setState(() => _selectedStudentId = val),
                    validator: (val) => val == null ? 'Required' : null,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => const Text('Error loading students'),
                ),
                SizedBox(height: 16.h),

                // Date
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(_selectedDate.toIso8601String().split('T').first),
                  ),
                ),
                SizedBox(height: 16.h),

                // Status
                DropdownButtonFormField<AttendanceStatus>(
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  initialValue: _selectedStatus,
                  items: AttendanceStatus.values.map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.name.toUpperCase()),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedStatus = val!),
                ),
                SizedBox(height: 16.h),

                // Remarks
                CustomTextField(
                  label: 'Remarks (Optional)',
                  hint: 'Enter remarks here...',
                  controller: _remarksController,
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
                      text: 'Save',
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
