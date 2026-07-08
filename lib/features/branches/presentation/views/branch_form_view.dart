import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/shared/models/branch_model.dart';
import 'package:ascento_abacus/features/branches/data/repositories/branches_repository.dart';
import 'package:ascento_abacus/features/branches/presentation/providers/branches_provider.dart';
import 'package:go_router/go_router.dart';

class BranchFormView extends ConsumerStatefulWidget {
  final BranchModel? branch; // null means create

  const BranchFormView({super.key, this.branch});

  @override
  ConsumerState<BranchFormView> createState() => _BranchFormViewState();
}

class _BranchFormViewState extends ConsumerState<BranchFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.branch?.name ?? '');
    _cityController = TextEditingController(text: widget.branch?.city ?? '');
    _phoneController = TextEditingController(text: widget.branch?.phone ?? '');
    _addressController = TextEditingController(text: widget.branch?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repository = ref.read(branchesRepositoryProvider);
      final data = {
        'name': _nameController.text.trim(),
        'city': _cityController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      };

      if (widget.branch == null) {
        await repository.createBranch(data);
      } else {
        await repository.updateBranch(widget.branch!.id, data);
      }

      ref.invalidate(branchesListProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.branch == null ? 'Branch created successfully' : 'Branch updated successfully'),
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
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.branch == null ? 'Add Branch' : 'Edit Branch',
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
                        label: 'Branch Name',
                        hint: 'Enter branch name',
                        prefixIcon: Icons.business_rounded,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        controller: _cityController,
                        label: 'City',
                        hint: 'Enter city',
                        prefixIcon: Icons.location_city_rounded,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: 'Enter phone number',
                        prefixIcon: Icons.phone_rounded,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        controller: _addressController,
                        label: 'Address',
                        hint: 'Enter address',
                        prefixIcon: Icons.home_rounded,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  text: widget.branch == null ? 'Create Branch' : 'Save Changes',
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
