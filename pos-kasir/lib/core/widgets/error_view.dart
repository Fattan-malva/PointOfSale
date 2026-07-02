import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// ErrorView - Error State UI
class ErrorView extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    this.title = 'Terjadi Kesalahan',
    this.subtitle,
    this.buttonLabel = 'Coba Lagi',
    this.onButtonPressed,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.space4),
          Text(title, style: AppTypography.title, textAlign: TextAlign.center),
          if (subtitle != null || message != null) ...[
            const SizedBox(height: AppSpacing.space2),
            Text(
              subtitle ?? message!,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (buttonLabel != null) ...[
            const SizedBox(height: AppSpacing.space6),
            ElevatedButton(
              onPressed: onButtonPressed ?? onRetry,
              child: Text(buttonLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
