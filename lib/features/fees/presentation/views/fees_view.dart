import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/repositories/feature_repository.dart';
import 'package:ascento_abacus/core/widgets/app_dialogs.dart';
import 'dart:async';

// =============================================================================
// STATEFUL LOCAL FEES PROVIDER
// =============================================================================

class LocalFeesNotifier extends StateNotifier<AsyncValue<List<FeeRecord>>> {
  final Ref _ref;
  LocalFeesNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    try {
      final repo = _ref.read(featureRepositoryProvider);
      final initialFees = await repo.getFeeHistory();
      state = AsyncValue.data(initialFees);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void payFee(String id, double amountPaid) {
    state.whenData((fees) {
      final updatedList = fees.map((fee) {
        if (fee.id == id) {
          final newPaidAmount = (fee.paidAmount ?? 0) + amountPaid;
          final isFullyPaid = newPaidAmount >= fee.amount;
          return FeeRecord(
            id: fee.id,
            title: fee.title,
            amount: fee.amount,
            paidAmount: newPaidAmount,
            status: isFullyPaid ? PaymentStatus.paid : PaymentStatus.partial,
            dueDate: fee.dueDate,
            paidDate: DateTime.now(),
            transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
          );
        }
        return fee;
      }).toList();
      state = AsyncValue.data(updatedList);
    });
  }
}

final localFeesProvider = StateNotifierProvider<LocalFeesNotifier, AsyncValue<List<FeeRecord>>>((ref) {
  return LocalFeesNotifier(ref);
});

// =============================================================================
// OVERHAULED FEES MAIN VIEW
// =============================================================================

class FeesView extends ConsumerWidget {
  const FeesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final feesState = ref.watch(localFeesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.creamBg,
      body: feesState.when(
        loading: () => ListView(
          padding: EdgeInsets.all(24.w),
          children: List.generate(3, (_) => AppShimmer.card()),
        ),
        error: (e, _) => EmptyStateWidget(
          title: 'Failed to load billing',
          subtitle: e.toString(),
          icon: Icons.error_outline,
        ),
        data: (fees) {
          final totalAmount = fees.fold<double>(0, (sum, f) => sum + f.amount);
          final totalPaid = fees.fold<double>(0, (sum, f) => sum + (f.paidAmount ?? 0));
          final totalOutstanding = fees.fold<double>(0, (sum, f) => sum + f.balanceDue);
          final paidRatio = totalAmount > 0 ? (totalPaid / totalAmount) : 0.0;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(localFeesProvider);
            },
            color: isDark ? AppColors.darkPrimary : AppColors.primaryClay,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1. Outstanding Balance Card (Overhauled Dashboard Card) ---
                  _buildOutstandingCard(context, totalOutstanding, totalPaid, totalAmount, paidRatio, isDark),
                  SizedBox(height: 18.h),

                  // --- 2. Razorpay Direct Access Card ---
                  _PaymentAccessCard(totalOutstanding: totalOutstanding, fees: fees),
                  SizedBox(height: 22.h),

                  // --- 3. Fee History Section ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fee Installments Ledger',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16.sp,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black54.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${fees.length} ITEMS',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  ...fees.map((fee) => _FeeTile(fee: fee)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOutstandingCard(
    BuildContext context,
    double outstanding,
    double paid,
    double total,
    double ratio,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2C2420), const Color(0xFF1E1512)]
              : [const Color(0xFFFF8E53), const Color(0xFFFF6B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFFFF6B6B).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.white24,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL OUTSTANDING',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '₹ ${outstanding.toStringAsFixed(0)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 28.sp,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Progress',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(ratio * 100).toStringAsFixed(0)}% Paid',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8.h,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'PAID SO FAR',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '₹ ${paid.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 20.h,
                  color: Colors.white24,
                ),
                Column(
                  children: [
                    Text(
                      'TOTAL BENEFACTOR',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '₹ ${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ONLINE PAYMENT & RAZORPAY GATEWAY TRIGGER CARD
// =============================================================================

class _PaymentAccessCard extends ConsumerWidget {
  final double totalOutstanding;
  final List<FeeRecord> fees;

  const _PaymentAccessCard({
    required this.totalOutstanding,
    required this.fees,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: const Color(0xFF0052FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Color(0xFF0052FF),
              size: 24,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Razorpay Instant Billing',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  totalOutstanding > 0
                      ? 'Pay off your entire outstanding sum of ₹ ${totalOutstanding.toStringAsFixed(0)} instantly via our secure billing system.'
                      : 'Excellent! All academic fee cycles are fully cleared. No outstanding balances pending at this time.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey.shade400 : AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
                if (totalOutstanding > 0) ...[
                  SizedBox(height: 14.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      final firstUnpaid = fees.firstWhere((f) => f.balanceDue > 0);
                      _showRazorpaySheet(context, firstUnpaid, totalOutstanding, ref);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    icon: const Icon(Icons.shield_rounded, size: 14),
                    label: Text(
                      'Pay outstanding total',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EXPANDABLE FEE INSTALMENT TILE
// =============================================================================

class _FeeTile extends StatefulWidget {
  final FeeRecord fee;
  const _FeeTile({required this.fee});

  @override
  State<_FeeTile> createState() => _FeeTileState();
}

class _FeeTileState extends State<_FeeTile> {
  bool _isExpanded = false;

  Color _statusColor() {
    switch (widget.fee.status) {
      case PaymentStatus.paid:
        return AppColors.secondarySage;
      case PaymentStatus.pending:
        return AppColors.tertiaryHoney;
      case PaymentStatus.overdue:
        return AppColors.errorRed;
      case PaymentStatus.partial:
        return AppColors.primaryClay;
    }
  }

  IconData _statusIcon() {
    switch (widget.fee.status) {
      case PaymentStatus.paid:
        return Icons.check_circle_rounded;
      case PaymentStatus.pending:
        return Icons.watch_later_rounded;
      case PaymentStatus.overdue:
        return Icons.info_rounded;
      case PaymentStatus.partial:
        return Icons.pie_chart_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _statusColor();

    return AppCard(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          trailing: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _isExpanded ? 0.5 : 0.0,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? Colors.white60 : Colors.black45,
            ),
          ),
          title: Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_statusIcon(), color: color, size: 20.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.fee.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Due: ${widget.fee.dueDate.day}/${widget.fee.dueDate.month}/${widget.fee.dueDate.year}',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : AppColors.textMuted,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹ ${widget.fee.amount.toStringAsFixed(0)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      widget.fee.status.name.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.creamBorder,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'INVOICE ITEM BREAKDOWN',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _buildBreakdownRow(context, '01. Tuition & Mentorship Fees', widget.fee.amount * 0.75, isDark),
                  _buildBreakdownRow(context, '02. Laboratory & Activity Charges', widget.fee.amount * 0.12, isDark),
                  _buildBreakdownRow(context, '03. Study Materials & Kits', widget.fee.amount * 0.08, isDark),
                  _buildBreakdownRow(context, '04. Services GST Tax (18%)', widget.fee.amount * 0.05, isDark),
                  const Divider(),
                  _buildBreakdownRow(context, 'Total Gross Payable', widget.fee.amount, isDark, isBold: true),
                  if (widget.fee.paidAmount != null && widget.fee.paidAmount! > 0) ...[
                    _buildBreakdownRow(context, 'Credits Paid', -widget.fee.paidAmount!, isDark, isCredit: true),
                    const Divider(),
                    _buildBreakdownRow(
                      context,
                      'Net Outstanding Balance',
                      widget.fee.balanceDue,
                      isDark,
                      isBold: true,
                      customColor: widget.fee.balanceDue > 0 ? AppColors.errorRed : AppColors.secondarySage,
                    ),
                  ],
                  if (widget.fee.transactionId != null) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailValue('Transaction ID', widget.fee.transactionId!, isDark),
                          if (widget.fee.paidDate != null)
                            _buildDetailValue(
                              'Date Settled',
                              '${widget.fee.paidDate!.day}/${widget.fee.paidDate!.month}/${widget.fee.paidDate!.year}',
                              isDark,
                            ),
                          _buildDetailValue('Payment Gateway', 'Razorpay Instant Core', isDark),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  Consumer(
                    builder: (context, ref, _) {
                      return Row(
                        children: [
                          if (widget.fee.balanceDue > 0)
                            Expanded(
                              child: Container(
                                height: 38.h,
                                margin: EdgeInsets.only(right: widget.fee.paidAmount != null ? 8.w : 0),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _showRazorpaySheet(context, widget.fee, widget.fee.balanceDue, ref);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0052FF),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  icon: const Icon(Icons.payment_rounded, size: 14),
                                  label: Text(
                                    'Pay Outstanding ₹${widget.fee.balanceDue.toStringAsFixed(0)}',
                                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          if (widget.fee.paidAmount != null && widget.fee.paidAmount! > 0)
                            Expanded(
                              child: SizedBox(
                                height: 38.h,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _showDownloadDialog(context, widget.fee);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isDark ? Colors.white70 : AppColors.textCharcoal,
                                    side: BorderSide(
                                      color: isDark ? Colors.white24 : AppColors.creamBorder,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  icon: const Icon(Icons.file_download_rounded, size: 14),
                                  label: Text(
                                    'Download Receipt',
                                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    BuildContext context,
    String label,
    double amount,
    bool isDark, {
    bool isBold = false,
    bool isCredit = false,
    Color? customColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isDark ? Colors.white70 : AppColors.textCharcoal,
            ),
          ),
          Text(
            '${isCredit ? '-' : ''}₹ ${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: customColor ??
                  (isCredit
                      ? AppColors.secondarySage
                      : (isDark ? Colors.white : AppColors.textCharcoal)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailValue(String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10.sp,
              color: isDark ? Colors.white70 : AppColors.textCharcoal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HIGH-FIDELITY RAZORPAY GATEWAY MODAL SIMULATION
// =============================================================================

void _showRazorpaySheet(BuildContext context, FeeRecord fee, double payAmount, WidgetRef ref) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (ctx) => _RazorpayGatewayModal(
      fee: fee,
      payAmount: payAmount,
      isDark: isDark,
      onPaymentSuccess: (amountPaid) {
        ref.read(localFeesProvider.notifier).payFee(fee.id, amountPaid);
        AppSnackbar.success(
          context,
          message: 'Payment of ₹ ${amountPaid.toStringAsFixed(0)} credited successfully via Razorpay.',
        );
      },
    ),
  );
}

class _RazorpayGatewayModal extends StatefulWidget {
  final FeeRecord fee;
  final double payAmount;
  final bool isDark;
  final Function(double) onPaymentSuccess;

  const _RazorpayGatewayModal({
    required this.fee,
    required this.payAmount,
    required this.isDark,
    required this.onPaymentSuccess,
  });

  @override
  State<_RazorpayGatewayModal> createState() => _RazorpayGatewayModalState();
}

class _RazorpayGatewayModalState extends State<_RazorpayGatewayModal> {
  String _selectedMethod = 'UPI';
  bool _isProcessing = false;
  String _processingState = 'Securing tunnel connection...';
  bool _paymentFinished = false;
  int _timerCounter = 0;
  Timer? _processingTimer;

  final List<String> _processingSteps = [
    'Securing tunnel connection...',
    'Authenticating with Bank servers...',
    'Verifying balance tokens...',
    'Settling merchant billing records...',
  ];

  @override
  void dispose() {
    _processingTimer?.cancel();
    super.dispose();
  }

  void _startPaymentFlow() {
    setState(() {
      _isProcessing = true;
    });

    _processingTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (_timerCounter < _processingSteps.length - 1) {
        setState(() {
          _timerCounter++;
          _processingState = _processingSteps[_timerCounter];
        });
      } else {
        timer.cancel();
        setState(() {
          _isProcessing = false;
          _paymentFinished = true;
        });

        // Autoclose gateway screen after brief success display
        Future.delayed(const Duration(milliseconds: 1600), () {
          if (mounted) {
            Navigator.of(context).pop();
            widget.onPaymentSuccess(widget.payAmount);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Iconic Razorpay Dark Slate Color
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Logo & Safe badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0052FF),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Center(
                      child: Text(
                        'R',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Razorpay Trusted Checkout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        'MID: MID_ASCENTO_ABACUS_982',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 8.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: Colors.green, size: 10),
                    SizedBox(width: 4.w),
                    Text(
                      'SECURE',
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 24),

          if (_isProcessing) ...[
            _buildProcessingState(),
          ] else if (_paymentFinished) ...[
            _buildSuccessState(),
          ] else ...[
            _buildPaymentMethodsState(),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Institution Detail Card
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ascento Abacus Education',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.fee.title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹ ${widget.payAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        const Text(
          'PREFERRED PAYMENT CHANNELS',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8.h),
        _buildMethodRow(
          'UPI',
          'Instant pay using GPay, PhonePe, or UPI ID',
          Icons.qr_code_2_rounded,
          const Color(0xFFEAB308),
        ),
        _buildMethodRow(
          'Credit/Debit Card',
          'Visa, Mastercard, RuPay & Diner Clubs',
          Icons.credit_card_rounded,
          const Color(0xFF3B82F6),
        ),
        _buildMethodRow(
          'Net Banking',
          'SBI, ICICI, HDFC, Axis, and more banks',
          Icons.account_balance_rounded,
          const Color(0xFF10B981),
        ),
        _buildMethodRow(
          'Digital Wallets',
          'Paytm, PhonePe, AmazonPay Wallet',
          Icons.wallet_rounded,
          const Color(0xFFEC4899),
        ),
        SizedBox(height: 24.h),
        Container(
          height: 48.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0052FF).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _startPaymentFlow,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052FF), // Razorpay Blue
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 14),
                SizedBox(width: 8.w),
                Text(
                  'PAY ₹ ${widget.payAmount.toStringAsFixed(0)} SECURELY',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodRow(String name, String sub, IconData icon, Color badgeColor) {
    final isSelected = _selectedMethod == name;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = name;
        });
      },
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF0052FF).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: badgeColor, size: 18),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF0052FF) : Colors.white24,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0052FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          SizedBox(
            width: 52.w,
            height: 52.w,
            child: const CircularProgressIndicator(
              color: Color(0xFF0052FF),
              strokeWidth: 4,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            _processingState,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          const Text(
            'Please do not close the window or tap back.',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(height: 20.h),
          const Text(
            'Payment Successful!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Reference ID: PAY_TXN_${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// INTERACTIVE RECEIPT DOWNLOAD DIALOG SIMULATION
// =============================================================================

void _showDownloadDialog(BuildContext context, FeeRecord fee) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ReceiptDownloadDialog(fee: fee),
  );
}

class _ReceiptDownloadDialog extends StatefulWidget {
  final FeeRecord fee;
  const _ReceiptDownloadDialog({required this.fee});

  @override
  State<_ReceiptDownloadDialog> createState() => _ReceiptDownloadDialogState();
}

class _ReceiptDownloadDialogState extends State<_ReceiptDownloadDialog> {
  double _progress = 0.0;
  String _downloadStep = 'Connecting to ledger database...';
  Timer? _downloadTimer;

  final List<String> _steps = [
    'Connecting to ledger database...',
    'Fetching transaction signatures...',
    'Compiling receipt layout & PDF...',
    'Securing download encryption keys...',
    'Finalizing write to Downloads storage...',
  ];

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  @override
  void dispose() {
    _downloadTimer?.cancel();
    super.dispose();
  }

  void _startDownload() {
    _downloadTimer = Timer.periodic(const Duration(milliseconds: 320), (timer) {
      if (_progress < 1.0) {
        setState(() {
          _progress += 0.1;
          if (_progress >= 1.0) _progress = 1.0;
          final stepIndex = (_progress * (_steps.length - 1)).round();
          _downloadStep = _steps[stepIndex];
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            Navigator.of(context).pop();
            AppSnackbar.success(
              context,
              message: 'Fee receipt for ${widget.fee.title} downloaded successfully to device!',
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.creamSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      content: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56.w,
              height: 56.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _progress,
                    color: isDark ? AppColors.darkPrimary : AppColors.primaryClay,
                    strokeWidth: 5,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  ),
                  Text(
                    '${(_progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: isDark ? Colors.white : AppColors.textCharcoal,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Generating PDF Invoice',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              _downloadStep,
              style: TextStyle(
                color: isDark ? Colors.white60 : AppColors.textMuted,
                fontSize: 10.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
