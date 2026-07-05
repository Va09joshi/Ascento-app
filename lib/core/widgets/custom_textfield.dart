import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ascento_abacus/core/constants/app_sizes.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool isObscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final int minLines;
  final int maxLines;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.isObscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.minLines = 1,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withOpacity(0.85),
          ),
        ),
        AppSizes.h8,
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          enabled: enabled,
          minLines: isObscure ? 1 : minLines,
          maxLines: isObscure ? 1 : maxLines,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor.withOpacity(0.5),
            ),
            fillColor: isDark
                ? theme.colorScheme.primaryContainer
                : AppColors.white,
            filled: true,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: theme.colorScheme.primary, size: 20)
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(
                      suffixIcon,
                      color: theme.colorScheme.secondary,
                      size: 20,
                    ),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.r12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.r12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.r12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.r12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.r12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
