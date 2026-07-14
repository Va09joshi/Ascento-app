import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/features/users/presentation/providers/users_provider.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/features/users/data/repositories/users_repository.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/shared/widgets/premium_data_table.dart';
import 'package:ascento_abacus/features/users/presentation/widgets/assign_class_dialog.dart';

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
    context.push(RoutePaths.addUser, extra: currentRole);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          final activeRole = _roles[_tabController.index];
          return FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            onPressed: () => _showAddUserSheet(context, activeRole),
            icon: const Icon(Icons.add_rounded),
            label: Text('Add ${activeRole[0].toUpperCase()}${activeRole.substring(1)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
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
                children: _roles.map((role) => _UserListTab(
                  role: role,
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserListTab extends ConsumerStatefulWidget {
  final String role;
  
  const _UserListTab({required this.role});

  @override
  ConsumerState<_UserListTab> createState() => _UserListTabState();
}

class _UserListTabState extends ConsumerState<_UserListTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersListProvider(widget.role));
    
    final allUsers = usersAsync.value ?? [];
    final filteredUsers = allUsers.where((u) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return u.name.toLowerCase().contains(query) || u.email.toLowerCase().contains(query);
    }).toList();
    
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurfaceDarker : AppColors.surfaceDarker,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          SizedBox(height: 16.h),
          PremiumDataTable<UserModel>(
            title: '${widget.role[0].toUpperCase()}${widget.role.substring(1)}s Management',
            subtitle: 'Manage all ${widget.role} accounts in the system.',
            isLoading: usersAsync.isLoading,
            onRowTap: (user) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('User Details'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${user.id}'),
                      SizedBox(height: 8.h),
                      Text('Name: ${user.name}'),
                      SizedBox(height: 8.h),
                      Text('Email: ${user.email}'),
                      if (user.role == UserRole.student) ...[
                        SizedBox(height: 8.h),
                        if (user.className != null) Text('Class: ${user.className}'),
                        if (user.sectionName != null) ...[
                          SizedBox(height: 8.h),
                          Text('Section: ${user.sectionName}'),
                        ],
                        if (user.rollNumber != null) ...[
                          SizedBox(height: 8.h),
                          Text('Roll No: ${user.rollNumber}'),
                        ],
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))
                  ],
                ),
              );
            },
            data: filteredUsers,
            columns: const ['User', 'Email', 'Phone', 'Domain', 'Role', 'Status', 'Actions'],
            rowBuilder: (user) => [
              // User Avatar & Name
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                    CircleAvatar(
                      radius: 16.w,
                      backgroundImage: NetworkImage(user.avatarUrl!),
                      onBackgroundImageError: (_, __) {},
                    )
                  else
                    Container(
                      width: 32.w,
                      height: 32.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                      ),
                      if (user.role == UserRole.student && user.rollNumber != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          'Roll: ${user.rollNumber}',
                          style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              // Email
              Text(user.email),
              // Phone
              Text(user.phone ?? 'N/A'),
              // Domain
              Text(user.domainId ?? 'N/A'),
              // Role Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  user.role.name.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.info,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.role == 'student')
                    IconButton(
                      icon: const Icon(Icons.class_outlined, size: 20),
                      color: AppColors.primary,
                      tooltip: 'Assign Class',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AssignClassDialog(student: user),
                        );
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: AppColors.info,
                    onPressed: () => context.push(RoutePaths.editUser, extra: user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: AppColors.error,
                    onPressed: () => _showDeleteDialog(context, ref, user, widget.role),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, UserModel user, String role) {
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete user'), backgroundColor: Colors.red));
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
