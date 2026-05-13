import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

/// Centred error state with icon, message, and retry / report actions.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.message,
    this.onRetry,
    this.onReport,
  });

  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 44,
                      color: cs.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Something went wrong',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    message ?? 'An unexpected error occurred. Please try again.',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  if (onRetry != null || onReport != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onReport != null)
                          SecondaryButton(
                            label: 'Report',
                            onPressed: onReport,
                          ),
                        if (onReport != null && onRetry != null)
                          const SizedBox(width: AppSpacing.md),
                        if (onRetry != null)
                          PrimaryButton(
                            label: 'Try again',
                            onPressed: onRetry,
                            isExpanded: false,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
