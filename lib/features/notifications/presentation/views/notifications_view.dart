import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/providers/feature_providers.dart';

class NotificationsView extends ConsumerWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notifAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: notifAsync.when(
        loading: () => ListView(
          padding: EdgeInsets.all(24.w),
          children: List.generate(5, (_) => AppShimmer.card()),
        ),
        error: (e, _) => EmptyStateWidget(
          title: 'Failed',
          subtitle: e.toString(),
          icon: Icons.error_outline,
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Notifications',
              subtitle: 'You\'re all caught up!',
              icon: Icons.notifications_off_outlined,
            );
          }
          final unreadCount = items.where((i) => !i.isRead).length;
          return ListView(
            padding: EdgeInsets.all(20.w),
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF433170), const Color(0xFF2E2352)]
                        : [const Color(0xFFEDE7FF), const Color(0xFFF7F4FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You have $unreadCount unread',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Stay updated with school alerts',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              ...items.map((item) => _NotificationTile(item: item)),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  const _NotificationTile({required this.item});

  Color _typeColor() {
    switch (item.type) {
      case NotificationType.fees:
        return AppColors.info;
      case NotificationType.homework:
        return AppColors.primary;
      case NotificationType.event:
        return const Color(0xFF7E57C2);
      case NotificationType.attendance:
        return AppColors.error;
      case NotificationType.academic:
        return AppColors.secondary;
      case NotificationType.general:
        return Colors.grey;
    }
  }

  IconData _typeIcon() {
    switch (item.type) {
      case NotificationType.fees:
        return Icons.payment_rounded;
      case NotificationType.homework:
        return Icons.assignment_rounded;
      case NotificationType.event:
        return Icons.event_rounded;
      case NotificationType.attendance:
        return Icons.how_to_reg_rounded;
      case NotificationType.academic:
        return Icons.school_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(item.createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _typeColor();

    return AppCard(
      color: item.isRead ? null : AppColors.primary.withValues(alpha: 0.04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_typeIcon(), color: color, size: 20),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: item.isRead
                              ? FontWeight.w500
                              : FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  item.body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: item.isRead ? Colors.grey : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  _timeAgo(),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
