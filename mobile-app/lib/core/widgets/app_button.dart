import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outlined, danger, text }

/// TravelPulse LK — Primary Interactive Button Component
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = onPressed != null && !isLoading;
    final double buttonHeight = height ?? AppSpacing.buttonHeight;

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor()),
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
        ] else if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 18, color: _getContentColor(isInteractive)),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          text,
          style: AppTypography.labelLarge.copyWith(
            color: _getContentColor(isInteractive),
          ),
        ),
        if (!isLoading && trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Icon(trailingIcon, size: 18, color: _getContentColor(isInteractive)),
        ],
      ],
    );

    Widget button;

    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isInteractive ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
            minimumSize: Size(isFullWidth ? double.infinity : 0, buttonHeight),
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
          ),
          child: content,
        );
        break;

      case AppButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isInteractive ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            disabledBackgroundColor: AppColors.primaryContainer.withOpacity(0.5),
            elevation: 0,
            minimumSize: Size(isFullWidth ? double.infinity : 0, buttonHeight),
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
          ),
          child: content,
        );
        break;

      case AppButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isInteractive ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(
              color: isInteractive ? AppColors.primary : AppColors.borderDark,
              width: 1.5,
            ),
            minimumSize: Size(isFullWidth ? double.infinity : 0, buttonHeight),
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
          ),
          child: content,
        );
        break;

      case AppButtonVariant.danger:
        button = ElevatedButton(
          onPressed: isInteractive ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            disabledBackgroundColor: AppColors.error.withOpacity(0.5),
            minimumSize: Size(isFullWidth ? double.infinity : 0, buttonHeight),
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
          ),
          child: content,
        );
        break;

      case AppButtonVariant.text:
        button = TextButton(
          onPressed: isInteractive ? onPressed : null,
          style: TextButton.styleFrom(
            minimumSize: Size(isFullWidth ? double.infinity : 0, buttonHeight),
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
          ),
          child: content,
        );
        break;
    }

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  Color _getContentColor(bool isInteractive) {
    if (!isInteractive && variant != AppButtonVariant.text) {
      return AppColors.textInverse.withOpacity(0.8);
    }
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return AppColors.textInverse;
      case AppButtonVariant.secondary:
        return AppColors.primaryDark;
      case AppButtonVariant.outlined:
        return AppColors.primary;
      case AppButtonVariant.text:
        return isInteractive ? AppColors.primary : AppColors.textMuted;
    }
  }

  Color _getLoadingColor() {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return AppColors.textInverse;
      case AppButtonVariant.secondary:
      case AppButtonVariant.outlined:
      case AppButtonVariant.text:
        return AppColors.primary;
    }
  }
}

