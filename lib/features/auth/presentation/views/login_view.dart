import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/theme/app_spacing.dart';
import 'package:ascento_abacus/core/theme/app_radius.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/core/widgets/glass_container.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/shared/validators/form_validators.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _rememberMe = false;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).login(
        _usernameController.text.trim(),
        _passwordController.text,
        UserRole.student, // We pass student for now, backend dictates actual role
        _rememberMe,
        () {
          final authState = ref.read(authControllerProvider);
          final userRole = authState.currentUser?.role;
          
          if (userRole == UserRole.admin || userRole == UserRole.superAdmin) {
            context.go('/admin-dashboard');
          } else if (userRole == UserRole.teacher) {
            context.go('/teacher-dashboard');
          } else {
            context.go('/dashboard');
          }
        },
      );
    }
  }

  String? _validateIdentifier(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Please enter your ID or email';
    if (input.contains('@')) {
      return FormValidators.validateEmail(input);
    }
    return FormValidators.validateEnrollmentId(input);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
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
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.p32),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- School Brand Header ---
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
                              child: SizedBox(
                                width: 120,
                                height: 80,
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.school_rounded,
                                    size: 56,
                                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.h32,

                          // Removed Welcome Text and Subtitle

                          // --- Red Error Announcement Panel ---
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
                            controller: _usernameController,
                            label: 'ID or Email',
                            hint: 'Enter your ID or Email',
                            prefixIcon: Icons.badge_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateIdentifier,
                          ),
                          AppSpacing.h20,

                          CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outline_rounded,
                            isObscure: _isPasswordObscured,
                            suffixIcon: _isPasswordObscured
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            onSuffixIconPressed: () {
                              setState(() {
                                _isPasswordObscured = !_isPasswordObscured;
                              });
                            },
                            validator: FormValidators.validatePassword,
                          ),

                          // --- Remember Me & Forgot Password ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remember me',
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : AppColors.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  context.push('/forgot-password');
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.h24,

                          // --- Login Action Submit Button ---
                          CustomButton(
                            text: 'Sign In',
                            isLoading: authState.isLoading,
                            onPressed: _submitLogin,
                          ),
                          AppSpacing.h32,

                          // --- Help Desk Footer ---
                          Text(
                            'Need help? support@ascento.com',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white54 : AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
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
      ),
    );
  }
}
