import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static DeviceType getDeviceType(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    if (width >= 1024) {
      return DeviceType.desktop;
    } else if (width >= 600) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  static bool isMobile(BuildContext context) => getDeviceType(context) == DeviceType.mobile;
  static bool isTablet(BuildContext context) => getDeviceType(context) == DeviceType.tablet;
  static bool isDesktop(BuildContext context) => getDeviceType(context) == DeviceType.desktop;

  static double horizontalPadding(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.desktop:
        return 32;
      case DeviceType.tablet:
        return 24;
      case DeviceType.mobile:
        return 16;
    }
  }

  static double contentMaxWidth(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.desktop:
        return 960;
      case DeviceType.tablet:
        return 760;
      case DeviceType.mobile:
        return MediaQuery.sizeOf(context).width;
    }
  }

  static double formMaxWidth(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.desktop:
        return 720;
      case DeviceType.tablet:
        return 640;
      case DeviceType.mobile:
        return MediaQuery.sizeOf(context).width;
    }
  }

  static int adaptiveColumns(
    BuildContext context, {
    double minTileWidth = 180,
    int minColumns = 1,
    int? maxColumns,
  }) {
    final width = contentMaxWidth(context);
    final computed = (width / minTileWidth).floor().clamp(minColumns, maxColumns ?? 6);
    return computed;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        if (width >= 1024) {
          return desktop ?? tablet ?? mobile;
        } else if (width >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedPadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveBuilder.horizontalPadding(context),
          vertical: 16,
        );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? ResponsiveBuilder.contentMaxWidth(context),
        ),
        child: Padding(
          padding: resolvedPadding,
          child: child,
        ),
      ),
    );
  }
}
