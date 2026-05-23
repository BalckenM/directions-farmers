import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';

@JS('window.triggerPwaInstall')
external JSPromise<JSString> _triggerPwaInstall();

@JS('window.addEventListener')
external void _addWindowListener(String type, JSFunction callback);

/// Shows a Material banner prompting the user to install the PWA.
/// Only active on web. Wrap your top-level [Scaffold] with this widget.
class PwaInstallBanner extends StatefulWidget {
  const PwaInstallBanner({super.key, required this.child});
  final Widget child;

  @override
  State<PwaInstallBanner> createState() => _PwaInstallBannerState();
}

class _PwaInstallBannerState extends State<PwaInstallBanner> {
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _addWindowListener(
        'pwaInstallReady',
        ((JSObject _) {
          if (mounted) setState(() => _showBanner = true);
        }).toJS,
      );
    }
  }

  Future<void> _install() async {
    setState(() => _showBanner = false);
    await _triggerPwaInstall().toDart;
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || !_showBanner) return widget.child;
    return Column(
      children: [
        Material(
          elevation: 2,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.install_mobile_rounded, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Install 4Directions Farm for quick access',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: _install,
                    child: const Text('Install'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _showBanner = false),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
