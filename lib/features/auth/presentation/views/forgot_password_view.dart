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

class ForgotPasswordView extends ConsumerStatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  ConsumerState<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends ConsumerState<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submitForgotPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).sendForgotPasswordOtp(
        _emailController.text.trim(),
        () {
          // Success callback: navigate to OTP verification
          context.push('/otp-verify');
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
            color: isDark ? Colors.white : AppColors.textCharcoal,
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
                        // --- Lock Icon / Graphic ---
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
                                    ? AppColors.darkPrimary.withValues(alpha: 0.15) 
                                    : AppColors.primaryClay.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lock_reset_rounded,
                                size: 40.r,
                                color: isDark ? AppColors.darkPrimary : AppColors.primaryClay,
                              ),
                            ),
                          ),
                        ),
                        AppSpacing.h24,

                        // --- Header ---
                        Text(
                          'Forgot Password',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.textCharcoal,
                            letterSpacing: -0.5,
                            fontSize: 32.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.h8,
                        Text(
                          'Provide your registered school email address below and we will dispatch a 6-digit verification code.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : AppColors.textMuted,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.h32,

                        // --- Error Notification Panel ---
                        if (authState.errorMessage != null) ...[
                          Container(
                            padding: EdgeInsets.all(AppSpacing.p16),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed.withValues(alpha: 0.1),
                              border: Border.all(
                                color: AppColors.errorRed.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.r12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorRed.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.errorRed,
                                    size: 20,
                                  ),
                                ),
                                AppSpacing.w12,
                                Expanded(
                                  child: Text(
                                    authState.errorMessage!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.errorRed,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppSpacing.h24,
                        ],

                        // --- Text Field input ---
                        CustomTextField(
                          controller: _emailController,
                          label: 'School Email Address',
                          hint: 'name@ascento.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: FormValidators.validateEmail,
                        ),
                        AppSpacing.h32,

                        // --- Submit Button ---
                        CustomButton(
                          text: 'Send Verification Code',
                          icon: Icons.send_rounded,
                          isLoading: authState.isLoading,
                          onPressed: _submitForgotPassword,
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
