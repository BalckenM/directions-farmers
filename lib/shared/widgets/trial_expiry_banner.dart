import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';

/// A top-of-screen banner shown when the user's trial expires within 7 days.
///
/// Place this widget as the `top` slot in a [Column] inside any shell scaffold,
/// or wrap it in a [AnimatedSwitcher] for a smooth appear/disappear effect.
///
/// The banner is invisible (zero height) when not needed.
class TrialExpiryBanner extends ConsumerWidget {
  const TrialExpiryBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpiring = ref.watch(trialExpiringProvider);
    final daysLeft = ref.watch(trialDaysRemainingProvider);

    if (!isExpiring || daysLeft == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final label = daysLeft == 0
        ? 'Your trial expires today!'
        : 'Trial expires in $daysLeft day${daysLeft == 1 ? '' : 's'}.';

    return MaterialBanner(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      backgroundColor: colorScheme.errorContainer,
      content: Text(
        label,
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
      leading: Icon(
        Icons.warning_amber_rounded,
        color: colorScheme.onErrorContainer,
      ),
      actions: [
        TextButton(
          onPressed: () {
            // TODO(upgrade): Navigate to subscription / upgrade screen.
          },
          child: Text(
            'Upgrade',
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
        ),
      ],
    );
  }
}
