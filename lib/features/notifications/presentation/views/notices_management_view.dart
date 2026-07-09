import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/models/notice_model.dart';
import 'package:ascento_abacus/features/notifications/presentation/providers/notices_provider.dart';
import 'package:ascento_abacus/shared/widgets/premium_data_table.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';

class NoticesManagementView extends ConsumerWidget {
  const NoticesManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final noticesAsync = ref.watch(noticesListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
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
              PremiumDataTable<NoticeModel>(
                title: 'Notices & Announcements',
                subtitle: 'Manage school-wide notices, banners, and push notifications.',
                isLoading: noticesAsync.isLoading,
                data: noticesAsync.valueOrNull ?? [],
                columns: const ['Notice', 'Type', 'Date Posted', 'Actions'],
                rowBuilder: (notice) => [
                  // Notice Title & Body
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: notice.bannerUrl != null ? EdgeInsets.zero : EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkPrimary : AppColors.primary).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: notice.bannerUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.network(notice.bannerUrl!, width: 36.w, height: 36.w, fit: BoxFit.cover),
                              )
                            : Icon(_getTypeIcon(notice.type), color: isDark ? AppColors.darkPrimary : AppColors.primary, size: 16.sp),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            notice.title,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                          ),
                          SizedBox(
                            width: 250.w,
                            child: Text(
                            notice.content,
                              style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Type Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.darkSurfaceDarker : AppColors.surfaceDarker),
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                    child: Text(
                      notice.type.toUpperCase(),
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Date
                  Text(notice.createdAt != null ? notice.createdAt!.toIso8601String().split('T')[0] : 'N/A'),
                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: AppColors.info,
                        onPressed: () {
                          context.push(RoutePaths.editNotice, extra: notice);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AppColors.error,
                        onPressed: () => _showDeleteDialog(context, notice, ref),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
