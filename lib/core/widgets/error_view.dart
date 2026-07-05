import 'package:flutter/material.dart';
import 'package:ascento_abacus/core/constants/app_sizes.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';

class ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryText;

  const ErrorView({
    super.key,
    this.title = 'Oops! Something went wrong',
    required this.message,
    this.onRetry,
    this.retryText = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Elegant animated warning icon card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: theme.colorScheme.error,
                size: 56,
              ),
            ),
            AppSizes.h24,
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
          ),
          AppSizes.h8,
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? theme.colorScheme.onSurface.withOpacity(0.7) : theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            AppSizes.h32,
            SizedBox(
              width: 180,
              child: CustomButton(
                text: retryText,
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
              ),
            ),
          ],
        ],
      ),
    ),
  );
  }
}
