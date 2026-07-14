import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/homework/presentation/providers/homework_provider.dart';

class HomeworkTeacherView extends ConsumerStatefulWidget {
  const HomeworkTeacherView({super.key});

  @override
  ConsumerState<HomeworkTeacherView> createState() => _HomeworkTeacherViewState();
}

class _HomeworkTeacherViewState extends ConsumerState<HomeworkTeacherView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hwAsync = ref.watch(homeworkListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Manage Homework'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Open Homework Creation Dialog (Simplified for now)
            },
          ),
        ],
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
          if (items.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Homework Created',
              subtitle: 'Click + to create an assignment.',
              icon: Icons.assignment_outlined,
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(20.w),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: 16.h),
            itemBuilder: (context, index) => _HomeworkTeacherTile(item: items[index]),
          );
        },
      ),
    );
  }
}

class _HomeworkTeacherTile extends ConsumerWidget {
  final HomeworkItem item;
  const _HomeworkTeacherTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              Text('Due: ${item.dueDate.toIso8601String().split('T')[0]}', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 8.h),
          Text(item.description, style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp)),
          SizedBox(height: 16.h),
          TextButton.icon(
            icon: const Icon(Icons.grading),
            label: const Text('Grade Submissions'),
            onPressed: () {
              // Open grading view
            },
          )
        ],
      ),
    );
  }
}
