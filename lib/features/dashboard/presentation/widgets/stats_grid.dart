import 'package:flutter/material.dart';
import 'package:ascento_abacus/core/constants/app_colors.dart';
import 'package:ascento_abacus/core/constants/app_sizes.dart';

class StatsGrid extends StatelessWidget {
  final int completedLevels;
  final int totalStars;

  const StatsGrid({
    super.key,
    required this.completedLevels,
    required this.totalStars,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final stats = [
      _StatItem(
        title: 'Your Level',
        value: 'Level ${completedLevels + 1}',
        subtitle: 'Soroban Beginner',
        icon: Icons.school_rounded,
        color: AppColors.primary,
      ),
      _StatItem(
        title: 'Stars Earned',
        value: '$totalStars',
        subtitle: 'Math points',
        icon: Icons.star_rounded,
        color: AppColors.info,
      ),
      _StatItem(
        title: 'Exercises',
        value: '${completedLevels * 5 + 4}',
        subtitle: 'Completed items',
        icon: Icons.task_alt_rounded,
        color: AppColors.secondary,
      ),
      _StatItem(
        title: 'Daily Streak',
        value: '3 Days',
        subtitle: 'Keep it up!',
        icon: Icons.local_fire_department_rounded,
        color: Colors.orangeAccent,
      ),
    ];

    // Responsive Grid layout
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width >= 600 ? 4 : 2;
        final double childAspectRatio = width >= 600 ? 1.4 : 1.15;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSizes.p12,
            mainAxisSpacing: AppSizes.p12,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final item = stats[index];
            return Card(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.surfaceDarker,
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, color: item.color, size: 20),
                        ),
                        Text(
                          item.title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.value,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        AppSizes.h4,
                        Text(
                          item.subtitle,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  _StatItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
