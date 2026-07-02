import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// AppButton - Reusable Button Component
/// Variants: primary, secondary, outline, text
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final AppButtonVariant variant;
  final double? width;
  final double? height;
  final Widget? leftIcon;
  final Widget? rightIcon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height,
    this.leftIcon,
    this.rightIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isButtonDisabled = !isEnabled || isLoading;
    final effectiveOnPressed = isButtonDisabled ? null : onPressed;

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: switch (variant) {
        AppButtonVariant.primary => _PrimaryButton(
          label: label,
          onPressed: effectiveOnPressed,
          isLoading: isLoading,
          isEnabled: isEnabled,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
        ),
        AppButtonVariant.secondary => _SecondaryButton(
          label: label,
          onPressed: effectiveOnPressed,
          isLoading: isLoading,
          isEnabled: isEnabled,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
        ),
        AppButtonVariant.outline => _OutlineButton(
          label: label,
          onPressed: effectiveOnPressed,
          isLoading: isLoading,
          isEnabled: isEnabled,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
        ),
        AppButtonVariant.text => _TextButton(
          label: label,
          onPressed: effectiveOnPressed,
          isLoading: isLoading,
          isEnabled: isEnabled,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
        ),
      },
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Widget? leftIcon;
  final Widget? rightIcon;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.isEnabled,
    required this.leftIcon,
    required this.rightIcon,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isEnabled ? AppColors.accent : AppColors.textDisabled,
        foregroundColor: AppColors.inverseText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.inverseText,
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leftIcon != null) ...[
                  leftIcon!,
                  const SizedBox(width: AppSpacing.space2),
                ],
                Text(label, style: AppTypography.body),
                if (rightIcon != null) ...[
                  const SizedBox(width: AppSpacing.space2),
                  rightIcon!,
                ],
              ],
            ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Widget? leftIcon;
  final Widget? rightIcon;

  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.isEnabled,
    required this.leftIcon,
    required this.rightIcon,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isEnabled ? AppColors.surface : AppColors.surface,
        foregroundColor: isEnabled
            ? AppColors.textPrimary
            : AppColors.textDisabled,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textPrimary,
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leftIcon != null) ...[
                  leftIcon!,
                  const SizedBox(width: AppSpacing.space2),
                ],
                Text(label, style: AppTypography.body),
                if (rightIcon != null) ...[
                  const SizedBox(width: AppSpacing.space2),
                  rightIcon!,
                ],
              ],
            ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Widget? leftIcon;
  final Widget? rightIcon;

  const _OutlineButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.isEnabled,
    required this.leftIcon,
    required this.rightIcon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isEnabled ? AppColors.border : AppColors.textDisabled,
        ),
        foregroundColor: isEnabled
            ? AppColors.textPrimary
            : AppColors.textDisabled,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textPrimary,
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leftIcon != null) ...[
                  leftIcon!,
                  const SizedBox(width: AppSpacing.space2),
                ],
                Text(label, style: AppTypography.body),
                if (rightIcon != null) ...[
                  const SizedBox(width: AppSpacing.space2),
                  rightIcon!,
                ],
              ],
            ),
    );
  }
}

class _TextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Widget? leftIcon;
  final Widget? rightIcon;

  const _TextButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.isEnabled,
    required this.leftIcon,
    required this.rightIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isEnabled ? AppColors.accent : AppColors.textDisabled,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leftIcon != null) ...[
                  leftIcon!,
                  const SizedBox(width: AppSpacing.space2),
                ],
                Text(label, style: AppTypography.body),
                if (rightIcon != null) ...[
                  const SizedBox(width: AppSpacing.space2),
                  rightIcon!,
                ],
              ],
            ),
    );
  }
}

enum AppButtonVariant { primary, secondary, outline, text }
