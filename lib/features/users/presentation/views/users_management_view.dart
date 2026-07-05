import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/features/users/presentation/providers/users_provider.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/features/users/presentation/widgets/user_form_sheet.dart';
import 'package:ascento_abacus/features/users/data/repositories/users_repository.dart';

class UsersManagementView extends ConsumerStatefulWidget {
  const UsersManagementView({super.key});

  @override
  ConsumerState<UsersManagementView> createState() => _UsersManagementViewState();
}

class _UsersManagementViewState extends ConsumerState<UsersManagementView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _roles = ['admin', 'teacher', 'student', 'parent'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _roles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddUserSheet(BuildContext context, String currentRole) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserFormSheet(initialRole: currentRole),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.creamBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: isDark ? AppColors.darkSurface : AppColors.creamSurface,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.primaryClay,
                labelColor: AppColors.primaryClay,
                unselectedLabelColor: AppColors.textMuted,
                tabs: const [
                  Tab(text: 'Admins'),
                  Tab(text: 'Teachers'),
                  Tab(text: 'Students'),
                  Tab(text: 'Parents'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _roles.map((role) => _UserListTab(role: role)).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserSheet(context, _roles[_tabController.index]),
        backgroundColor: AppColors.primaryClay,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add User', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _UserListTab extends ConsumerWidget {
  final String role;
  const _UserListTab({required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersListProvider(role));
    final theme = Theme.of(context);

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text('No users found in this role.'));
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryClay.withValues(alpha: 0.1),
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(color: AppColors.primaryClay, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              user.email,
                              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                        onSelected: (value) {
                          if (value == 'edit') {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => UserFormSheet(initialRole: role, userToEdit: user),
                            );
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete User'),
                                content: Text('Are you sure you want to delete ${user.name}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      try {
                                        await ref.read(usersRepositoryProvider).deleteUser(user.id);
                                        ref.invalidate(usersListProvider(role));
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted successfully')));
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete user'), backgroundColor: Colors.red));
                                        }
                                      }
                                    },
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_rounded, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_rounded, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
