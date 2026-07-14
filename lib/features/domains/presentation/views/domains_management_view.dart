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
      backgroundColor: Colors.transparent,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Domains Management',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Manage academic domains (e.g. Abacus, Vedic Maths)',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              
              if (domainsState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (domainsState.hasError)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error, size: 48.sp),
                        SizedBox(height: 16.h),
                        Text(
                          'Failed to load domains',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.error),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          domainsState.error.toString().replaceFirst('Exception: ', ''),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else if (domainsState.valueOrNull == null || domainsState.valueOrNull!.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Text(
                      'No domains found. Create one to get started!',
                      style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: domainsState.value!.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final domain = domainsState.value![index];
                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        children: [
                          // Domain Icon
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.darkPrimary : AppColors.primary).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(Icons.category, color: isDark ? AppColors.darkPrimary : AppColors.primary, size: 24.sp),
                          ),
                          SizedBox(width: 16.w),
                          
                          // Domain Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        domain.name,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    // Status Badge
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: domain.isActive 
                                            ? AppColors.success.withValues(alpha: 0.1) 
                                            : (isDark ? AppColors.darkSurfaceDarker : AppColors.surfaceDarker),
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        domain.isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          color: domain.isActive 
                                              ? AppColors.success 
                                              : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  domain.description ?? 'No description provided',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          
                          // Action Buttons
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                color: AppColors.info,
                                iconSize: 20.sp,
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.all(6.w),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => DomainFormDialog(domain: domain),
                                  );
                                },
                              ),
                              SizedBox(height: 8.h),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: AppColors.error,
                                iconSize: 20.sp,
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.all(6.w),
                                onPressed: () => _showDeleteDialog(context, domain, ref),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
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
