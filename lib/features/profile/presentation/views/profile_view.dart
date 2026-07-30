import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/shared/providers/feature_providers.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ascento_abacus/features/profile/presentation/widgets/edit_profile_dialog.dart';
import 'package:ascento_abacus/shared/router/app_router.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:shimmer/shimmer.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);
    final user = authState.currentUser;

    if (user != null && user.role != UserRole.student) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: _buildStaffProfile(context, user, ref, isDark),
      );
    }

    final profileAsync = ref.watch(studentProfileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: profileAsync.when(
        loading: () => ListView(
          padding: EdgeInsets.all(24.w),
          children: List.generate(5, (_) => AppShimmer.card()),
        ),
        error: (e, _) => EmptyStateWidget(
          title: 'Failed',
          subtitle: e.toString(),
          icon: Icons.error_outline,
        ),
        data: (profile) => SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF5B62E6), const Color(0xFF3D3FA8)]
                        : [const Color(0xFF5B67F4), const Color(0xFF7B4DE6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56.r,
                      height: 56.r,
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28.r),
                        child: profile.user.avatarUrl != null && profile.user.avatarUrl!.isNotEmpty
                            ? Image.network(
                                profile.user.avatarUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Shimmer.fromColors(
                                    baseColor: Colors.white.withValues(alpha: 0.2),
                                    highlightColor: Colors.white.withValues(alpha: 0.5),
                                    child: Container(
                                      width: 56.r,
                                      height: 56.r,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 26),
                              )
                            : Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.person,
                                      size: 26,
                                      color: Colors.white,
                                    ),
                              ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.user.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (profile.className.isNotEmpty || profile.rollNumber.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              [
                                if (profile.className.isNotEmpty) '${profile.className}${profile.section.isNotEmpty ? ' - ${profile.section}' : ''}',
                                if (profile.rollNumber.isNotEmpty) 'Roll No. ${profile.rollNumber}',
                              ].join(' | '),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),

              AppCard(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      icon: Icons.badge,
                      label: 'Student ID',
                      value: profile.user.id,
                    ),
                    _InfoRow(
                      icon: Icons.mail_outline,
                      label: 'Email',
                      value: profile.user.email,
                    ),
                    if (profile.phone != null)
                      _InfoRow(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: profile.phone!,
                      ),
                    if (profile.dateOfBirth != null)
                      _InfoRow(
                        icon: Icons.cake,
                        label: 'DOB',
                        value:
                            '${profile.dateOfBirth!.day}/${profile.dateOfBirth!.month}/${profile.dateOfBirth!.year}',
                      ),
                    if (profile.bloodGroup != null)
                      _InfoRow(
                        icon: Icons.bloodtype,
                        label: 'Blood Group',
                        value: profile.bloodGroup!,
                      ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              if (profile.fatherName != null || profile.motherName != null)
                AppCard(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (profile.fatherName != null)
                        _InfoRow(
                          icon: Icons.person,
                          label: 'Father',
                          value: profile.fatherName!,
                        ),
                      if (profile.motherName != null)
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: 'Mother',
                          value: profile.motherName!,
                        ),
                    ],
                  ),
                ),

              if (profile.address != null) ...[
                SizedBox(height: 14.h),
                AppCard(
                  padding: EdgeInsets.all(12.w),
                  child: _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: profile.address!,
                  ),
                ),
              ],

              SizedBox(height: 24.h),
              CustomButton(
                text: 'Edit Profile',
                icon: Icons.edit_rounded,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditProfileDialog(profile: profile),
                  );
                },
              ),
              SizedBox(height: 12.h),
              CustomButton(
                text: 'Logout',
                icon: Icons.logout_rounded,
                isSecondary: true,
                isLoading: authState.isLoading,
                onPressed: () {
                  ref.read(authControllerProvider.notifier).logout(() {
                    ref.read(routerProvider).go(RoutePaths.login);
                  });
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaffProfile(BuildContext context, UserModel user, WidgetRef ref, bool isDark) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF5B62E6), const Color(0xFF3D3FA8)]
                      : [const Color(0xFF5B67F4), const Color(0xFF7B4DE6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56.r,
                    height: 56.r,
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28.r),
                      child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                          ? Image.network(
                              user.avatarUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Shimmer.fromColors(
                                  baseColor: Colors.white.withValues(alpha: 0.2),
                                  highlightColor: Colors.white.withValues(alpha: 0.5),
                                  child: Container(
                                    width: 56.r,
                                    height: 56.r,
                                    color: Colors.white,
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 26),
                            )
                          : Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.person,
                                    size: 26,
                                    color: Colors.white,
                                  ),
                            ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _formatRole(user.role),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            
            AppCard(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icon: Icons.badge,
                    label: 'User ID',
                    value: user.id.isEmpty ? 'N/A' : user.id,
                  ),
                  _InfoRow(
                    icon: Icons.mail_outline,
                    label: 'Email',
                    value: user.email.isEmpty ? 'N/A' : user.email,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            CustomButton(
              text: 'Logout',
              icon: Icons.logout_rounded,
              isSecondary: true,
              isLoading: authState.isLoading,
              onPressed: () {
                ref.read(authControllerProvider.notifier).logout(() {
                  ref.read(routerProvider).go(RoutePaths.login);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatRole(UserRole role) {
    if (role == UserRole.superAdmin) return 'Super Administrator';
    final str = role.name;
    if (str.isEmpty) return 'Staff';
    return str[0].toUpperCase() + str.substring(1);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          SizedBox(width: 10.w),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value.trim().isEmpty ? 'N/A' : value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: value.trim().isEmpty ? AppColors.textMuted : null,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
