import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/theme/app_spacing.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/glass_container.dart';
import 'package:ascento_abacus/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:ascento_abacus/features/onboarding/presentation/widgets/onboarding_illustration_widget.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final onboardingState = ref.watch(onboardingControllerProvider);
    final controllerNotifier = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
          child: Column(
            children: [
              // --- Top App Bar ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!onboardingState.isLastPage)
                      TextButton(
                        onPressed: () {
                          controllerNotifier.completeOnboarding(() {
                            context.go('/dashboard');
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: isDark 
                              ? Colors.black.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Skip',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? AppColors.darkPrimary : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // --- Top Sliding PageView ---
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingState.items.length,
                  onPageChanged: controllerNotifier.handlePageChanged,
                  itemBuilder: (context, index) {
                    final item = onboardingState.items[index];
                    
                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.p24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppSpacing.h32,
                            // Beautiful Custom Animated Vector Illustration
                            OnboardingIllustrationWidget(illustration: item.illustration),
                            AppSpacing.h32,
                            
                            // Slide Header Title
                            Text(
                              item.title,
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            AppSpacing.h16,
                            
                            // Slide Paragraph Subtitle
                            Text(
                              item.description,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: isDark ? AppColors.darkTextMuted : AppColors.textPrimary,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            AppSpacing.h16,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // --- Bottom Navigation & Dots Panel ---
              Padding(
                padding: EdgeInsets.all(AppSpacing.p24),
                child: GlassContainer(
                  blur: 15.0,
                  opacity: isDark ? 0.3 : 0.6,
                  padding: EdgeInsets.all(AppSpacing.p24),
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page Indicators Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          onboardingState.items.length,
                          (index) => _buildIndicatorDot(index, onboardingState.currentIndex, isDark),
                        ),
                      ),
                      AppSpacing.h32,

                      // Action Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: onboardingState.isLastPage ? 'Get Started' : 'Continue',
                          onPressed: () {
                            if (onboardingState.isLastPage) {
                              controllerNotifier.completeOnboarding(() {
                                context.go('/dashboard');
                              });
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  // Beautiful active pill/dot indicator
  Widget _buildIndicatorDot(int index, int activeIndex, bool isDark) {
    final isActive = index == activeIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.r,
      width: isActive ? 24.r : 8.r,
      decoration: BoxDecoration(
        color: isActive
            ? (isDark ? AppColors.darkPrimary : AppColors.primary)
            : (isDark ? AppColors.darkBorder : AppColors.textMuted.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
