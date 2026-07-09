import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/features/users/data/repositories/users_repository.dart';
import 'package:ascento_abacus/features/users/presentation/providers/users_provider.dart';
import 'package:ascento_abacus/features/domains/presentation/providers/domains_provider.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';

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

  // Student details
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); // Or teacher email
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  
  // Parent details
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Academic & Address / Teacher info
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();

  String? _selectedDomain;
  String? _selectedStatus = 'Active';
  String? _selectedGender = 'Male';
  DateTime? _selectedDateOfBirth;

  bool get _isEdit => widget.userToEdit != null;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.userToEdit?.role.name ?? widget.initialRole;
    if (_isEdit) {
      _nameController.text = widget.userToEdit!.name;
      _emailController.text = widget.userToEdit!.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _parentEmailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      final repo = ref.read(usersRepositoryProvider);
      final payload = {
        'full_name': _nameController.text.trim(),
        'email': _selectedRole == 'student' ? _parentEmailController.text.trim() : _emailController.text.trim(),
        'phone': _selectedRole == 'student' ? _parentPhoneController.text.trim() : _phoneController.text.trim(),
        'role': _selectedRole,
        'gender': _selectedGender?.toLowerCase(),
        'status': _selectedStatus,
        'address': _addressController.text.trim(),
        if (_selectedDomain != null) 'domain_id': _selectedDomain,
      };
      
      if (_isEdit) {
        await repo.updateUser(widget.userToEdit!.id, payload);
      } else {
        await repo.createUser(payload);
      }
      
      ref.invalidate(usersListProvider(_selectedRole));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, fontSize: 12.sp, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildResponsiveRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children.map((c) => Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8.w), child: c))).toList(),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children.map((c) => Padding(padding: EdgeInsets.only(bottom: 16.h), child: c)).toList(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = _selectedRole == 'student';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Update ${_selectedRole.capitalize()}' : 'Create ${_selectedRole.capitalize()}', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8.r)),
                child: Text(
                  isStudent 
                    ? 'Fill student and parent details. On mobile, fields are shown in a single-column flow for easier input.'
                    : 'Fill user details. Passwords are auto-generated if left blank.',
                  style: TextStyle(color: Colors.blue.shade800, fontSize: 13.sp),
                ),
              ),
              SizedBox(height: 16.h),

              if (isStudent) ...[
                _buildSectionTitle('STUDENT DETAILS'),
                _buildResponsiveRow([
                  CustomTextField(controller: _nameController, label: 'Full Name'),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(context: context, initialDate: DateTime(2010), firstDate: DateTime(1990), lastDate: DateTime.now());
                      if (date != null) setState(() => _selectedDateOfBirth = date);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: 'DOB', suffixIcon: const Icon(Icons.calendar_today)),
                      child: Text(_selectedDateOfBirth?.toString().split(' ').first ?? 'mm/dd/yyyy'),
                    ),
                  ),
                ]),
                SizedBox(height: 16.h),
                _buildResponsiveRow([
                  CustomTextField(controller: _ageController, label: 'Age'),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Gender'),
                    value: _selectedGender,
                    items: ['Male', 'Female'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _selectedGender = v),
                  ),
                ]),
                _buildSectionTitle('PARENT DETAILS'),
                _buildResponsiveRow([
                  CustomTextField(controller: _parentNameController, label: 'Parent Name'),
                  CustomTextField(controller: _parentPhoneController, label: 'Parent Phone'),
                ]),
                SizedBox(height: 16.h),
                _buildResponsiveRow([
                  CustomTextField(controller: _parentEmailController, label: 'Parent Email'),
                  ref.watch(domainsListProvider).when(
                    data: (domains) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Domain'),
                      value: _selectedDomain,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Select domain')),
                        ...domains.where((d) => d.isActive).map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                      ],
                      onChanged: (v) => setState(() => _selectedDomain = v),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => const Text('Error loading domains'),
                  ),
                ]),
                SizedBox(height: 16.h),
                CustomTextField(controller: _passwordController, label: 'Password (Optional)', hint: 'Leave blank to auto-generate temporary'),
                
                _buildSectionTitle('ACADEMIC & ADDRESS'),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Status'),
                  value: _selectedStatus,
                  items: ['Active', 'Inactive'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _selectedStatus = v),
                ),
                SizedBox(height: 16.h),
                CustomTextField(controller: _addressController, label: 'Address'),
                SizedBox(height: 16.h),
                _buildResponsiveRow([
                  CustomTextField(controller: _cityController, label: 'City'),
                  CustomTextField(controller: _stateController, label: 'State'),
                ]),
              ] else ...[
                _buildResponsiveRow([
                  CustomTextField(controller: _nameController, label: 'Name'),
                  CustomTextField(controller: _emailController, label: 'Email'),
                ]),
                SizedBox(height: 16.h),
                _buildResponsiveRow([
                  CustomTextField(controller: _phoneController, label: 'Phone'),
                  ref.watch(domainsListProvider).when(
                    data: (domains) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Domain'),
                      value: _selectedDomain,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Select domain')),
                        ...domains.where((d) => d.isActive).map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                      ],
                      onChanged: (v) => setState(() => _selectedDomain = v),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => const Text('Error loading domains'),
                  ),
                ]),
                SizedBox(height: 16.h),
                _buildResponsiveRow([
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Status'),
                    value: _selectedStatus,
                    items: ['Active', 'Inactive'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _selectedStatus = v),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Gender'),
                    value: _selectedGender,
                    items: ['Male', 'Female'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _selectedGender = v),
                  ),
                ]),
                SizedBox(height: 16.h),
                _buildResponsiveRow([
                  CustomTextField(controller: _qualificationController, label: 'Qualification'),
                  CustomTextField(controller: _experienceController, label: 'Experience (Years)'),
                ]),
                SizedBox(height: 16.h),
                CustomTextField(controller: _addressController, label: 'Address'),
                SizedBox(height: 16.h),
                _buildResponsiveRow([
                  CustomTextField(controller: _cityController, label: 'City'),
                  CustomTextField(controller: _stateController, label: 'State'),
                ]),
                SizedBox(height: 16.h),
                CustomTextField(controller: _countryController, label: 'Country'),
              ],

              SizedBox(height: 32.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  SizedBox(width: 16.w),
                  CustomButton(
                    text: _isEdit ? 'Update ${_selectedRole.capitalize()}' : 'Create ${_selectedRole.capitalize()}',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
