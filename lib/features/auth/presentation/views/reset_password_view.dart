import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/theme/app_spacing.dart';
import 'package:ascento_abacus/core/theme/app_radius.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/shared/validators/form_validators.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';

class ResetPasswordView extends ConsumerStatefulWidget {
  const ResetPasswordView({super.key});

  @override
  ConsumerState<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends ConsumerState<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordObscured = true;
  bool _isConfirmObscured = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitReset() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).resetPassword(
        _passwordController.text,
        () {
          // Success callback: show pop-up dialog or show SnackBar and route back to login
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.darkSurface 
                    : AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text('Password Updated'),
                  ],
                ),
                content: const Text(
                  'Your security pin has been reset successfully. You can now sign in using your new credentials.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/login');
                    },
                    child: const Text('Back to Login'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF2C1B2E), const Color(0xFF1B263B)]
                : [const Color(0xFFFFE5E5), const Color(0xFFE5F0FF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.p24, vertical: 16.h),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.p32),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 32,
                        spreadRadius: 8,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Key Badge Graphic ---
                        Center(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.8, end: 1.0),
                            duration: const Duration(seconds: 2),
                            curve: Curves.elasticOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: child,
                              );
                            },
                            child: Container(
                              width: 80.r,
                              height: 80.r,
                              decoration: BoxDecoration(
                                color: isDark 
                                    ? AppColors.info.withValues(alpha: 0.15) 
                                    : AppColors.info.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.key_rounded,
                                size: 40.r,
                                color: isDark ? AppColors.info : AppColors.info,
                              ),
                            ),
                          ),
                        ),
                        AppSpacing.h24,

                        // --- Header ---
                        Text(
                          'Setup Password',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                            letterSpacing: -0.5,
                            fontSize: 32.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.h8,
                        Text(
                          'Formulate a durable new password pin to safeguard your unified school learning account.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : AppColors.textMuted,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.h32,

                        // --- Error notice panel ---
                        if (authState.errorMessage != null) ...[
                          Container(
                            padding: EdgeInsets.all(AppSpacing.p16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.r12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                ),
                                AppSpacing.w12,
                                Expanded(
                                  child: Text(
                                    authState.errorMessage!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppSpacing.h24,
                        ],

                        // --- Form Fields ---
                        CustomTextField(
                          controller: _passwordController,
                          label: 'New Password Pin',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          isObscure: _isPasswordObscured,
                          suffixIcon: _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          onSuffixIconPressed: () {
                            setState(() {
                              _isPasswordObscured = !_isPasswordObscured;
                            });
                          },
                          validator: FormValidators.validatePassword,
                        ),
                        AppSpacing.h24,

                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password Pin',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_rounded,
                          isObscure: _isConfirmObscured,
                          suffixIcon: _isConfirmObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          onSuffixIconPressed: () {
                            setState(() {
                              _isConfirmObscured = !_isConfirmObscured;
                            });
                          },
                          validator: (val) {
                            if (val != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return FormValidators.validatePassword(val);
                          },
                        ),
                        AppSpacing.h32,

                        // --- Submit Button ---
                        CustomButton(
                          text: 'Finalize Reset',
                          icon: Icons.vpn_key_rounded,
                          isLoading: authState.isLoading,
                          onPressed: _submitReset,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
