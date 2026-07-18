import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/shared/models/notice_model.dart';
import 'package:ascento_abacus/features/notifications/presentation/providers/notices_provider.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';

class NoticesManagementView extends ConsumerWidget {
  final bool isReadOnly;

  const NoticesManagementView({super.key, this.isReadOnly = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final noticesAsync = ref.watch(noticesListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: isReadOnly ? null : FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          context.push(RoutePaths.addNotice);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Notice', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Notices & Announcements',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              SizedBox(height: 8.h),
              Text(
                'Manage school-wide notices, banners, and push notifications.',
                style: TextStyle(fontSize: 14.sp, color: AppColors.textMuted),
              ),
              SizedBox(height: 24.h),
              if (noticesAsync.isLoading)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (context, index) => SizedBox(height: 24.h),
                  itemBuilder: (context, index) => SizedBox(
                    height: 250.h,
                    child: AppShimmer.card(),
                  ),
                )
              else if (noticesAsync.hasError)
                Center(child: Text('Error: ${noticesAsync.error}'))
              else if (noticesAsync.valueOrNull == null || noticesAsync.valueOrNull!.isEmpty)
                Center(child: Text('No notices found', style: TextStyle(color: AppColors.textMuted)))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: noticesAsync.value!.length,
                  separatorBuilder: (context, index) => SizedBox(height: 24.h),
                  itemBuilder: (context, index) {
                    final notice = noticesAsync.value![index];
                    return _buildNoticePosterCard(context, notice, isDark, ref);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoticePosterCard(BuildContext context, NoticeModel notice, bool isDark, WidgetRef ref) {
    return InkWell(
      onTap: () => context.push(RoutePaths.adminNoticeDetails, extra: notice),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner or Default Graphic
          SizedBox(
            height: 180.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (notice.bannerUrl != null && notice.bannerUrl!.isNotEmpty)
                  Image.network(
                    notice.bannerUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderGraphic(notice, isDark),
                  )
                else
                  _buildPlaceholderGraphic(notice, isDark),
                
                // Overlay Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                
                // Type Badge
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      notice.type.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Date & Actions (Edit/Delete) overlay
                if (!isReadOnly)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                          onPressed: () => context.push(RoutePaths.editNotice, extra: notice),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                          onPressed: () => _showDeleteDialog(context, notice, ref),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    notice.content,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      fontSize: 14.sp,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14.sp, color: AppColors.textMuted),
                      SizedBox(width: 6.w),
                      Text(
                        notice.createdAt != null ? notice.createdAt!.toIso8601String().split('T')[0] : 'Just now',
                        style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
      )
    );
  }

  // Dialog implementation removed in favor of AdminNoticeDetailsView

  Widget _buildPlaceholderGraphic(NoticeModel notice, bool isDark) {
    return Container(
      color: _getTypeColor(notice.type).withValues(alpha: 0.2),
      child: Center(
        child: Icon(
          _getTypeIcon(notice.type),
          size: 64.sp,
          color: _getTypeColor(notice.type),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'general': return Colors.blue;
      case 'academic': return Colors.green;
      case 'fees': return Colors.orange;
      case 'event': return Colors.purple;
      case 'update': return Colors.teal;
      case 'alert': return Colors.red;
      default: return AppColors.primary;
    }
  }

  void _showDeleteDialog(BuildContext context, NoticeModel notice, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Notice'),
        content: Text('Are you sure you want to delete "${notice.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(noticesListProvider.notifier).deleteNotice(notice.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notice deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete notice'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'general': return Icons.notifications_rounded;
      case 'academic': return Icons.school_rounded;
      case 'fees': return Icons.attach_money_rounded;
      case 'event': return Icons.event_rounded;
      case 'update': return Icons.update_rounded;
      case 'alert': return Icons.warning_rounded;
      default: return Icons.campaign_rounded;
    }
  }
}
