import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/homework/presentation/providers/homework_provider.dart';
import 'package:ascento_abacus/features/homework/data/repositories/homework_repository.dart';

class HomeworkStudentView extends ConsumerStatefulWidget {
  const HomeworkStudentView({super.key});

  @override
  ConsumerState<HomeworkStudentView> createState() => _HomeworkStudentViewState();
}

class _HomeworkStudentViewState extends ConsumerState<HomeworkStudentView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hwAsync = ref.watch(homeworkListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('My Homework'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              title: 'No Homework',
              subtitle: 'All caught up!',
              icon: Icons.check_circle_outline,
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(20.w),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: 16.h),
            itemBuilder: (context, index) => _HomeworkStudentTile(item: items[index]),
          );
        },
      ),
    );
  }
}

class _HomeworkStudentTile extends ConsumerWidget {
  final HomeworkItem item;
  const _HomeworkStudentTile({required this.item});

  Future<void> _submitHomework(BuildContext context, WidgetRef ref) async {
    // Show a simple dialog to input file URL
    final controller = TextEditingController();
    final fileUrl = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Homework'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'File URL (PDF/Image)',
            hintText: 'https://...',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (fileUrl != null && fileUrl.isNotEmpty) {
      try {
        await ref.read(homeworkRepositoryProvider).submitHomework(item.id, fileUrl);
        ref.invalidate(homeworkListProvider);
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Homework submitted successfully!')));
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
          SizedBox(height: 4.h),
          Text(item.description, style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp)),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Due: ${item.dueDate.toIso8601String().split('T')[0]}', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
              Text('Status: ${item.status.name.toUpperCase()}'),
            ],
          ),
          SizedBox(height: 16.h),
          if (item.status == HomeworkStatus.pending)
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Submit Work',
                onPressed: () => _submitHomework(context, ref),
              ),
            ),
        ],
      ),
    );
  }
}
