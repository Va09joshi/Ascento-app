import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/features/users/data/repositories/users_repository.dart';
import 'package:ascento_abacus/features/users/presentation/providers/users_provider.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';
import 'package:ascento_abacus/features/branches/presentation/providers/branches_provider.dart';

import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:go_router/go_router.dart';

class UserFormView extends ConsumerStatefulWidget {
  final String initialRole;
  final UserModel? userToEdit;
  const UserFormView({super.key, required this.initialRole, this.userToEdit});

  @override
  ConsumerState<UserFormView> createState() => _UserFormViewState();
}

class _UserFormViewState extends ConsumerState<UserFormView> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedRole;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Student specific
  final _rollNumberController = TextEditingController();

  String? _selectedClassId;
  String? _selectedSectionId;
  String? _selectedAcademicYearId;
  
  // Shared
  String? _selectedBranchId;

  bool get _isEdit => widget.userToEdit != null;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.userToEdit?.role.name ?? widget.initialRole;
    if (_isEdit) {
      _nameController.text = widget.userToEdit!.name;
      _emailController.text = widget.userToEdit!.email;
      // Note: phone, classId, sectionId, rollNumber might not be available in base UserModel
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _rollNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final payload = <String, dynamic>{
        'full_name': _nameController.text.trim(),
      };
      
      if (!_isEdit) {
        payload['role'] = _selectedRole;
        payload['email'] = _emailController.text.trim();
      }
      
      if (_phoneController.text.isNotEmpty) {
        payload['phone'] = _phoneController.text.trim();
      }
      
      if (!_isEdit && _selectedBranchId != null) {
        payload['branch_id'] = _selectedBranchId!;
      }
      
      if (_selectedRole == 'student' && !_isEdit) {
        payload['class_id'] = _selectedClassId!;
        payload['section_id'] = _selectedSectionId!;
        payload['roll_number'] = _rollNumberController.text.trim();
        payload['academic_year_id'] = _selectedAcademicYearId!;
      }
      final repo = ref.read(usersRepositoryProvider);
      if (_isEdit) {
        await repo.updateUser(widget.userToEdit!.id, payload);
      } else {
        await repo.createUser(payload);
      }
      
      // Invalidate provider so list refreshes
      ref.invalidate(usersListProvider(_selectedRole));
      if (_isEdit && _selectedRole != widget.initialRole) {
        ref.invalidate(usersListProvider(widget.initialRole));
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEdit ? 'User updated successfully' : 'User created successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
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
    final branchesAsync = ref.watch(branchesListProvider);
    final classesAsync = ref.watch(classesListProvider);
    final sectionsAsync = ref.watch(sectionsListProvider);
    final academicYearsAsync = ref.watch(academicYearsListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit User' : 'Add New User',
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
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
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          prefixIcon: const Icon(Icons.shield_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                          DropdownMenuItem(value: 'student', child: Text('Student')),
                          DropdownMenuItem(value: 'parent', child: Text('Parent')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRole = val);
                        },
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'John Doe',
                        prefixIcon: Icons.person_rounded,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'john@example.com',
                        prefixIcon: Icons.email_rounded,
                        validator: (v) => v == null || !v.contains('@') ? 'Invalid email' : null,
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Phone Number (Optional)',
                        hint: '+91 9876543210',
                        prefixIcon: Icons.phone_rounded,
                      ),

                      if (!_isEdit) ...[
                        SizedBox(height: 20.h),
                        branchesAsync.when(
                          data: (branches) => DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Select Branch',
                              prefixIcon: const Icon(Icons.business_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12)),
                            ),
                            value: _selectedBranchId,
                            items: branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                            onChanged: (val) => setState(() => _selectedBranchId = val),
                            validator: (value) => value == null ? 'Required' : null,
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, s) => Text('Error loading branches: $e'),
                        ),
                      ],

                      if (_selectedRole == 'student' && !_isEdit) ...[
                        SizedBox(height: 20.h),
                        Divider(color: isDark ? Colors.white24 : Colors.black12),
                        SizedBox(height: 20.h),
                        Text('Academic Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        SizedBox(height: 16.h),
                        classesAsync.when(
                          data: (classes) => DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Select Class',
                              prefixIcon: const Icon(Icons.class_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12)),
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
                        sectionsAsync.when(
                          data: (sections) {
                            // Filter sections by selected class if one is selected
                            final filteredSections = _selectedClassId != null
                              ? sections.where((s) => s.classId == _selectedClassId).toList()
                              : sections;
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Select Section',
                                prefixIcon: const Icon(Icons.view_comfy_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12)),
                              ),
                              value: _selectedSectionId,
                              items: filteredSections.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                              onChanged: (val) => setState(() => _selectedSectionId = val),
                              validator: (value) => value == null ? 'Required' : null,
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, s) => Text('Error loading sections: $e'),
                        ),
                        SizedBox(height: 20.h),
                        academicYearsAsync.when(
                          data: (years) => DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Select Academic Year',
                              prefixIcon: const Icon(Icons.calendar_month_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12)),
                            ),
                            value: _selectedAcademicYearId,
                            items: years.map((y) => DropdownMenuItem(value: y.id, child: Text(y.name))).toList(),
                            onChanged: (val) => setState(() => _selectedAcademicYearId = val),
                            validator: (value) => value == null ? 'Required' : null,
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, s) => Text('Error loading years: $e'),
                        ),
                        SizedBox(height: 20.h),
                        CustomTextField(
                          controller: _rollNumberController,
                          label: 'Roll Number',
                          hint: 'A-101',
                          prefixIcon: Icons.format_list_numbered_rounded,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  text: _isEdit ? 'Update User' : 'Create User',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
