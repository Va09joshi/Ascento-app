import 'package:flutter/material.dart';
import 'package:ascento_abacus/core/constants/app_colors.dart';
import 'package:ascento_abacus/core/constants/app_sizes.dart';

class LevelCard extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final double progress; // 0.0 to 1.0
  final bool isLocked;
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.index,
    required this.title,
    required this.description,
    required this.progress,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color badgeColor = isLocked
        ? (isDark ? AppColors.darkBorder : AppColors.creamSurfaceDarker)
        : AppColors.primaryClay;

    final Color cardBg = isDark ? AppColors.darkSurface : AppColors.creamBg;

    return Card(
      color: isLocked ? cardBg.withOpacity(0.5) : cardBg,
      margin: const EdgeInsets.only(bottom: AppSizes.p16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLocked
              ? (isDark ? AppColors.darkBorder : AppColors.creamSurfaceDarker.withOpacity(0.5))
              : (isDark ? AppColors.darkBorder : AppColors.creamSurfaceDarker),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular Level Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: badgeColor, width: 2),
                ),
                child: Center(
                  child: isLocked
                      ? Icon(Icons.lock_rounded, color: theme.disabledColor, size: 20)
                      : Text(
                          '$index',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryClay,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              AppSizes.w16,

              // Level Details & Progress Bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isLocked ? theme.disabledColor : null,
                            ),
                          ),
                        ),
                        if (!isLocked && progress >= 1.0)
                          const Icon(Icons.check_circle_rounded, color: AppColors.secondarySage, size: 20),
                      ],
                    ),
                    AppSizes.h4,
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                    ),
                    if (!isLocked) ...[
                      AppSizes.h16,
                      // Progress Bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: isDark ? AppColors.darkBorder : AppColors.creamSurfaceDarker,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondarySage),
                              ),
                            ),
                          ),
                          AppSizes.w12,
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondarySage,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
