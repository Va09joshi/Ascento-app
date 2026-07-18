import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ascento_abacus/features/content/presentation/providers/content_provider.dart';
import 'package:ascento_abacus/features/content/data/repositories/content_repository.dart';

class ContentView extends ConsumerStatefulWidget {
  const ContentView({super.key});

  @override
  ConsumerState<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends ConsumerState<ContentView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final contentAsync = ref.watch(contentListProvider);
    final currentUser = ref.watch(authControllerProvider).currentUser;
    final canManage = currentUser?.role == UserRole.admin ||
        currentUser?.role == UserRole.superAdmin ||
        currentUser?.role == UserRole.teacher;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Study Materials', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (canManage)
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: ElevatedButton.icon(
                onPressed: () => _showContentDialog(context, ref),
                icon: const Icon(Icons.upload_file_rounded, size: 20),
                label: const Text('Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
              ),
            ),
        ],
      ),
      body: contentAsync.when(
        loading: () => ListView.separated(
          padding: EdgeInsets.all(24.w),
          itemCount: 4,
          separatorBuilder: (_, __) => SizedBox(height: 16.h),
          itemBuilder: (_, __) => AppShimmer.card(),
        ),
        error: (e, _) => EmptyStateWidget(
          title: 'Load failed',
          subtitle: e.toString(),
          icon: Icons.error_outline,
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Materials Found',
              subtitle: 'Study materials and resources will appear here.',
              icon: Icons.auto_stories_rounded,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(contentListProvider),
            child: ListView.separated(
              padding: EdgeInsets.all(20.w),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 16.h),
              itemBuilder: (context, index) => _ContentTile(
                item: items[index],
                canManage: canManage,
                onEdit: () => _showContentDialog(context, ref, content: items[index]),
                onDelete: () => _confirmDelete(context, ref, items[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showContentDialog(BuildContext context, WidgetRef ref, {ContentItem? content}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ContentFormDialog(content: content),
    ).then((result) {
      if (result == true) {
        ref.invalidate(contentListProvider);
      }
    });
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ContentItem content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24.r),
            SizedBox(width: 8.w),
            const Text('Delete Material'),
          ],
        ),
        content: Text('Are you sure you want to delete "${content.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(contentRepositoryProvider).deleteContent(content.id);
                ref.invalidate(contentListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Material deleted successfully'), backgroundColor: AppColors.success),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Content Form Dialog ──
class _ContentFormDialog extends ConsumerStatefulWidget {
  final ContentItem? content;
  const _ContentFormDialog({this.content});

  @override
  ConsumerState<_ContentFormDialog> createState() => _ContentFormDialogState();
}

class _ContentFormDialogState extends ConsumerState<_ContentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  String _selectedType = 'pdf';
  bool _isLoading = false;
  String? _selectedFilePath;
  String? _selectedFileName;

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
      // Request permission based on platform and version
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
          // Auto-detect type
          if (_selectedFileName!.toLowerCase().endsWith('.pdf')) {
            _selectedType = 'pdf';
          } else if (_selectedFileName!.toLowerCase().endsWith('.jpg') || _selectedFileName!.toLowerCase().endsWith('.png') || _selectedFileName!.toLowerCase().endsWith('.jpeg')) {
            _selectedType = 'image';
          }
          // Clear URL if picking a local file
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

      // If a local file is picked, upload it first
      if (_selectedFilePath != null) {
        storageUrl = await repo.uploadDocument(_selectedFilePath!);
      }

      final data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _selectedType,
        'storage_path': storageUrl,
        'public_url': storageUrl,
      };

      if (_isEdit) {
        await repo.updateContent(widget.content!.id, data);
      } else {
        await repo.createContent(data);
      }

      if (mounted) {
        Navigator.pop(context, true);
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500.w),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(Icons.auto_stories_rounded, color: const Color(0xFF3498DB), size: 28.r),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          _isEdit ? 'Edit Material' : 'Upload Material',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  CustomTextField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'e.g. Chapter 3 - Addition Basics',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                  ),
                  SizedBox(height: 16.h),

                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Brief description of the material...',
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.h),

                  // Type Selector
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
                  SizedBox(height: 20.h),

                  // File Picker / URL
                  Text('Resource Link or File', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : AppColors.background,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                    child: Column(
                      children: [
                        if (_selectedFileName != null) ...[
                          Row(
                            children: [
                              Icon(Icons.insert_drive_file_rounded, color: AppColors.primary, size: 24.r),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  _selectedFileName!,
                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp),
                                  overflow: TextOverflow.ellipsis,
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
                        ] else ...[
                          CustomTextField(
                            controller: _urlController,
                            label: 'External URL (YouTube, Drive, etc.)',
                            hint: 'https://...',
                            keyboardType: TextInputType.url,
                          ),
                          SizedBox(height: 16.h),
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
                          SizedBox(height: 16.h),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _pickFile,
                              icon: const Icon(Icons.upload_file_rounded),
                              label: const Text('Browse Local File'),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(width: 16.w),
                      CustomButton(
                        text: _isEdit ? 'Save Changes' : 'Upload Material',
                        isLoading: _isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Content Tile ──
class _ContentTile extends StatelessWidget {
  final ContentItem item;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContentTile({
    required this.item,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'video':
        return Icons.video_library_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'quiz':
        return Icons.quiz_rounded;
      case 'worksheet':
        return Icons.assignment_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFE74C3C);
      case 'video':
        return const Color(0xFF3498DB);
      case 'image':
        return const Color(0xFF2ECC71);
      case 'quiz':
        return const Color(0xFFE67E22);
      case 'worksheet':
        return const Color(0xFF9B59B6);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = _getColorForType(item.type);

    return InkWell(
      onTap: () async {
        if (item.publicUrl.isNotEmpty) {
          var link = item.publicUrl.trim();
          if (!link.startsWith('http://') && !link.startsWith('https://')) {
            link = 'https://$link';
          }
          final url = Uri.parse(link);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not open resource link')),
              );
            }
          }
        }
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Minimal Icon
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                _getIconForType(item.type),
                color: iconColor,
                size: 24.r,
              ),
            ),
            SizedBox(width: 16.w),
            // Main Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        item.type.toUpperCase(),
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        ' • ${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                  if (item.description.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Actions
            if (canManage)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_rounded, color: AppColors.info, size: 20),
                        SizedBox(width: 12.w),
                        const Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_rounded, color: AppColors.error, size: 20),
                        SizedBox(width: 12.w),
                        const Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              )
            else
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 24.r),
          ],
        ),
      ),
    );
  }
}
