import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ListShimmerLoader extends StatelessWidget {
  final int itemCount;
  final double height;
  final EdgeInsetsGeometry? padding;

  const ListShimmerLoader({
    super.key,
    this.itemCount = 5,
    this.height = 70.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView.builder(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
            child: Container(
              height: height.h,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        );
      },
    );
  }
}
