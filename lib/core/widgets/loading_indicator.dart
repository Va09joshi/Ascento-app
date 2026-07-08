import 'package:flutter/material.dart';
import 'package:ascento_abacus/core/constants/app_colors.dart';

class LoadingIndicator extends StatefulWidget {
  final String? message;
  const LoadingIndicator({super.key, this.message});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final beadColors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.info,
      isDark ? AppColors.darkPrimary : AppColors.secondary.withOpacity(0.7),
      isDark ? AppColors.darkSecondary : AppColors.primary.withOpacity(0.7),
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual Abacus Frame with rods and bouncing beads!
          Container(
            width: 160,
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.surfaceDarker,
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Stack(
              children: [
                // Horizontal divider beam representing an Abacus beam
                Align(
                  alignment: const Alignment(0, -0.2),
                  child: Container(
                    height: 5,
                    color: isDark ? AppColors.darkBorder : AppColors.surfaceDarker,
                  ),
                ),
                // 5 columns, each with a rod and a bouncing bead!
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    return _AbacusRodBead(
                      color: beadColors[index],
                      index: index,
                      controller: _controller,
                      isDark: isDark,
                    );
                  }),
                ),
              ],
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 20),
            Text(
              widget.message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AbacusRodBead extends StatelessWidget {
  final Color color;
  final int index;
  final AnimationController controller;
  final bool isDark;

  const _AbacusRodBead({
    required this.color,
    required this.index,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Staggered bounce values for bead movement on rod
    final double startFraction = index * 0.15;
    final double endFraction = startFraction + 0.4;

    final Animation<double> bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 50.0).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 50.0, end: 0.0).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          startFraction % 1.0,
          endFraction % 1.0,
          curve: Curves.linear,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            // Vertical Abacus Rod
            Container(
              width: 2.0,
              height: 76,
              color: isDark ? AppColors.darkBorder : AppColors.surfaceDarker.withOpacity(0.7),
            ),
            // Floating Bouncing Bead
            Positioned(
              top: bounceAnimation.value,
              child: Container(
                width: 18,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 3,
                      offset: const Offset(0, 1.5),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
