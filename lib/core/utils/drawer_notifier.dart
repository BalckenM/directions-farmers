import 'package:flutter/material.dart';

/// Shared [ValueNotifier] that tracks whether the app navigation drawer is
/// currently open. Written by [FarmScaffold] via [Scaffold.onDrawerChanged]
/// and read by [_AppShell] to hide the floating bottom nav bar while the
/// drawer is visible.
///
/// Exposed as an [InheritedNotifier] so any widget in the tree can listen
/// without needing a ref or prop-drilling.
class DrawerState extends InheritedNotifier<ValueNotifier<bool>> {
  const DrawerState({
    super.key,
    required ValueNotifier<bool> notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// Returns true when the drawer is open.
  static bool isOpen(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<DrawerState>();
    return inherited?.notifier?.value ?? false;
  }

  /// Returns the raw notifier so [FarmScaffold] can write to it.
  static ValueNotifier<bool>? notifierOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DrawerState>()
        ?.notifier;
  }
}
