import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shimmer placeholder skeleton for loading states.
///
/// Usage:
/// ```dart
/// AppShimmer(width: 200, height: 20)  // text line
/// AppShimmer.circle(size: 48)          // avatar
/// AppShimmer.card()                    // full card skeleton
/// ```
class AppShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  /// Circular shimmer (avatars, icons)
  factory AppShimmer.circle({Key? key, double size = 48}) {
    return AppShimmer(key: key, width: size, height: size, borderRadius: size / 2);
  }

  /// Full card skeleton with multiple line placeholders
  static Widget card({Key? key}) {
    return Padding(
      key: key,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppShimmer(width: 48, height: 48, borderRadius: 24),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmer(width: 160.w, height: 14),
                    SizedBox(height: 8.h),
                    AppShimmer(width: 100.w, height: 10),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AppShimmer(width: double.infinity, height: 12),
          SizedBox(height: 6.h),
          AppShimmer(width: 240.w, height: 12),
        ],
      ),
    );
  }

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [baseColor, highlightColor, baseColor],
            ),
          ),
        );
      },
    );
  }
}
