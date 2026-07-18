import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final canManage = currentUser?.role == UserRole.admin ||
        currentUser?.role == UserRole.superAdmin ||
        currentUser?.role == UserRole.teacher;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Live Meetings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (canManage)
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: ElevatedButton.icon(
                onPressed: () => _showMeetingDialog(context, ref),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Schedule'),
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
      body: meetingsAsync.when(
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

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(meetingsRepositoryProvider);
      final data = {
        'title': _titleController.text.trim(),
        'meet_link': _linkController.text.trim(),
        'meet_date': _selectedDate!.toIso8601String().split('T')[0],
        'start_time': _startTimeController.text.trim(),
        'end_time': _endTimeController.text.trim(),
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

                  // Date Picker
                  Text('Date & Time', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
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
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) setState(() => _selectedDate = date);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Meeting Date',
                              suffixIcon: Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                              border: OutlineInputBorder(borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            child: Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                  : 'Select date',
                              style: TextStyle(
                                color: _selectedDate != null ? null : AppColors.textMuted,
                                fontWeight: _selectedDate != null ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _pickTime(_startTimeController),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Start Time',
                                    suffixIcon: Icon(Icons.access_time_rounded),
                                    border: OutlineInputBorder(borderSide: BorderSide.none),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                  ),
                                  child: Text(
                                    _startTimeController.text.isNotEmpty ? _startTimeController.text : 'HH:MM',
                                    style: TextStyle(
                                      color: _startTimeController.text.isNotEmpty ? null : AppColors.textMuted,
                                      fontWeight: _startTimeController.text.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(width: 1, height: 40, color: isDark ? AppColors.darkBorder : AppColors.border),
                            Expanded(
                              child: InkWell(
                                onTap: () => _pickTime(_endTimeController),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'End Time',
                                    suffixIcon: Icon(Icons.access_time_filled_rounded),
                                    border: OutlineInputBorder(borderSide: BorderSide.none),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                  ),
                                  child: Text(
                                    _endTimeController.text.isNotEmpty ? _endTimeController.text : 'HH:MM',
                                    style: TextStyle(
                                      color: _endTimeController.text.isNotEmpty ? null : AppColors.textMuted,
                                      fontWeight: _endTimeController.text.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primaryColor = Color(0xFFE74C3C);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: primaryColor.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            var link = item.meetLink.trim();
            if (!link.startsWith('http://') && !link.startsWith('https://')) {
              link = 'https://$link';
            }
            final url = Uri.parse(link);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open meeting link')),
                );
              }
            }
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar Date Box
                Container(
                  width: 60.r,
                  height: 60.r,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.2),
                        primaryColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.meetDate.day.toString().padLeft(2, '0'),
                        style: TextStyle(color: primaryColor, fontSize: 20.sp, fontWeight: FontWeight.w900, height: 1),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _getMonth(item.meetDate.month),
                        style: TextStyle(color: primaryColor, fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1, height: 1),
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
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17.sp, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.r,
                                  height: 6.r,
                                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                                ),
                                SizedBox(width: 4.w),
                                Text('LIVE', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 9.sp, letterSpacing: 0.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 8.h,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time_rounded, size: 14.sp, color: AppColors.textMuted),
                              SizedBox(width: 4.w),
                              Text(
                                '${item.startTime} - ${item.endTime}',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          if (item.className != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.class_rounded, size: 14.sp, color: AppColors.textMuted),
                                SizedBox(width: 4.w),
                                Text(
                                  '${item.className}${item.sectionName != null ? ' - ${item.sectionName}' : ''}',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      ElevatedButton.icon(
                        onPressed: () async {
                          var link = item.meetLink.trim();
                          if (!link.startsWith('http://') && !link.startsWith('https://')) {
                            link = 'https://$link';
                          }
                          final url = Uri.parse(link);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not open meeting link')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.videocam_rounded, size: 16),
                        label: const Text('Join Meeting', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: Size(0, 36.h),
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                      ),
                    ],
                  ),
                ),
                if (canManage)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
                    padding: EdgeInsets.zero,
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
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }
}
