import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/constants/app_sizes.dart';
import 'package:ascento_abacus/features/splash/presentation/controllers/splash_controller.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen to splash controller state for router navigation redirect
    ref.listen<SplashState>(splashControllerProvider, (prev, next) {
      if (next.status == SplashStatus.completed && next.targetRoute != null) {
        context.go(next.targetRoute!);
      }
    });

    final splashState = ref.watch(splashControllerProvider);
    final bool isError = splashState.status == SplashStatus.error;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isError) ...[
                // Simple scale animation
                ScaleTransition(
                  scale: _animation,
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.school_rounded,
                        size: 96,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],

              if (isError) ...[
                Card(
                  color: isDark
                      ? const Color(0xFF2D1F1C)
                      : const Color(0xFFFDF6F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.report_problem_rounded,
                            color: AppColors.error,
                            size: 40,
                          ),
                        ),
                        AppSizes.h16,
                        Text(
                          'Initialization Error',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSizes.h8,
                        Text(
                          splashState.errorMessage ??
                              'An unknown boot sequence error has occurred.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.textMuted,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSizes.h24,
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: AppColors.white,
                            ),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                            onPressed: () {
                              ref
                                  .read(splashControllerProvider.notifier)
                                  .runBootSequence();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
