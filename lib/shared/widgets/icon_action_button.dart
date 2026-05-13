import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';

/// Circular icon button with an optional tooltip, respecting minimum touch
/// target size from the design system.
class IconActionButton extends StatelessWidget {
  const IconActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.size = AppSpacing.minTouchTarget,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          icon: IconTheme(
            data: IconThemeData(color: color),
            child: icon,
          ),
          onPressed: onPressed,
          padding: EdgeInsets.zero,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
