import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import 'icon_action_button.dart';

/// A styled [AppBar] consistent with the farm design system.
///
/// Provides convenience parameters for common patterns: back button, search,
/// notifications, and an avatar trailing widget.
class FarmAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FarmAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.onSearch,
    this.bottom,
    this.centerTitle = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onSearch;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    Widget titleWidget;
    if (subtitle != null) {
      titleWidget = Column(
        crossAxisAlignment:
            centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          Text(
            subtitle!,
            style: tt.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      );
    } else {
      titleWidget = Text(title,
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800));
    }

    final resolvedActions = <Widget>[
      if (onSearch != null)
        IconActionButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: onSearch,
          tooltip: 'Search',
        ),
      ...?actions,
      const SizedBox(width: AppSpacing.xs),
    ];

    return AppBar(
      title: titleWidget,
      leading: leading ?? (context.canPop() ? BackButton(onPressed: context.pop) : null),
      centerTitle: centerTitle,
      actions: resolvedActions.isEmpty ? null : resolvedActions,
      bottom: bottom,
      scrolledUnderElevation: 1,
    );
  }
}
