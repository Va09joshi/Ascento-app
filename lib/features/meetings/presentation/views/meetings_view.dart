import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ascento_abacus/features/meetings/presentation/providers/meetings_provider.dart';
import 'package:ascento_abacus/features/meetings/data/repositories/meetings_repository.dart';
import 'package:ascento_abacus/features/academics/presentation/providers/academics_provider.dart';
import 'package:ascento_abacus/shared/providers/feature_providers.dart';

class MeetingsView extends ConsumerStatefulWidget {
  const MeetingsView({super.key});

  @override
  ConsumerState<MeetingsView> createState() => _MeetingsViewState();
}

class _MeetingsViewState extends ConsumerState<MeetingsView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final meetingsAsync = ref.watch(meetingsListProvider);
    final currentUser = ref.watch(authControllerProvider).currentUser;
    final profile = ref.watch(studentProfileProvider).valueOrNull;
    final canManage = currentUser?.role == UserRole.admin ||
        currentUser?.role == UserRole.superAdmin ||
        currentUser?.role == UserRole.teacher;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Meetings',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22.sp,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Schedule and manage sessions.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: meetingsAsync.when(
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
                  if (currentUser?.role == UserRole.student) {
                    items = items.where((m) {
                      if (m.classId == null) return true;
                      if (m.classId != profile?.classId) return false;
                      if (m.sectionId != null && m.sectionId != profile?.sectionId) return false;
                      return true;
                    }).toList();
                  }

                  if (items.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'No Active Meetings',
                      subtitle: 'There are no upcoming meetings for your classes.',
                      icon: Icons.video_camera_front_rounded,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.refresh(meetingsListProvider),
                    child: ListView.separated(
                      padding: EdgeInsets.all(20.w),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => SizedBox(height: 16.h),
                      itemBuilder: (context, index) => _MeetingTile(
                        item: items[index],
                        canManage: canManage,
                        onEdit: () => _showMeetingDialog(context, ref, meeting: items[index]),
                        onDelete: () => _confirmDelete(context, ref, items[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _showMeetingDialog(context, ref),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  void _showMeetingDialog(BuildContext context, WidgetRef ref, {MeetingItem? meeting}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _MeetingFormDialog(meeting: meeting),
    ).then((result) {
      if (result == true) {
        ref.invalidate(meetingsListProvider);
      }
    });
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, MeetingItem meeting) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24.r),
            SizedBox(width: 8.w),
            const Text('Delete Meeting'),
          ],
        ),
        content: Text('Are you sure you want to cancel "${meeting.title}"? This action cannot be undone.'),
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
                await ref.read(meetingsRepositoryProvider).deleteMeeting(meeting.id);
                ref.invalidate(meetingsListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meeting cancelled successfully'), backgroundColor: AppColors.success),
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
            child: const Text('Cancel Meeting'),
          ),
        ],
      ),
    );
  }
}

// ── Meeting Form Dialog ──
class _MeetingFormDialog extends ConsumerStatefulWidget {
  final MeetingItem? meeting;
  const _MeetingFormDialog({this.meeting});

  @override
  ConsumerState<_MeetingFormDialog> createState() => _MeetingFormDialogState();
}

