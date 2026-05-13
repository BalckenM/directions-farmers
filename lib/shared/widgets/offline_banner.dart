import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/connectivity_service.dart';

/// Slides in from the top when the device goes offline and hides when
/// connectivity is restored. Wraps a Riverpod [isOnlineProvider] watch.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          SizeTransition(sizeFactor: animation, child: child),
      child: isOnline
          ? const SizedBox.shrink()
          : _Banner(key: const ValueKey('offline')),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: cs.errorContainer,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: cs.onErrorContainer),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'You are offline — showing cached data',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: cs.onErrorContainer),
          ),
        ],
      ),
    );
  }
}
