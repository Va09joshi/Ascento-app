import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/shared/models/section_model.dart';
import 'package:ascento_abacus/features/academics/data/repositories/academics_repository.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';
import 'package:ascento_abacus/features/users/presentation/providers/users_provider.dart';
import 'package:go_router/go_router.dart';

class SectionFormView extends ConsumerStatefulWidget {
  final SectionModel? section;

  const SectionFormView({super.key, this.section});

  @override
  ConsumerState<SectionFormView> createState() => _SectionFormViewState();
}

class _SectionFormViewState extends ConsumerState<SectionFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _maxStudentsController;
  String? _selectedClassId;
  String? _selectedTeacherId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.section?.name ?? '');
    _maxStudentsController = TextEditingController(text: widget.section?.maxStudents.toString() ?? '');
    _selectedClassId = widget.section?.classId;
    _selectedTeacherId = widget.section?.teacherId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxStudentsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a class'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repository = ref.read(academicsRepositoryProvider);
      final data = {
        'name': _nameController.text.trim(),
        'class_id': _selectedClassId,
        'max_students': int.tryParse(_maxStudentsController.text.trim()) ?? 40,
        if (_selectedTeacherId != null) 'teacher_id': _selectedTeacherId,
      };

      if (widget.section == null) {
        await repository.createSection(data);
      } else {
        await repository.updateSection(widget.section!.id, data);
      }

      ref.invalidate(sectionsListProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.section == null ? 'Section created successfully' : 'Section updated successfully'),
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
    final classesAsync = ref.watch(classesListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          widget.section == null ? 'Add Section' : 'Edit Section',
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
                        label: 'Section Name',
                        hint: 'Enter section name (e.g. A)',
                        prefixIcon: Icons.group_work_rounded,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),
                      classesAsync.when(
                        data: (classes) => DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Select Class',
                            prefixIcon: const Icon(Icons.class_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                            ),
                          ),
                          value: _selectedClassId,
                          items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                          onChanged: (val) => setState(() => _selectedClassId = val),
                          validator: (value) => value == null ? 'Required' : null,
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, s) => Text('Error loading classes: $e'),
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        controller: _maxStudentsController,
                        label: 'Max Students',
                        hint: 'Enter max students',
                        prefixIcon: Icons.format_list_numbered_rounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),
                      ref.watch(usersListProvider('teacher')).when(
                        data: (teachers) => DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Assign Teacher',
                            prefixIcon: const Icon(Icons.person_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                            ),
                          ),
                          value: _selectedTeacherId,
                          items: [
                            const DropdownMenuItem(value: null, child: Text('No Teacher assigned')),
                            ...teachers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))),
                          ],
                          onChanged: (val) => setState(() => _selectedTeacherId = val),
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, s) => Text('Error loading teachers: $e'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  text: widget.section == null ? 'Create Section' : 'Save Changes',
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
