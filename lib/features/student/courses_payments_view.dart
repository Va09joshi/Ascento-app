import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/theme/app_spacing.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';

class CoursesPaymentsView extends ConsumerWidget {
  const CoursesPaymentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses & Fees'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            AppSpacing.h16,
            Text(
              'Pending Fees: Rs 4,500',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.h8,
            Text(
              'Pay your outstanding balance safely via Razorpay.',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
            AppSpacing.h32,
            SizedBox(
              width: 200,
              child: CustomButton(
                text: 'Pay Now',
                icon: Icons.payment_rounded,
                onPressed: () {
                  // Initialize Razorpay flow
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