class _MeetingFormDialogState extends ConsumerState<_MeetingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  bool _isAllStudents = true;
  String? _selectedClassId;
  String? _selectedSectionId;

  bool get _isEdit => widget.meeting != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final m = widget.meeting!;
      _titleController.text = m.title;
      _linkController.text = m.meetLink;
      _selectedDate = m.meetDate;
      _startTimeController.text = m.startTime;
      _endTimeController.text = m.endTime;
      _selectedClassId = m.classId;
      _selectedSectionId = m.sectionId;
      if (m.classId != null) {
        _isAllStudents = false;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a meeting date')),
      );
      return;
    }
    
    if (!_isAllStudents && _selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(meetingsRepositoryProvider);
      final data = {
        'title': _titleController.text.trim(),
        'meet_link': _linkController.text.trim(),
        'meet_date': _selectedDate!.toIso8601String().split('T')[0],
        'start_time': _startTimeController.text.trim(),
        'end_time': _endTimeController.text.trim(),
        'class_id': _isAllStudents ? null : _selectedClassId,
        'section_id': _isAllStudents ? null : _selectedSectionId,
      };

      if (_isEdit) {
        await repo.updateMeeting(widget.meeting!.id, data);
      } else {
        await repo.createMeeting(data);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Meeting updated successfully' : 'Meeting scheduled successfully'),
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

  Future<void> _pickTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      controller.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
        constraints: BoxConstraints(maxWidth: 480.w),
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
                          color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(Icons.video_camera_front_rounded, color: const Color(0xFFE74C3C), size: 28.r),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          _isEdit ? 'Edit Meeting' : 'Schedule Meeting',
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
                    label: 'Meeting Title',
                    hint: 'e.g. Class 5 - Abacus Review',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                  ),
                  SizedBox(height: 16.h),

                  CustomTextField(
                    controller: _linkController,
                    label: 'Meeting Link',
                    hint: 'https://meet.google.com/...',
                    keyboardType: TextInputType.url,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Link is required' : null,
                  ),
                  SizedBox(height: 20.h),

                  // Target Audience
                  SwitchListTile(
                    title: const Text('For All Students'),
                    subtitle: const Text('Schedule meeting for everyone'),
                    value: _isAllStudents,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        _isAllStudents = val;
                        if (val) {
                          _selectedClassId = null;
                          _selectedSectionId = null;
                        }
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (!_isAllStudents) ...[
                    SizedBox(height: 12.h),
                    Consumer(builder: (context, ref, _) {
                      final classesAsync = ref.watch(classesListProvider);
                      return classesAsync.when(
                        data: (classes) => DropdownButtonFormField<String>(
                          value: _selectedClassId,
                          decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
                          items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedClassId = val;
                              _selectedSectionId = null;
                            });
                          },
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('Error loading classes'),
                      );
                    }),
                    SizedBox(height: 12.h),
                    if (_selectedClassId != null)
                      Consumer(builder: (context, ref, _) {
                        final sectionsAsync = ref.watch(sectionsListProvider);
                        return sectionsAsync.when(
                          data: (sections) {
                            final classSections = sections.where((s) => s.classId == _selectedClassId).toList();
                            return DropdownButtonFormField<String>(
                              value: _selectedSectionId,
                              decoration: const InputDecoration(labelText: 'Section (Optional)', border: OutlineInputBorder()),
                              items: classSections.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                              onChanged: (val) => setState(() => _selectedSectionId = val),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      }),
                  ],
                  SizedBox(height: 20.h),

                  // Date & Time using standard inputs
                  CustomTextField(
                    label: 'Meeting Date',
                    hint: 'Select date',
                    readOnly: true,
                    suffixIcon: Icons.calendar_month_rounded,
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                          : '',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _startTimeController,
                          label: 'Start Time',
                          hint: 'HH:MM',
                          readOnly: true,
                          suffixIcon: Icons.access_time_rounded,
                          onTap: () => _pickTime(_startTimeController),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: CustomTextField(
                          controller: _endTimeController,
                          label: 'End Time',
                          hint: 'HH:MM',
                          readOnly: true,
                          suffixIcon: Icons.access_time_filled_rounded,
                          onTap: () => _pickTime(_endTimeController),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ],
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
                        text: _isEdit ? 'Save Changes' : 'Schedule',
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

// ── Meeting Tile ──
class _MeetingTile extends StatelessWidget {
  final MeetingItem item;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MeetingTile({
    required this.item,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  bool _checkIfLive(MeetingItem item) {
    final now = DateTime.now();
    if (now.year == item.meetDate.year && now.month == item.meetDate.month && now.day == item.meetDate.day) {
      try {
        final startParts = item.startTime.split(':');
        final endParts = item.endTime.split(':');
        if (startParts.length >= 2 && endParts.length >= 2) {
          final startH = int.parse(startParts[0]);
          final startM = int.parse(startParts[1]);
          final endH = int.parse(endParts[0]);
          final endM = int.parse(endParts[1]);
          
          final start = DateTime(now.year, now.month, now.day, startH, startM);
          final end = DateTime(now.year, now.month, now.day, endH, endM);
          
          // Consider live 5 minutes before start, up to the end time
          return now.isAfter(start.subtract(const Duration(minutes: 5))) && now.isBefore(end);
        }
      } catch (_) {}
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Real calculation based on date and time
    final isLiveNow = _checkIfLive(item);
    
    final accentColor = isLiveNow ? const Color(0xFFEF4444) : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Minimal Date Box
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.meetDate.day.toString().padLeft(2, '0'),
                        style: TextStyle(color: accentColor, fontSize: 18.sp, fontWeight: FontWeight.bold, height: 1),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _getMonth(item.meetDate.month),
                        style: TextStyle(color: accentColor, fontSize: 10.sp, fontWeight: FontWeight.w600, letterSpacing: 1, height: 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                // Main Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp, color: isDark ? Colors.white : AppColors.textPrimary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (isLiveNow) ...[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text('LIVE NOW', style: TextStyle(color: const Color(0xFFEF4444), fontSize: 9.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            ),
                            SizedBox(width: 8.w),
                          ] else ...[
                            Text(
                              'UPCOMING',
                              style: TextStyle(color: AppColors.primary, fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                            SizedBox(width: 8.w),
                          ],
                          Text(
                            '• ${item.startTime} - ${item.endTime}',
                            style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted, fontSize: 12.sp),
                          ),
                        ],
                      ),
                      if (item.className != null) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(Icons.class_rounded, size: 14.sp, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                            SizedBox(width: 6.w),
                            Text(
                              '${item.className}${item.sectionName != null ? ' - ${item.sectionName}' : ''}',
                              style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted, fontSize: 13.sp),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (canManage) ...[
                  SizedBox(width: 8.w),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz_rounded, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
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
                            const Text('Cancel Meeting', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Action Area
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (item.meetLink.isNotEmpty) {
                      final uri = Uri.tryParse(item.meetLink);
                      if (uri != null && await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not launch meeting link'), backgroundColor: AppColors.error),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLiveNow ? const Color(0xFFEF4444) : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white),
                    foregroundColor: isLiveNow ? Colors.white : (isDark ? Colors.white : AppColors.primary),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(
                        color: isLiveNow ? Colors.transparent : (isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.05)),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLiveNow ? 'Join Live Session' : 'View Link',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
                      ),
                      if (isLiveNow) ...[
                        SizedBox(width: 6.w),
                        Icon(Icons.video_call_rounded, size: 18.r),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }
}
