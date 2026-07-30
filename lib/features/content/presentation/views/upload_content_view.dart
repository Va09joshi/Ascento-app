import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/content/data/repositories/content_repository.dart';
import 'package:ascento_abacus/features/content/presentation/providers/content_provider.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/features/users/presentation/providers/teachers_provider.dart';
class UploadContentView extends ConsumerStatefulWidget {
  final ContentItem? content;
  const UploadContentView({super.key, this.content});

  @override
  ConsumerState<UploadContentView> createState() => _UploadContentViewState();
}

class _UploadContentViewState extends ConsumerState<UploadContentView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  String _selectedType = 'pdf';
  bool _isLoading = false;
  String? _selectedFilePath;
  String? _selectedFileName;
  String? _selectedClassId;
  String? _selectedSectionId;

  bool get _isEdit => widget.content != null;

  static const _contentTypes = [
    {'value': 'pdf', 'label': 'PDF Document', 'icon': Icons.picture_as_pdf_rounded},
    {'value': 'video', 'label': 'Video Link', 'icon': Icons.video_library_rounded},
    {'value': 'image', 'label': 'Image', 'icon': Icons.image_rounded},
    {'value': 'quiz', 'label': 'Quiz Link', 'icon': Icons.quiz_rounded},
    {'value': 'worksheet', 'label': 'Worksheet', 'icon': Icons.assignment_rounded},
  ];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final c = widget.content!;
      _titleController.text = c.title;
      _descriptionController.text = c.description;
      _urlController.text = c.publicUrl;
      _selectedType = c.type;
      _selectedClassId = c.classId;
      _selectedSectionId = c.sectionId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final status = await Permission.storage.request();
      final photosStatus = await Permission.photos.request();
      
      if (status.isPermanentlyDenied || photosStatus.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Storage permission is required to upload files.'),
              action: SnackBarAction(label: 'Settings', onPressed: () => openAppSettings()),
            ),
          );
        }
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
          if (_selectedFileName!.toLowerCase().endsWith('.pdf')) {
            _selectedType = 'pdf';
          } else if (_selectedFileName!.toLowerCase().endsWith('.jpg') || _selectedFileName!.toLowerCase().endsWith('.png') || _selectedFileName!.toLowerCase().endsWith('.jpeg')) {
            _selectedType = 'image';
          }
          _urlController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_urlController.text.isEmpty && _selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a file or a link.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(contentRepositoryProvider);
      String storageUrl = _urlController.text.trim();

      if (_selectedFilePath != null) {
        storageUrl = await repo.uploadDocument(_selectedFilePath!);
      }

      final data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _selectedType,
        'storage_path': storageUrl,
        'public_url': storageUrl,
        if (_selectedClassId != null) 'class_id': _selectedClassId,
        if (_selectedSectionId != null) 'section_id': _selectedSectionId,
      };

      if (_isEdit) {
        await repo.updateContent(widget.content!.id, data);
      } else {
        await repo.createContent(data);
      }

      if (mounted) {
        ref.invalidate(contentListProvider);
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Material updated successfully' : 'Material uploaded successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
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

    final authState = ref.watch(authControllerProvider);
    final user = authState.currentUser;
    final isTeacher = user?.role == UserRole.teacher;
    final isAdmin = user?.role == UserRole.admin || user?.role == UserRole.superAdmin;
    final classesAsync = ref.watch(classesListProvider);
    final sectionsAsync = ref.watch(sectionsListProvider);
    
    List<DropdownMenuItem<String>> classDropdownItems = [];
    List<DropdownMenuItem<String>> sectionDropdownItems = [];
    
    if (isTeacher) {
      final myStudentsAsync = ref.watch(myStudentsProvider);
      final mySections = myStudentsAsync.valueOrNull ?? [];

      final uniqueClasses = <String, Map<String, String>>{};
      for (var s in mySections) {
        if (s['class_id'] != null && s['class_name'] != null) {
          uniqueClasses[s['class_id']] = {
            'id': s['class_id'].toString(),
            'name': s['class_name'].toString(),
          };
        }
      }
      final teacherClasses = uniqueClasses.values.toList();

      classDropdownItems = teacherClasses.map((c) => DropdownMenuItem(value: c['id'], child: Text(c['name']!))).toList();
      sectionDropdownItems = mySections
          .where((s) => s['class_id'] == _selectedClassId)
          .map((s) => DropdownMenuItem(
                value: s['section_id']?.toString(), 
                child: Text(s['section_name']?.toString() ?? '')
              ))
          .toList();
    } else if (isAdmin) {
      classDropdownItems = (classesAsync.valueOrNull ?? []).map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList();
      sectionDropdownItems = (sectionsAsync.valueOrNull ?? [])
          .where((s) => s.classId == _selectedClassId)
          .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
          .toList();
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Material' : 'Upload Material',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title and Description Card
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Basic Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(height: 16.h),
                      CustomTextField(
                        controller: _titleController,
                        label: 'Material Title',
                        hint: 'e.g. Chapter 3 - Addition Basics',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Brief description of the material...',
                        maxLines: 4,
                      ),
                      if (isTeacher || isAdmin) ...[
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: const InputDecoration(labelText: 'Target Class (Optional)'),
                                value: _selectedClassId,
                                items: [
                                  const DropdownMenuItem<String>(value: null, child: Text('All Classes')),
                                  ...classDropdownItems,
                                ],
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
                                decoration: const InputDecoration(labelText: 'Target Section (Optional)'),
                                value: _selectedSectionId,
                                items: [
                                  const DropdownMenuItem<String>(value: null, child: Text('All Sections')),
                                  ...sectionDropdownItems,
                                ],
                                onChanged: _selectedClassId == null ? null : (val) {
                                  setState(() {
                                    _selectedSectionId = val;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Material Type Card
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resource Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(height: 16.h),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Material Type'),
                        value: _selectedType,
                        items: _contentTypes.map((t) {
                          return DropdownMenuItem(
                            value: t['value'] as String,
                            child: Row(
                              children: [
                                Icon(t['icon'] as IconData, size: 20, color: AppColors.primary),
                                SizedBox(width: 12.w),
                                Text(t['label'] as String),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedType = v ?? 'pdf'),
                      ),
                      SizedBox(height: 24.h),

                      // Large Upload Zone
                      Text('Resource Link or File', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(height: 12.h),
                      if (_selectedFileName != null)
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.insert_drive_file_rounded, color: AppColors.primary, size: 32.r),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedFileName!,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text('Ready to upload', style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: AppColors.error),
                                onPressed: () => setState(() {
                                  _selectedFilePath = null;
                                  _selectedFileName = null;
                                }),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBackground : AppColors.background,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomTextField(
                                controller: _urlController,
                                label: 'External URL (YouTube, Drive, etc.)',
                                hint: 'https://...',
                                keyboardType: TextInputType.url,
                              ),
                              SizedBox(height: 20.h),
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                                    child: Text('OR', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              InkWell(
                                onTap: _pickFile,
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 32.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), style: BorderStyle.solid),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.cloud_upload_rounded, size: 48.r, color: AppColors.primary),
                                      SizedBox(height: 16.h),
                                      Text('Click to Browse Local Files', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14.sp)),
                                      SizedBox(height: 4.h),
                                      Text('PDF, DOC, JPG, PNG (Max 10MB)', style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                // Submit Button
                CustomButton(
                  text: _isEdit ? 'Save Changes' : 'Upload Material',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
