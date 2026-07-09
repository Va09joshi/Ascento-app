import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/features/domains/presentation/providers/domains_provider.dart';
import 'package:ascento_abacus/features/domains/presentation/widgets/domain_form_dialog.dart';
import 'package:ascento_abacus/shared/models/domain_model.dart';
import 'package:ascento_abacus/shared/widgets/premium_data_table.dart';

class DomainsManagementView extends ConsumerWidget {
  const DomainsManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final domainsState = ref.watch(domainsListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const DomainFormDialog(),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Domain', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PremiumDataTable<DomainModel>(
                title: 'Domains Management',
                subtitle: 'Manage academic domains (e.g. Abacus, Vedic Maths)',
                isLoading: domainsState.isLoading,
                error: domainsState.hasError ? domainsState.error.toString() : null,
                data: domainsState.valueOrNull ?? [],
                columns: const ['Domain', 'Status', 'Actions'],
                rowBuilder: (domain) => [
                  // Domain Name and Icon
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkPrimary : AppColors.primary).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.category, color: isDark ? AppColors.darkPrimary : AppColors.primary, size: 16.sp),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            domain.name,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                          ),
                          SizedBox(
                            width: 250.w,
                            child: Text(
                              domain.description ?? 'No description provided',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: domain.isActive ? AppColors.success.withValues(alpha: 0.1) : (isDark ? AppColors.darkSurfaceDarker : AppColors.surfaceDarker),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      domain.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: domain.isActive ? AppColors.success : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: AppColors.info,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => DomainFormDialog(domain: domain),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AppColors.error,
                        onPressed: () => _showDeleteDialog(context, domain, ref),
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

  void _showDeleteDialog(BuildContext context, DomainModel domain, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Domain'),
        content: Text('Are you sure you want to delete ${domain.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(domainsListProvider.notifier).deleteDomain(domain.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Domain deleted'), backgroundColor: AppColors.success));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppColors.error));
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
