import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ascento_abacus/features/homework/presentation/providers/homework_provider.dart';
import 'package:ascento_abacus/features/homework/data/repositories/homework_repository.dart';
import 'package:ascento_abacus/features/content/data/repositories/content_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeworkStudentView extends ConsumerStatefulWidget {
  const HomeworkStudentView({super.key});

  @override
  ConsumerState<HomeworkStudentView> createState() => _HomeworkStudentViewState();
}

class _HomeworkStudentViewState extends ConsumerState<HomeworkStudentView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hwAsync = ref.watch(homeworkListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Homework'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: hwAsync.when(
        loading: () => ListView(
          padding: EdgeInsets.all(24.w),
          children: List.generate(4, (_) => AppShimmer.card()),
        ),
        error: (e, _) => EmptyStateWidget(
          title: 'Load failed',
          subtitle: e.toString(),
          icon: Icons.error_outline,
        ),
        data: (items) {
          final now = DateTime.now();
          final visibleItems = items.where((item) {
            // Remove from UI if pending and overdue by more than 7 days
            if (item.status == HomeworkStatus.pending && item.dueDate.isBefore(now.subtract(const Duration(days: 7)))) {
              return false;
            }
            return true;
          }).toList();

          if (visibleItems.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Homework',
              subtitle: 'All caught up!',
              icon: Icons.check_circle_outline,
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(20.w),
            itemCount: visibleItems.length,
            separatorBuilder: (_, __) => SizedBox(height: 16.h),
            itemBuilder: (context, index) => _HomeworkStudentTile(item: visibleItems[index]),
          );
        },
      ),
    );
    );
  }
}

class _HomeworkSubmissionSheet extends StatefulWidget {
  final HomeworkItem item;
  final Future<void> Function(PlatformFile) onSubmit;

  const _HomeworkSubmissionSheet({required this.item, required this.onSubmit});

  @override
  State<_HomeworkSubmissionSheet> createState() => _HomeworkSubmissionSheetState();
}

class _HomeworkSubmissionSheetState extends State<_HomeworkSubmissionSheet> {
  PlatformFile? _selectedFile;
  bool _isSubmitting = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 12.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          
          Text(
            'Submit Homework',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.item.title,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white70 : AppColors.textMuted,
            ),
          ),
          SizedBox(height: 32.h),

          // File Picker Area
          GestureDetector(
            onTap: _isSubmitting ? null : _pickFile,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.black12 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: _selectedFile != null ? AppColors.primary : (isDark ? AppColors.darkBorder : Colors.grey.shade300),
                  width: _selectedFile != null ? 2 : 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _selectedFile != null ? Icons.description_rounded : Icons.cloud_upload_rounded,
                    size: 48.r,
                    color: _selectedFile != null ? AppColors.primary : Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  if (_selectedFile != null) ...[
                    Text(
                      _selectedFile!.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Tap to change file',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Tap to browse files',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Supported formats: PDF, JPG, PNG',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          SizedBox(height: 32.h),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedFile == null || _isSubmitting)
                  ? null
                  : () async {
                      setState(() => _isSubmitting = true);
                      await widget.onSubmit(_selectedFile!);
                      if (context.mounted) Navigator.of(context).pop();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Submit Assignment',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
class _HomeworkStudentTile extends ConsumerStatefulWidget {
  final HomeworkItem item;
  const _HomeworkStudentTile({required this.item});

  @override
  ConsumerState<_HomeworkStudentTile> createState() => _HomeworkStudentTileState();
}

class _HomeworkStudentTileState extends ConsumerState<_HomeworkStudentTile> {
  bool _isUploading = false;

  Future<void> _openSubmissionSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _HomeworkSubmissionSheet(
        item: widget.item,
        onSubmit: (file) async {
          setState(() => _isUploading = true);
          try {
            // Upload to storage
            final fileUrl = await ref.read(contentRepositoryProvider).uploadDocument(file.path!);
            // Submit homework
            await ref.read(homeworkRepositoryProvider).submitHomework(widget.item.id, fileUrl);
            ref.invalidate(homeworkListProvider);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Homework submitted successfully!'), backgroundColor: AppColors.success),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Submission failed: $e'), backgroundColor: AppColors.error),
              );
            }
          } finally {
            if (mounted) setState(() => _isUploading = false);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.item.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
          SizedBox(height: 4.h),
          Text(widget.item.description, style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp)),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Due: ${widget.item.dueDate.toIso8601String().split('T')[0]}', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: widget.item.status == HomeworkStatus.submitted 
                      ? AppColors.success.withValues(alpha: 0.1) 
                      : (widget.item.status == HomeworkStatus.graded ? Colors.blue.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  widget.item.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.sp, 
                    fontWeight: FontWeight.bold,
                    color: widget.item.status == HomeworkStatus.submitted 
                        ? AppColors.success 
                        : (widget.item.status == HomeworkStatus.graded ? Colors.blue : AppColors.warning),
                  ),
                ),
              ),
            ],
          ),
          
          if (widget.item.attachmentUrl != null && widget.item.attachmentUrl!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.attach_file_rounded, color: AppColors.primary, size: 24.r),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reference Material', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                          SizedBox(height: 2.h),
                          Text('View attachment', style: TextStyle(color: AppColors.primary, fontSize: 12.sp)),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final url = Uri.parse(widget.item.attachmentUrl!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      icon: Icon(Icons.open_in_new_rounded, size: 18.r),
                      label: const Text('Open'),
                    ),
                  ],
                ),
              ),
            ),
            
          SizedBox(height: 16.h),
          if (widget.item.status == HomeworkStatus.pending && widget.item.submissionUrl == null)
            SizedBox(
              width: double.infinity,
              child: _isUploading
                  ? AppShimmer(width: double.infinity, height: 48.h, borderRadius: 12.r)
                  : CustomButton(
                      text: 'Submit Homework',
                      onPressed: _openSubmissionSheet,
                    ),
            ),
          if (widget.item.submissionUrl != null)
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.description_rounded, color: Colors.blue, size: 24.r),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Submission', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                        SizedBox(height: 2.h),
                        Text('Successfully uploaded', style: TextStyle(color: Colors.blue, fontSize: 12.sp)),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(widget.item.submissionUrl!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    icon: Icon(Icons.remove_red_eye_rounded, size: 18.r),
                    label: const Text('View'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
