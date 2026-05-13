import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';

/// Standalone [NavigationBar] widget with farm-specific tab definitions.
///
/// This widget is used by [AppRouter]'s shell route when a custom widget
/// reference is needed (e.g. in tests or previews). In production the router
/// manages this widget directly inside `_AppShell`.
class FarmBottomNav extends StatelessWidget {
  const FarmBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const List<NavigationDestination> destinations = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard_rounded),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.pets_outlined),
      selectedIcon: Icon(Icons.pets_rounded),
      label: 'Livestock',
    ),
    NavigationDestination(
      icon: Icon(Icons.health_and_safety_outlined),
      selectedIcon: Icon(Icons.health_and_safety_rounded),
      label: 'Health',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart_rounded),
      label: 'Reports',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: AppSpacing.minTouchTarget * 1.7,
    );
  }
}
