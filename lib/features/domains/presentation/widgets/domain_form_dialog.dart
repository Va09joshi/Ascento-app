import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/shared/models/domain_model.dart';
import 'package:ascento_abacus/features/domains/presentation/providers/domains_provider.dart';

class DomainFormDialog extends ConsumerStatefulWidget {
  final DomainModel? domain;
  const DomainFormDialog({super.key, this.domain});

  @override
  ConsumerState<DomainFormDialog> createState() => _DomainFormDialogState();
}

class _DomainFormDialogState extends ConsumerState<DomainFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late bool _isActive;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.domain?.name ?? '');
    _descController = TextEditingController(text: widget.domain?.description ?? '');
    _isActive = widget.domain?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final payload = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'is_active': _isActive,
    };

    try {
      if (widget.domain == null) {
        await ref.read(domainsListProvider.notifier).createDomain(payload);
      } else {
        await ref.read(domainsListProvider.notifier).updateDomain(widget.domain!.id, payload);
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.domain == null ? 'Domain created successfully' : 'Domain updated successfully'),
            backgroundColor: AppColors.success,
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppColors.error)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: 450.w,
        padding: EdgeInsets.all(32.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.domain == null ? 'Create New Domain' : 'Edit Domain',
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              SizedBox(height: 24.h),
              
              CustomTextField(
                controller: _nameController,
                label: 'Domain Name',
                hint: 'e.g., Abacus, Vedic Math',
                validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
              ),
              SizedBox(height: 16.h),
              
              CustomTextField(
                controller: _descController,
                label: 'Description',
                hint: 'Brief description...',
                maxLines: 3,
              ),
              SizedBox(height: 16.h),
              
              SwitchListTile(
                title: const Text('Is Active', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Inactive domains will not be selectable'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              SizedBox(height: 32.h),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  SizedBox(width: 16.w),
                  SizedBox(
                    width: 140.w,
                    child: CustomButton(
                      text: widget.domain == null ? 'Create' : 'Save Changes',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
