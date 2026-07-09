import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/features/domains/presentation/providers/domains_provider.dart';
import 'package:ascento_abacus/features/domains/presentation/widgets/domain_form_dialog.dart';

class DomainsManagementView extends ConsumerWidget {
  const DomainsManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domainsState = ref.watch(domainsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Domains Management',
                        style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Manage academic domains (e.g. Abacus, Vedic Math)',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 180.w,
                    child: CustomButton(
                      text: 'Add Domain',
                      icon: Icons.add,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const DomainFormDialog(),
                        );
                      },
                    ),
                  )
                ],
              ),
              SizedBox(height: 32.h),
              
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: domainsState.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
                    data: (domains) {
                      if (domains.isEmpty) {
                        return Center(
                          child: Text('No domains found.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16.sp)),
                        );
                      }
                      
                      return ListView.separated(
                        itemCount: domains.length,
                        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final domain = domains[index];
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            leading: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.category, color: AppColors.primary),
                            ),
                            title: Text(domain.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4.h),
                                Text(domain.description ?? 'No description provided', style: TextStyle(color: Colors.grey.shade600)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: domain.isActive ? AppColors.success.withOpacity(0.1) : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    domain.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color: domain.isActive ? AppColors.success : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: AppColors.primary),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => DomainFormDialog(domain: domain),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Domain'),
                                        content: Text('Are you sure you want to delete ${domain.name}?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, true), 
                                            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                                          ),
                                        ],
                                      )
                                    );
                                    
                                    if (confirm == true) {
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
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      );
                    }
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
