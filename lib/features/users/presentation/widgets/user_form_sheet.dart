import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/features/users/data/repositories/users_repository.dart';
import 'package:ascento_abacus/features/users/presentation/providers/users_provider.dart';

import 'package:ascento_abacus/shared/models/user_model.dart';

class UserFormSheet extends ConsumerStatefulWidget {
  final String initialRole;
  final UserModel? userToEdit;
  const UserFormSheet({super.key, required this.initialRole, this.userToEdit});

  @override
  ConsumerState<UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends ConsumerState<UserFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedRole;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Student specific
  final _classIdController = TextEditingController();
  final _sectionIdController = TextEditingController();
  final _rollNumberController = TextEditingController();

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
    _classIdController.dispose();
    _sectionIdController.dispose();
    _rollNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final payload = {
        'role': _selectedRole,
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      };
      
      if (_phoneController.text.isNotEmpty) {
        payload['phone'] = _phoneController.text.trim();
      }
      
      if (_selectedRole == 'student' && !_isEdit) {
        payload['class_id'] = _classIdController.text.trim();
        payload['section_id'] = _sectionIdController.text.trim();
        payload['roll_number'] = _rollNumberController.text.trim();
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

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.creamSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isEdit ? 'Edit User' : 'Add New User',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16.h),
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: const InputDecoration(labelText: 'Role'),
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
                            SizedBox(height: 12.h),
                            CustomTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              hint: 'John Doe',
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                            SizedBox(height: 12.h),
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'john@example.com',
                              validator: (v) => v == null || !v.contains('@') ? 'Invalid email' : null,
                            ),
                            SizedBox(height: 12.h),
                            CustomTextField(
                              controller: _phoneController,
                              label: 'Phone Number (Optional)',
                              hint: '+91 9876543210',
                            ),
                            
                            if (_selectedRole == 'student' && !_isEdit) ...[
                              SizedBox(height: 12.h),
                              const Divider(),
                              SizedBox(height: 12.h),
                              Text('Academic Details', style: theme.textTheme.labelLarge),
                              SizedBox(height: 12.h),
                              CustomTextField(
                                controller: _classIdController,
                                label: 'Class ID (UUID)',
                                hint: 'Enter Class UUID',
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                              ),
                              SizedBox(height: 12.h),
                              CustomTextField(
                                controller: _sectionIdController,
                                label: 'Section ID (UUID)',
                                hint: 'Enter Section UUID',
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                              ),
                              SizedBox(height: 12.h),
                              CustomTextField(
                                controller: _rollNumberController,
                                label: 'Roll Number (Optional)',
                                hint: '101A',
                              ),
                            ],
                            
                            SizedBox(height: 24.h),
                            SafeArea(
                              top: false,
                              child: CustomButton(
                                text: _isEdit ? 'Update User' : 'Create User',
                                isLoading: _isLoading,
                                onPressed: _submit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
