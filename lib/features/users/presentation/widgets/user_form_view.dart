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
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';
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

  XFile? _selectedAvatar;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedAvatar = picked);
    }
  }

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

  final _rollNumberController = TextEditingController();
  String? _selectedClassId;
  String? _selectedSectionId;
  String? _selectedAcademicYearId;

  String? _selectedDomain;
  String? _selectedStatus = 'Active';
  String? _selectedGender = 'Male';
  DateTime? _selectedDateOfBirth;

  bool get _isEdit => widget.userToEdit != null;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.userToEdit?.role.name ?? widget.initialRole;
    if (_isEdit && widget.userToEdit != null) {
      final user = widget.userToEdit!;
      _nameController.text = user.name;
      _emailController.text = user.email;
      
      if (_selectedRole == 'student') {
        _parentEmailController.text = user.email;
        if (user.phone != null) _parentPhoneController.text = user.phone!;
        _selectedClassId = user.classId;
        _selectedSectionId = user.sectionId;
        _selectedAcademicYearId = user.academicYearId;
        if (user.rollNumber != null) _rollNumberController.text = user.rollNumber!;
      } else {
        if (user.phone != null) _phoneController.text = user.phone!;
      }
      
      if (user.address != null) _addressController.text = user.address!;
      
      if (user.gender != null) {
        final g = user.gender!.toLowerCase();
        if (g == 'male' || g == 'female') {
          _selectedGender = g == 'male' ? 'Male' : 'Female';
        }
      }
      if (user.status != null) {
        final s = user.status!.toLowerCase();
        if (s == 'active' || s == 'inactive') {
          _selectedStatus = s == 'active' ? 'Active' : 'Inactive';
        }
      }
      if (user.domainId != null) {
        _selectedDomain = user.domainId;
      }
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
    _rollNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      final repo = ref.read(usersRepositoryProvider);
      final email = _emailController.text.trim();
      final payload = {
        'full_name': _nameController.text.trim(),
        if (email.isNotEmpty) 'email': email,
        'phone': _phoneController.text.trim(),
        'role': _selectedRole,
        'gender': _selectedGender?.toLowerCase(),
        'status': _selectedStatus,
        'address': _addressController.text.trim(),
        if (_selectedDomain != null) 'domain_id': _selectedDomain,
        if (_selectedRole == 'student') 'parent_name': _parentNameController.text.trim(),
        if (_selectedRole == 'student') 'parent_email': _parentEmailController.text.trim(),
        if (_selectedRole == 'student') 'parent_phone': _parentPhoneController.text.trim(),
        if (_selectedRole == 'student' && _selectedClassId != null) 'class_id': _selectedClassId,
        if (_selectedRole == 'student' && _selectedSectionId != null) 'section_id': _selectedSectionId,
        if (_selectedRole == 'student' && _selectedAcademicYearId != null) 'academic_year_id': _selectedAcademicYearId,
        if (_selectedRole == 'student' && _rollNumberController.text.isNotEmpty) 'roll_number': _rollNumberController.text.trim(),
      };
      
      UserModel? createdUser;
      if (_isEdit) {
        await repo.updateUser(widget.userToEdit!.id, payload, avatarFile: _selectedAvatar);
      } else {
        createdUser = await repo.createUser(payload, avatarFile: _selectedAvatar);
      }
      
      ref.invalidate(usersListProvider(_selectedRole));
      if (mounted) {
        if (createdUser?.tempPassword != null) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('User Created Successfully', style: TextStyle(color: AppColors.textPrimary)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please share these login details with the user:\n'),
                  Row(
                    children: [
                      Expanded(child: SelectableText('Email: ${createdUser!.email}')),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18, color: AppColors.primary),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: createdUser!.email));
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Email copied!')));
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: SelectableText('Password: ${createdUser!.tempPassword}')),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18, color: AppColors.primary),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: createdUser!.tempPassword!));
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Password copied!')));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('They will be asked to change this password on their first login.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        }
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
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _selectedAvatar != null
                            ? (kIsWeb 
                                ? NetworkImage(_selectedAvatar!.path) 
                                : FileImage(File(_selectedAvatar!.path))) as ImageProvider
                            : (widget.userToEdit?.avatarUrl != null && widget.userToEdit!.avatarUrl!.isNotEmpty
                                ? NetworkImage(widget.userToEdit!.avatarUrl!) as ImageProvider
                                : null),
                        child: (_selectedAvatar == null && (widget.userToEdit?.avatarUrl == null || widget.userToEdit!.avatarUrl!.isEmpty))
                            ? Icon(Icons.person, size: 50.r, color: Colors.grey.shade400)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 16.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
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
                _buildResponsiveRow([
                  ref.watch(academicYearsListProvider).when(
                    data: (years) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Academic Year'),
                      value: _selectedAcademicYearId,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Select Year')),
                        ...years.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                      ],
                      onChanged: (v) => setState(() => _selectedAcademicYearId = v),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => const Text('Error loading years'),
                  ),
                  ref.watch(classesListProvider).when(
                    data: (classes) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Class'),
                      value: _selectedClassId,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Select Class')),
                        ...classes.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                      ],
                      onChanged: (v) => setState(() => _selectedClassId = v),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => const Text('Error loading classes'),
                  ),
                ]),
                SizedBox(height: 16.h),
                _buildResponsiveRow([
                  ref.watch(sectionsListProvider).when(
                    data: (sections) {
                      final filteredSections = _selectedClassId != null
                          ? sections.where((s) => s.classId == _selectedClassId).toList()
                          : sections.toList();
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Section'),
                        value: filteredSections.any((s) => s.id == _selectedSectionId) ? _selectedSectionId : null,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Select Section')),
                          ...filteredSections.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                        ],
                        onChanged: (v) => setState(() => _selectedSectionId = v),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => const Text('Error loading sections'),
                  ),
                  CustomTextField(controller: _rollNumberController, label: 'Roll Number'),
                ]),
                SizedBox(height: 16.h),
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
