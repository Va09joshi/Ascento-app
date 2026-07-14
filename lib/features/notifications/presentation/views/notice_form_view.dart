import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/models/notice_model.dart';
import 'package:ascento_abacus/features/notifications/presentation/providers/notices_provider.dart';
import 'package:ascento_abacus/core/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class NoticeFormView extends ConsumerStatefulWidget {
  final NoticeModel? notice;

  const NoticeFormView({super.key, this.notice});

  @override
  ConsumerState<NoticeFormView> createState() => _NoticeFormViewState();
}

class _NoticeFormViewState extends ConsumerState<NoticeFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String _selectedType = 'news';
  bool _isPublished = true;
  bool _isLoading = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _types = ['event', 'news', 'update', 'alert'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.notice?.title ?? '');
    _contentController = TextEditingController(text: widget.notice?.content ?? '');
    if (widget.notice != null) {
      _selectedType = widget.notice!.type;
      _isPublished = widget.notice!.isPublished;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final currentUser = ref.read(storageServiceProvider).getCurrentUser();
    
    dynamic data;
    
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      data = FormData.fromMap({
        'title': _titleController.text,
        'content': _contentController.text,
        'type': _selectedType,
        'is_published': _isPublished,
        if (currentUser != null) 'created_by': currentUser.id,
        'image': MultipartFile.fromBytes(bytes, filename: _selectedImage!.name),
      });
    } else {
      data = {
        'title': _titleController.text,
        'content': _contentController.text,
        'type': _selectedType,
        'is_published': _isPublished,
        if (currentUser != null) 'created_by': currentUser.id,
      };
    }

    try {
      if (widget.notice == null) {
        await ref.read(noticesListProvider.notifier).createNotice(data);
      } else {
        await ref.read(noticesListProvider.notifier).updateNotice(widget.notice!.id, data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.notice == null ? 'Notice created successfully' : 'Notice updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage), 
            backgroundColor: AppColors.error, 
            duration: const Duration(seconds: 4)
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.notice == null ? 'Create Notice' : 'Edit Notice'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLabel('Notice Title', theme),
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration('Enter title', isDark),
                  validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                ),
                SizedBox(height: 20.h),
                
                _buildLabel('Notice Type', theme),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: _inputDecoration('', isDark),
                  items: _types.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                SizedBox(height: 20.h),
                
                _buildLabel('Notice Content', theme),
                TextFormField(
                  controller: _contentController,
                  maxLines: 6,
                  decoration: _inputDecoration('Enter notice details...', isDark),
                  validator: (value) => value == null || value.isEmpty ? 'Content is required' : null,
                ),
                SizedBox(height: 20.h),
                
                _buildLabel('Banner Image (Optional)', theme),
                GestureDetector(
                  onTap: () async {
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() => _selectedImage = image);
                    }
                  },
                  child: Container(
                    height: 150.h,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: kIsWeb 
                                ? Image.network(_selectedImage!.path, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => const Icon(Icons.image))
                                : Image.file(File(_selectedImage!.path), fit: BoxFit.cover, errorBuilder: (ctx, err, st) => const Icon(Icons.image)),
                          )
                        : (widget.notice?.bannerUrl != null && widget.notice!.bannerUrl!.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.network(widget.notice!.bannerUrl!, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => const Icon(Icons.broken_image)),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 48.r, color: Colors.grey),
                                  SizedBox(height: 8.h),
                                  Text('Tap to upload a banner image', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                                ],
                              ),
                  ),
                ),
                SizedBox(height: 20.h),
                
                SwitchListTile(
                  title: Text(
                    'Publish Notice',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: const Text('If turned off, this notice will be saved as a draft.'),
                  value: _isPublished,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isPublished = val),
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(height: 32.h),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(height: 20.w, width: 20.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          widget.notice == null ? 'Create Notice' : 'Update Notice',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    );
  }
}
