import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/features/exams/data/repositories/exams_repository.dart';
import 'package:ascento_abacus/features/exams/presentation/providers/exams_provider.dart';

class ExamFormView extends ConsumerStatefulWidget {
  const ExamFormView({super.key});

  @override
  ConsumerState<ExamFormView> createState() => _ExamFormViewState();
}

class _ExamFormViewState extends ConsumerState<ExamFormView> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _typeController = TextEditingController();
  final _academicYearIdController = TextEditingController();
  final _classIdController = TextEditingController();
  final _examDateController = TextEditingController();
  final _totalMarksController = TextEditingController(text: '100');
  final _passingMarksController = TextEditingController(text: '40');
  
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _typeController.dispose();
    _academicYearIdController.dispose();
    _classIdController.dispose();
    _examDateController.dispose();
    _totalMarksController.dispose();
    _passingMarksController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final payload = {
        "title": _titleController.text.trim(),
        "type": _typeController.text.trim().toLowerCase(),
        "academic_year_id": _academicYearIdController.text.trim(),
        "class_id": _classIdController.text.trim(),
        "exam_date": _examDateController.text.trim(),
        "total_marks": int.tryParse(_totalMarksController.text.trim()) ?? 100,
        "passing_marks": int.tryParse(_passingMarksController.text.trim()) ?? 40,
      };

      await ref.read(examsRepositoryProvider).createExam(payload);
      ref.invalidate(examsListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam created successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create exam: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('New Exam'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: 'Exam Title',
                  hint: 'e.g. Mid Term',
                  controller: _titleController,
                  validator: (v) => v == null || v.isEmpty ? 'Title required' : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  label: 'Exam Type',
                  hint: 'e.g. midterm, final, unit_test',
                  controller: _typeController,
                  validator: (v) => v == null || v.isEmpty ? 'Type required' : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  label: 'Academic Year ID',
                  hint: 'Enter academic year ID',
                  controller: _academicYearIdController,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  label: 'Class ID',
                  hint: 'Enter class ID',
                  controller: _classIdController,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  label: 'Exam Date',
                  hint: 'YYYY-MM-DD',
                  controller: _examDateController,
                  validator: (v) => v == null || v.isEmpty ? 'Date required' : null,
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Total Marks',
                        controller: _totalMarksController,
                        keyboardType: TextInputType.number, hint: 'marks',
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomTextField(
                        label: 'Passing Marks',
                        controller: _passingMarksController,
                        keyboardType: TextInputType.number, hint: 'marks',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  text: 'Create Exam',
                  isLoading: _isLoading,
                  onPressed: _submitForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
