import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/homework/presentation/providers/homework_provider.dart';
import 'package:ascento_abacus/features/homework/data/repositories/homework_repository.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';
import 'package:intl/intl.dart';

class HomeworkTeacherView extends ConsumerStatefulWidget {
  const HomeworkTeacherView({super.key});

  @override
  ConsumerState<HomeworkTeacherView> createState() => _HomeworkTeacherViewState();
}

class _HomeworkTeacherViewState extends ConsumerState<HomeworkTeacherView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hwAsync = ref.watch(homeworkListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Homework',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Publish and track assignments.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  FloatingActionButton.small(
                    onPressed: () => _showCreateHomeworkDialog(context, ref),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                    elevation: 0,
                  ),
                ],
              ),
            ),
            Expanded(
              child: hwAsync.when(
                loading: () => ListView(
                  padding: EdgeInsets.all(24.w),
                  children: List.generate(4, (_) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: AppShimmer(width: double.infinity, height: 120.h, borderRadius: 12.r),
                  )),
                ),
                error: (e, _) => EmptyStateWidget(
                  title: 'Load failed',
                  subtitle: e.toString(),
                  icon: Icons.error_outline,
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'No Homework Created',
                      subtitle: 'Click + to create an assignment.',
                      icon: Icons.assignment_outlined,
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 100.h),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => SizedBox(height: 16.h),
                    itemBuilder: (context, index) => _HomeworkTeacherTile(item: items[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateHomeworkDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: _CreateHomeworkDialog(),
      ),
    );
  }
}

class _CreateHomeworkDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CreateHomeworkDialog> createState() => _CreateHomeworkDialogState();
}

class _CreateHomeworkDialogState extends ConsumerState<_CreateHomeworkDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  
  String? _selectedClassId;
  String? _selectedSectionId;
  String? _selectedSubjectId;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final classesAsync = ref.watch(classesListProvider);
    final sectionsAsync = ref.watch(sectionsListProvider);
    final subjectsAsync = ref.watch(subjectsListProvider);

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text('Publish Homework', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: _inputDecoration('Title', isDark),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _descriptionController,
              decoration: _inputDecoration('Description', isDark),
              maxLines: 3,
            ),
            SizedBox(height: 16.h),
            
            // Dropdowns
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: _inputDecoration('Class', isDark),
                    value: _selectedClassId,
                    items: classesAsync.valueOrNull?.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name, overflow: TextOverflow.ellipsis),
                    )).toList() ?? [],
                    onChanged: (val) {
                      setState(() {
                        _selectedClassId = val;
                        _selectedSectionId = null;
                      });
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: _inputDecoration('Section', isDark),
                    value: _selectedSectionId,
                    items: sectionsAsync.valueOrNull
                        ?.where((s) => s.classId == _selectedClassId)
                        .map((s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name, overflow: TextOverflow.ellipsis),
                    )).toList() ?? [],
                    onChanged: (val) => setState(() => _selectedSectionId = val),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: _inputDecoration('Subject', isDark),
              value: _selectedSubjectId,
              items: subjectsAsync.valueOrNull?.map((s) => DropdownMenuItem(
                value: s.id,
                child: Text(s.name, overflow: TextOverflow.ellipsis),
              )).toList() ?? [],
              onChanged: (val) => setState(() => _selectedSubjectId = val),
            ),
            SizedBox(height: 16.h),
            
            // Date Picker
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event, color: AppColors.primary, size: 20.sp),
                    SizedBox(width: 12.w),
                    Text(
                      'Due: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
        ),
        CustomButton(
          text: 'Publish',
          isLoading: _isSubmitting,
          onPressed: () async {
            if (_titleController.text.isEmpty || _selectedSectionId == null || _selectedSubjectId == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
              return;
            }

            setState(() => _isSubmitting = true);
            try {
              await ref.read(homeworkRepositoryProvider).createHomework({
                'title': _titleController.text,
                'description': _descriptionController.text,
                'due_date': _selectedDate.toIso8601String(),
                'section_id': _selectedSectionId,
                'subject_id': _selectedSubjectId,
              });
              
              ref.invalidate(homeworkListProvider); // Refresh list
              if (mounted) Navigator.pop(context);
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
            } finally {
              if (mounted) setState(() => _isSubmitting = false);
            }
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
    );
  }
}

class _HomeworkTeacherTile extends ConsumerWidget {
  final HomeworkItem item;
  const _HomeworkTeacherTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.title, 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: isDark ? Colors.white : AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Due: ${DateFormat('MMM dd').format(item.dueDate)}', 
                  style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700, fontSize: 12.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            item.description, 
            style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.subject,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
              InkWell(
                onTap: () {
                  // View Submissions logic
                },
                borderRadius: BorderRadius.circular(6.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Row(
                    children: [
                      Icon(Icons.grading, size: 16.sp, color: isDark ? Colors.white70 : Colors.black87),
                      SizedBox(width: 4.w),
                      Text(
                        'Submissions',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp, color: isDark ? Colors.white70 : Colors.black87),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
