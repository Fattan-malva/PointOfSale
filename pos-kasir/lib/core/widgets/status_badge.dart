import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// StatusBadge - Chip/Badge Component dengan Semantic Colors
class StatusBadge extends StatelessWidget {
  final String label;
  final AppBadgeStatus status;
  final VoidCallback? onTap;
  final bool removable;
  final VoidCallback? onRemove;

  const StatusBadge({
    super.key,
    required this.label,
    required this.status,
    this.onTap,
    this.removable = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, textColor) = _getColors();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(color: textColor),
            ),
            if (removable) ...[
              const SizedBox(width: AppSpacing.space1),
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.close, size: 14, color: textColor),
              ),
            ],
          ],
        ),
      ),
    );
  }

  (Color, Color) _getColors() {
    return switch (status) {
      AppBadgeStatus.success => (AppColors.successSoft, AppColors.success),
      AppBadgeStatus.warning => (AppColors.warningSoft, AppColors.warning),
      AppBadgeStatus.error => (AppColors.errorSoft, AppColors.error),
      AppBadgeStatus.info => (AppColors.accentSoft, AppColors.accent),
      AppBadgeStatus.neutral => (AppColors.surface, AppColors.textSecondary),
    };
  }
}

enum AppBadgeStatus { success, warning, error, info, neutral }
