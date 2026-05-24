import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payroll_role.dart';

// ─── Current-user role provider ──────────────────────────────────────────────
// In production this would be populated from the auth token / Firestore user
// document. The provider is overridden at app start once the user signs in.

/// Notifier that holds the authenticated user's payroll role.
class PayrollRoleNotifier extends Notifier<PayrollRole> {
  @override
  PayrollRole build() => PayrollRole.worker; // safe default until auth resolves

  /// Called after sign-in to set the resolved role.
  void setRole(PayrollRole role) => state = role;
}

final payrollRoleProvider =
    NotifierProvider<PayrollRoleNotifier, PayrollRole>(
  PayrollRoleNotifier.new,
);

/// Derived provider: the full permission set for the current user.
final payrollPermissionsProvider = Provider<Set<PayrollPermission>>(
  (ref) => permissionsForRole(ref.watch(payrollRoleProvider)),
);

// ─── Convenience helpers (callable from ConsumerWidget) ──────────────────────
extension PayrollRoleRef on WidgetRef {
  /// Returns true when the current user holds [permission].
  bool can(PayrollPermission permission) =>
      read(payrollPermissionsProvider).contains(permission);

  PayrollRole get payrollRole => read(payrollRoleProvider);
}

// ─── Role-guard widget ───────────────────────────────────────────────────────

/// Renders [child] only when the current user holds ALL [required] permissions.
/// Shows [fallback] (or nothing) otherwise.
class PayrollGuard extends ConsumerWidget {
  const PayrollGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  final PayrollPermission permission;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(payrollPermissionsProvider).contains(permission);
    if (allowed) return child;
    return fallback ?? const SizedBox.shrink();
  }
}

/// Renders [child] when the current user holds ANY of [permissions].
class PayrollGuardAny extends ConsumerWidget {
  const PayrollGuardAny({
    super.key,
    required this.permissions,
    required this.child,
    this.fallback,
  });

  final Set<PayrollPermission> permissions;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPerms = ref.watch(payrollPermissionsProvider);
    if (permissions.any(userPerms.contains)) return child;
    return fallback ?? const SizedBox.shrink();
  }
}

/// Full-screen access-denied placeholder for route-level guards.
class PayrollAccessDeniedScreen extends StatelessWidget {
  const PayrollAccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Access restricted',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'You do not have permission to view this section.\n'
              'Contact your payroll manager or farm owner.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
