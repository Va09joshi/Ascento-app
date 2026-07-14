import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/models/branch_model.dart';
import 'package:ascento_abacus/features/branches/data/repositories/branches_repository.dart';
import 'package:ascento_abacus/features/branches/presentation/providers/branches_provider.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/shared/widgets/premium_data_table.dart';

class BranchesManagementView extends ConsumerStatefulWidget {
  const BranchesManagementView({super.key});

  @override
  ConsumerState<BranchesManagementView> createState() => _BranchesManagementViewState();
}

class _BranchesManagementViewState extends ConsumerState<BranchesManagementView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final branchesAsync = ref.watch(branchesListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push(RoutePaths.addBranch),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Branch', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PremiumDataTable<BranchModel>(
                title: 'Branches Management',
                subtitle: 'Manage all organization campuses and locations.',
                isLoading: branchesAsync.isLoading,
                data: branchesAsync.value ?? [],
                columns: const ['Branch Name', 'City', 'Phone', 'Address', 'Actions'],
                rowBuilder: (branch) => [
                  // Branch Name
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.domain_rounded, color: AppColors.primary, size: 16.sp),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        branch.name,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                      ),
                    ],
                  ),
                  // City
                  Text(branch.city),
                  // Phone
                  Text(branch.phone),
                  // Address
                  SizedBox(
                    width: 200.w,
                    child: Text(
                      branch.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: AppColors.info,
                        onPressed: () => context.push(RoutePaths.editBranch, extra: branch),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AppColors.error,
                        onPressed: () => _showDeleteDialog(context, branch),
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

  void _showDeleteDialog(BuildContext context, BranchModel branch) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Branch'),
        content: Text('Are you sure you want to delete ${branch.name}? This action cannot be undone.'),
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
                await ref.read(branchesRepositoryProvider).deleteBranch(branch.id);
                ref.invalidate(branchesListProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Branch deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete branch'), backgroundColor: AppColors.error),
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
}
