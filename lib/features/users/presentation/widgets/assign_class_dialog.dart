import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/features/users/data/repositories/users_repository.dart';

class AssignClassDialog extends ConsumerStatefulWidget {
  final UserModel student;
  
  const AssignClassDialog({super.key, required this.student});

  @override
  ConsumerState<AssignClassDialog> createState() => _AssignClassDialogState();
}

class _AssignClassDialogState extends ConsumerState<AssignClassDialog> {
  String? _selectedClassId;
  String? _selectedSectionId;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final classesAsync = ref.watch(classesListProvider);
    final sectionsAsync = ref.watch(sectionsListProvider);

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text('Assign Class to ${widget.student.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 400.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Select a class and section to assign this student.', style: theme.textTheme.bodyMedium),
            SizedBox(height: 16.h),
            
            // Class Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Class',
                filled: true,
                fillColor: isDark ? AppColors.darkBackground : AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
              value: _selectedClassId,
              items: classesAsync.valueOrNull?.map((c) => DropdownMenuItem(
                value: c.id,
                child: Text(c.name),
              )).toList() ?? [],
              onChanged: (val) {
                setState(() {
                  _selectedClassId = val;
                  _selectedSectionId = null;
                });
              },
            ),
            SizedBox(height: 16.h),
            
            // Section Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Section',
                filled: true,
                fillColor: isDark ? AppColors.darkBackground : AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
              value: _selectedSectionId,
              items: sectionsAsync.valueOrNull
                  ?.where((s) => s.classId == _selectedClassId)
                  .map((s) => DropdownMenuItem(
                value: s.id,
                child: Text(s.name),
              )).toList() ?? [],
              onChanged: (val) => setState(() => _selectedSectionId = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
        ),
        SizedBox(
          width: 120.w,
          child: CustomButton(
            text: 'Assign',
            isLoading: _isSubmitting,
            onPressed: _selectedSectionId == null ? null : _submitAssignment,
          ),
        ),
      ],
    );
  }

  Future<void> _submitAssignment() async {
    setState(() => _isSubmitting = true);
    try {
      // Default academic year for now, in a real app this might be selected or fetched
      const defaultAcademicYearId = '1ce37a6b-c744-4861-ab7d-686beeb59d99'; 

      await ref.read(usersRepositoryProvider).assignStudentClass(
        widget.student.id,
        _selectedClassId!,
        _selectedSectionId!,
        defaultAcademicYearId,
      );
      
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student assigned to class successfully!'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign student: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
