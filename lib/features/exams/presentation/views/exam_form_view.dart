import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/features/exams/data/repositories/exams_repository.dart';
import 'package:ascento_abacus/features/exams/presentation/providers/exams_provider.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';

class ExamFormView extends ConsumerStatefulWidget {
  final ExamSchedule? examToEdit;
  const ExamFormView({super.key, this.examToEdit});

  @override
  ConsumerState<ExamFormView> createState() => _ExamFormViewState();
}

class _ExamFormViewState extends ConsumerState<ExamFormView> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _totalMarksController = TextEditingController(text: '100');
  final _passingMarksController = TextEditingController(text: '40');
  
  String? _selectedAcademicYearId;
  String? _selectedClassId;
  String? _selectedExamType;
  DateTime? _selectedDate;

  final _examTypes = ['midterm', 'final', 'unit_test'];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.examToEdit != null) {
      final exam = widget.examToEdit!;
      _titleController.text = exam.examName;
      _totalMarksController.text = exam.totalMarks.toString();
      _passingMarksController.text = '40'; // Fallback as we don't have passing marks in ExamSchedule model immediately available
      _selectedAcademicYearId = exam.academicYearId;
      _selectedClassId = exam.classId;
      _selectedDate = exam.date;
      _selectedExamType = _examTypes.contains(exam.type) ? exam.type : _examTypes.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _totalMarksController.dispose();
    _passingMarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAcademicYearId == null || _selectedClassId == null || _selectedExamType == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payload = {
        "title": _titleController.text.trim(),
        "type": _selectedExamType,
        "academic_year_id": _selectedAcademicYearId,
        "class_id": _selectedClassId,
        "exam_date": _selectedDate!.toIso8601String().split('T').first,
        "total_marks": int.tryParse(_totalMarksController.text.trim()) ?? 100,
        "passing_marks": int.tryParse(_passingMarksController.text.trim()) ?? 40,
      };

      if (widget.examToEdit != null) {
        await ref.read(examsRepositoryProvider).updateExam(widget.examToEdit!.id, payload);
      } else {
        await ref.read(examsRepositoryProvider).createExam(payload);
      }
      ref.invalidate(examsListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.examToEdit != null ? 'Exam updated successfully' : 'Exam created successfully')),
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
        title: Text(widget.examToEdit != null ? 'Edit Exam' : 'New Exam'),
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

                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Exam Type',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  initialValue: _selectedExamType,
                  items: _examTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setState(() => _selectedExamType = val),
                  validator: (val) => val == null ? 'Required' : null,
                ),
                SizedBox(height: 16.h),

                ref.watch(academicYearsListProvider).when(
                  data: (years) => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Academic Year',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    initialValue: _selectedAcademicYearId,
                    items: years.map((y) => DropdownMenuItem(value: y.id, child: Text(y.name))).toList(),
                    onChanged: (val) => setState(() => _selectedAcademicYearId = val),
                    validator: (val) => val == null ? 'Required' : null,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Error loading academic years: $e'),
                ),
                SizedBox(height: 16.h),

                ref.watch(classesListProvider).when(
                  data: (classes) => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Class',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    initialValue: _selectedClassId,
                    items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() => _selectedClassId = val),
                    validator: (val) => val == null ? 'Required' : null,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Error loading classes: $e'),
                ),
                SizedBox(height: 16.h),

                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Exam Date',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(_selectedDate == null ? 'YYYY-MM-DD' : _selectedDate!.toIso8601String().split('T').first),
                  ),
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
                  text: widget.examToEdit != null ? 'Update Exam' : 'Create Exam',
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
