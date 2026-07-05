import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/theme/app_spacing.dart';
import 'package:ascento_abacus/features/admin/branches_crud/branch_repository.dart';

final branchesProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(branchRepositoryProvider).getBranches();
});

class BranchListView extends ConsumerWidget {
  const BranchListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branch Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Open create branch modal
            },
          )
        ],
      ),
      body: branchesAsync.when(
        data: (branches) {
          if (branches.isEmpty) {
            return const Center(child: Text('No branches found.'));
          }
          return ListView.separated(
            padding: EdgeInsets.all(AppSpacing.p16),
            itemCount: branches.length,
            separatorBuilder: (_, __) => AppSpacing.h12,
            itemBuilder: (context, index) {
              final branch = branches[index];
              return Container(
                padding: EdgeInsets.all(AppSpacing.p16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.creamSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.creamBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch['name'] ?? 'Unnamed Branch',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          branch['city'] ?? 'No City',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      onPressed: () {
                        // Open edit modal
                      },
                    )
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error loading branches: $e')),
      ),
    );
  }
}
