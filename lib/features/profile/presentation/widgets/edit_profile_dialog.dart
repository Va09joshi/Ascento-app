import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/repositories/feature_repository.dart';
import 'package:ascento_abacus/shared/providers/feature_providers.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  final StudentProfile profile;

  const EditProfileDialog({super.key, required this.profile});

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.profile.phone);
    _addressController = TextEditingController(text: widget.profile.address);
    _dobController = TextEditingController(
      text: widget.profile.dateOfBirth != null
          ? '${widget.profile.dateOfBirth!.year}-${widget.profile.dateOfBirth!.month.toString().padLeft(2, '0')}-${widget.profile.dateOfBirth!.day.toString().padLeft(2, '0')}'
          : '',
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final data = <String, dynamic>{};
      if (_phoneController.text.isNotEmpty) data['phone'] = _phoneController.text;
      if (_addressController.text.isNotEmpty) data['address'] = _addressController.text;
      if (_dobController.text.isNotEmpty) data['date_of_birth'] = _dobController.text;

      await ref.read(featureRepositoryProvider).updateStudentProfile(data);
      // ignore: unused_result
      ref.refresh(studentProfileProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
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

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profile',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _addressController,
              label: 'Address',
              hint: 'Enter your address',
              prefixIcon: Icons.location_on,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _dobController,
              label: 'Date of Birth (YYYY-MM-DD)',
              hint: 'e.g. 2010-05-21',
              prefixIcon: Icons.cake,
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    isSecondary: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomButton(
                    text: 'Save',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
