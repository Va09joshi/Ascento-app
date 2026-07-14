import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/shared/models/academic_year_model.dart';
import 'package:ascento_abacus/features/academics/data/repositories/academics_repository.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';
import 'package:go_router/go_router.dart';

class AcademicYearFormView extends ConsumerStatefulWidget {
  final AcademicYearModel? academicYear;

  const AcademicYearFormView({super.key, this.academicYear});

  @override
  ConsumerState<AcademicYearFormView> createState() => _AcademicYearFormViewState();
}

class _AcademicYearFormViewState extends ConsumerState<AcademicYearFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  bool _isCurrent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.academicYear?.name ?? '');
    _startDateController = TextEditingController(
      text: widget.academicYear?.startDate.split('T')[0] ?? '',
    );
    _endDateController = TextEditingController(
      text: widget.academicYear?.endDate.split('T')[0] ?? '',
    );
    _isCurrent = widget.academicYear?.isCurrent ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repository = ref.read(academicsRepositoryProvider);
      final data = {
        'name': _nameController.text.trim(),
        'start_date': _startDateController.text.trim(),
        'end_date': _endDateController.text.trim(),
        'is_current': _isCurrent,
      };

      if (widget.academicYear == null) {
        await repository.createAcademicYear(data);
      } else {
        await repository.updateAcademicYear(widget.academicYear!.id, data);
      }

      ref.invalidate(academicYearsListProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.academicYear == null ? 'Academic year created successfully' : 'Academic year updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'), 
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          widget.academicYear == null ? 'Add Academic Year' : 'Edit Academic Year',
          style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        label: 'Name (e.g. 2024-2025)',
                        hint: 'Enter academic year name',
                        prefixIcon: Icons.calendar_today_rounded,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        controller: _startDateController,
                        label: 'Start Date',
                        hint: 'Select start date',
                        prefixIcon: Icons.date_range_rounded,
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            _startDateController.text = date.toIso8601String().split('T')[0];
                          }
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        controller: _endDateController,
                        label: 'End Date',
                        hint: 'Select end date',
                        prefixIcon: Icons.event_rounded,
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            _endDateController.text = date.toIso8601String().split('T')[0];
                          }
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Is Current Year?', style: TextStyle(fontWeight: FontWeight.bold)),
                        value: _isCurrent,
                        onChanged: (val) => setState(() => _isCurrent = val),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  text: widget.academicYear == null ? 'Create' : 'Save Changes',
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
