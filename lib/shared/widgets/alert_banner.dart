import 'package:flutter/material.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

enum AlertBannerType { info, success, warning, error }

/// An inline alert banner with icon, title, and optional body text.
/// Used for non-blocking contextual feedback inside a screen.
class AlertBanner extends StatelessWidget {
  const AlertBanner({
    super.key,
    required this.type,
    required this.title,
    this.body,
    this.onDismiss,
  });

  final AlertBannerType type;
  final String title;
  final String? body;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _resolve(context);
    final bg = color.withAlpha(25);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: color, fontWeight: FontWeight.w700),
                ),
                if (body != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    body!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: color),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close_rounded, size: 18, color: color),
            ),
        ],
      ),
    );
  }

  (Color, IconData) _resolve(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (type) {
      AlertBannerType.info => (cs.primary, Icons.info_outline_rounded),
      AlertBannerType.success =>
        (const Color(0xFF2E7D32), Icons.check_circle_outline_rounded),
      AlertBannerType.warning =>
        (const Color(0xFFF57F17), Icons.warning_amber_rounded),
      AlertBannerType.error => (cs.error, Icons.error_outline_rounded),
    };
  }
}
