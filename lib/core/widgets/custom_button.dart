import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ascento_abacus/core/constants/app_sizes.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isLoading;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isSecondary = false,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color buttonColor = widget.isSecondary
        ? (isDark
              ? theme.colorScheme.surface
              : theme.colorScheme.primaryContainer)
        : theme.colorScheme.primary;

    final Color textColor = widget.isSecondary
        ? theme.colorScheme.primary
        : theme.colorScheme.onPrimary;

    final borderSide = widget.isSecondary
        ? BorderSide(color: theme.colorScheme.primary, width: 1.8)
        : BorderSide.none;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: AppSizes.buttonHeight,
          decoration: BoxDecoration(
            color: widget.onPressed == null
                ? theme.disabledColor.withOpacity(0.12)
                : buttonColor,
            borderRadius: BorderRadius.circular(AppSizes.r8),
            border: Border.fromBorderSide(
              widget.onPressed == null ? BorderSide.none : borderSide,
            ),
            boxShadow: widget.onPressed == null || widget.isSecondary
                ? []
                : [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 20, color: textColor),
                        AppSizes.w8,
                      ],
                      Text(
                        widget.text,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: widget.onPressed == null
                              ? theme.disabledColor
                              : textColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
