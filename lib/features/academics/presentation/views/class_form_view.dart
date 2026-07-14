import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/shared/models/class_model.dart';
import 'package:ascento_abacus/features/academics/data/repositories/academics_repository.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';
import 'package:go_router/go_router.dart';

class ClassFormView extends ConsumerStatefulWidget {
  final ClassModel? classModel;

  const ClassFormView({super.key, this.classModel});

  @override
  ConsumerState<ClassFormView> createState() => _ClassFormViewState();
}

class _ClassFormViewState extends ConsumerState<ClassFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _orderIndexController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.classModel?.name ?? '');
    _orderIndexController = TextEditingController(text: widget.classModel?.orderIndex.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orderIndexController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repository = ref.read(academicsRepositoryProvider);
      final data = {
        'name': _nameController.text.trim(),
        'order_index': int.tryParse(_orderIndexController.text.trim()) ?? 0,
      };

      if (widget.classModel == null) {
        await repository.createClass(data);
      } else {
        await repository.updateClass(widget.classModel!.id, data);
      }

      ref.invalidate(classesListProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.classModel == null ? 'Class created successfully' : 'Class updated successfully'),
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
          widget.classModel == null ? 'Add Class' : 'Edit Class',
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
                        label: 'Class Name',
                        hint: 'Enter class name',
                        prefixIcon: Icons.class_rounded,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        controller: _orderIndexController,
                        label: 'Order Index',
                        hint: 'Enter order index (number)',
                        prefixIcon: Icons.format_list_numbered_rounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  text: widget.classModel == null ? 'Create Class' : 'Save Changes',
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
