import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/theme/app_spacing.dart';
import 'package:ascento_abacus/core/theme/app_radius.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';

class OtpVerificationView extends ConsumerStatefulWidget {
  const OtpVerificationView({super.key});

  @override
  ConsumerState<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends ConsumerState<OtpVerificationView> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  
  late Timer _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _canResend = true;
          _timer.cancel();
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _submitOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).verifyOtp(
        _otpController.text.trim(),
        () {
          // Navigate to password reset update view
          context.push('/reset-password');
        },
      );
    }
  }

  void _resendCode() {
    if (_canResend) {
      final email = ref.read(authControllerProvider).otpEmail ?? '';
      ref.read(authControllerProvider.notifier).sendForgotPasswordOtp(
        email,
        () {
          _startTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A fresh verification code has been dispatched to your email.'),
              backgroundColor: AppColors.secondary,
            ),
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
                        // --- Lock Open Badge Icon ---
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
                                    ? AppColors.secondary.withValues(alpha: 0.15) 
                                    : AppColors.secondary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.mark_email_read_rounded,
                                size: 40.r,
                                color: isDark ? AppColors.secondary : AppColors.secondary,
                              ),
                            ),
                          ),
                        ),
                        AppSpacing.h24,

                        // --- Header ---
                        Text(
                          'Verify Identity',
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
                          'An OTP verification has been dispatched to ${authState.otpEmail ?? "your address"}. Enter the 6-digit numeric digits or sandbox code (123456) to proceed.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : AppColors.textMuted,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.h32,

                        // --- Error Notice ---
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

                        // --- OTP TextField ---
                        CustomTextField(
                          controller: _otpController,
                          label: 'Enter OTP Code',
                          hint: '123456',
                          prefixIcon: Icons.pin_rounded,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'OTP code is required';
                            }
                            if (val.trim().length < 4) {
                              return 'Please provide a valid code';
                            }
                            return null;
                          },
                        ),
                        AppSpacing.h24,

                        // --- Timer Countdown Indicators ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _canResend 
                                  ? 'Did not get the code?' 
                                  : 'Resend code in ${_secondsRemaining}s',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white54 : AppColors.textMuted,
                              ),
                            ),
                            TextButton(
                              onPressed: _canResend ? _resendCode : null,
                              child: Text(
                                'Resend Code',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: _canResend 
                                      ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.h32,

                        // --- Action Submit Button ---
                        CustomButton(
                          text: 'Verify and Continue',
                          icon: Icons.verified_user_rounded,
                          isLoading: authState.isLoading,
                          onPressed: _submitOtp,
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
