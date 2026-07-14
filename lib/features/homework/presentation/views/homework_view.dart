import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/providers/feature_providers.dart';

class HomeworkView extends ConsumerWidget {
  const HomeworkView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hwAsync = ref.watch(homeworkListProvider(null));

    return Scaffold(
      backgroundColor: Colors.transparent,
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
          if (items.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Homework',
              subtitle: 'All caught up!',
              icon: Icons.check_circle_outline,
            );
          }
          return ListView(
            padding: EdgeInsets.all(20.w),
            children: [
              AppCard(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.all(8.w),
                child: Row(
                  children: const [
                    _FilterChip(label: 'All', active: true),
                    _FilterChip(label: 'Pending', active: false),
                    _FilterChip(label: 'Submitted', active: false),
                    _FilterChip(label: 'Graded', active: false),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              ...items.map((item) => _HomeworkTile(item: item)),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  const _FilterChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: active ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _HomeworkTile extends StatelessWidget {
  final HomeworkItem item;
  const _HomeworkTile({required this.item});

  Color _statusColor() {
    switch (item.status) {
      case HomeworkStatus.pending:
        return item.isOverdue ? AppColors.error : AppColors.info;
      case HomeworkStatus.submitted:
        return AppColors.primary;
      case HomeworkStatus.late:
        return AppColors.error;
      case HomeworkStatus.graded:
        return AppColors.secondary;
    }
  }

  String _statusLabel() {
    if (item.isOverdue) return 'OVERDUE';
    return item.status.name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.subject,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _statusLabel(),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            item.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            item.description,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            maxLines: 2,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                'Due: ${item.dueDate.day}/${item.dueDate.month}/${item.dueDate.year}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              if (item.teacherName != null) ...[
                SizedBox(width: 16.w),
                Icon(Icons.person_outline, size: 14, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  item.teacherName!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
          if (item.marks != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: AppColors.info,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${item.marks}/${item.totalMarks}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
