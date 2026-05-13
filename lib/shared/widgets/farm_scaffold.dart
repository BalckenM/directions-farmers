import 'package:flutter/material.dart';
import 'farm_drawer.dart';
import 'offline_banner.dart';

/// A [Scaffold] wrapper that inserts the [OfflineBanner] above the [body]
/// and enforces consistent background colour from the theme.
///
/// [drawer] defaults to [FarmDrawer] so every screen gets sidebar navigation
/// automatically. Pass `drawer: null` explicitly to suppress it.
class FarmScaffold extends StatelessWidget {
  const FarmScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer = const FarmDrawer(),
    this.resizeToAvoidBottomInset = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: body),
        ],
      ),
    );
  }
}
