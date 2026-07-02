import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_shadows.dart';

/// AppCard - Base Card Component dengan Soft Shadow
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Color backgroundColor;
  final BoxShadow? shadow;
  final VoidCallback? onTap;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.backgroundColor = AppColors.surfaceRaised,
    this.shadow,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppSpacing.radiusLg;
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.space4);
    final effectiveShadow = shadow ?? AppShadows.md;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(effectiveRadius),
          boxShadow: [effectiveShadow],
          border: border,
        ),
        padding: effectivePadding,
        child: child,
      ),
    );
  }
}
