import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/theme/app_typography.dart';
import 'package:ascento_abacus/shared/widgets/premium_card.dart';
import 'package:shimmer/shimmer.dart';

class PremiumDataTable<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<String> columns;
  final List<T> data;
  final List<Widget> Function(T item) rowBuilder;
  final bool isLoading;
  final String? error;
  final Widget? emptyState;
  final void Function(T item)? onRowTap;

  const PremiumDataTable({
    super.key,
    required this.title,
    this.subtitle,
    required this.columns,
    required this.data,
    required this.rowBuilder,
    this.isLoading = false,
    this.error,
    this.emptyState,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [AppColors.darkSurfaceDarker, AppColors.darkSurface] 
                    : [AppColors.surfaceDarker, AppColors.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            padding: EdgeInsets.all(20.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.lightTextTheme.titleLarge?.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 6.h),
                        Text(
                          subtitle!,
                          style: AppTypography.lightTextTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            height: 4.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [AppColors.primary.withValues(alpha: 0.2), AppColors.darkSurface]
                    : [AppColors.primary.withValues(alpha: 0.1), AppColors.surface],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          
          // Table Section
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: List.generate(5, (index) => 
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Shimmer.fromColors(
                      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else if (error != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 20.w),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 48.sp),
                    SizedBox(height: 16.h),
                    Text(
                      'Failed to load data',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.error),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else if (data.isEmpty)
            emptyState ?? Padding(
              padding: EdgeInsets.symmetric(vertical: 60.h),
              child: Center(
                child: Text(
                  'No records found.',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                headingRowColor: WidgetStateProperty.resolveWith(
                  (states) => isDark ? AppColors.darkSurfaceDarker : AppColors.surfaceDarker,
                ),
                dataRowColor: WidgetStateProperty.resolveWith(
                  (states) {
                    if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
                      return isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04);
                    }
                    return null;
                  }
                ),
                dividerThickness: 1,
                columns: columns.map((col) => DataColumn(
                  label: Text(
                    col.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                )).toList(),
                rows: data.map((item) => DataRow(
                  onSelectChanged: onRowTap != null ? (_) => onRowTap!(item) : null,
                  cells: rowBuilder(item).map((widget) => DataCell(widget)).toList(),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
