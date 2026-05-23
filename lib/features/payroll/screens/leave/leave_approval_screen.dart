import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';
import '../../providers/payroll_action_providers.dart';

final _dfAppr = DateFormat('d MMM y');

// Semantic accent color per leave type name
Color _leaveAccentColor(String typeName) {
  final l = typeName.toLowerCase();
  if (l.contains('annual'))                                return PayrollTokens.teal;
  if (l.contains('sick'))                                  return PayrollTokens.rose;
  if (l.contains('maternity') || l.contains('paternity')) return PayrollTokens.purple;
  if (l.contains('family'))                                return PayrollTokens.amber;
  if (l.contains('unpaid'))                                return const Color(0xFF757575);
  if (l.contains('study'))                                 return PayrollTokens.indigo;
  return PayrollTokens.sky;
}

class LeaveApprovalScreen extends ConsumerWidget {
  const LeaveApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending    = ref.watch(pendingLeaveRequestsProvider);
    final employees  = ref.watch(employeesProvider);
    final leaveTypes = ref.watch(leaveTypesProvider);
    final empMap     = {for (final e in employees)  e.id: e};
    final typeMap    = {for (final t in leaveTypes) t.id: t.name};

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Leave Approvals'),
      body: Column(
        children: [
          // ── Prominent count banner ──────────────────────────────────────
          _PendingBanner(count: pending.length),

          // ── List / empty state ─────────────────────────────────────────
          Expanded(
            child: pending.isEmpty
                ? EmptyState(
                    icon: const Icon(Icons.check_circle_outline_rounded,
                        size: 56, color: PayrollTokens.green),
                    title: 'All caught up!',
                    subtitle: 'No pending leave requests.',
                  )
                : RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(pendingLeaveRequestsProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, AppSpacing.md, AppSpacing.md, 100),
                      itemCount: pending.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final r         = pending[i];
                        final emp       = empMap[r.employeeId];
                        final empName   = emp != null
                            ? '${emp.firstName} ${emp.lastName}'
                            : r.employeeId;
                        final initials  = emp != null
                            ? '${emp.firstName.isNotEmpty ? emp.firstName[0] : ''}'
                              '${emp.lastName.isNotEmpty  ? emp.lastName[0]  : ''}'
                              .toUpperCase()
                            : '?';
                        final typeName    = typeMap[r.leaveTypeId] ?? 'Leave';
                        final accentColor = _leaveAccentColor(typeName);

                        return _LeaveApprovalCard(
                          empName:     empName,
                          initials:    initials,
                          typeName:    typeName,
                          request:     r,
                          accentColor: accentColor,
                          onApprove: () async {
                            await ref
                                .read(leaveNotifierProvider.notifier)
                                .approve(r.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('Leave request approved.'),
                                  backgroundColor: PayrollTokens.green,
                                ),
                              );
                            }
                          },
                          onReject: () =>
                              _showRejectSheet(context, ref, r.id),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showRejectSheet(
      BuildContext context, WidgetRef ref, String requestId) {
    final ctrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md,
            AppSpacing.lg,
            MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Reject Leave Request',
                style: Theme.of(ctx)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: ctrl,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: PayrollTokens.rose),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await ref
                        .read(leaveNotifierProvider.notifier)
                        .reject(
                          requestId,
                          ctrl.text.trim().isEmpty
                              ? 'No reason given'
                              : ctrl.text.trim(),
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Leave request rejected.')));
                    }
                  },
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Reject'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── Pending count banner ─────────────────────────────────────────────────────

class _PendingBanner extends StatelessWidget {
  const _PendingBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final hasPending = count > 0;
    final bg    = hasPending ? PayrollTokens.amber : PayrollTokens.green;
    final icon  = hasPending
        ? Icons.pending_actions_rounded
        : Icons.check_circle_rounded;
    final label = hasPending
        ? '$count request${count == 1 ? '' : 's'} pending approval'
        : 'No pending requests';

    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: tt.labelMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          if (hasPending)
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: tt.labelMedium?.copyWith(
                    color: PayrollTokens.amber,
                    fontWeight: FontWeight.w900),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Leave approval card ──────────────────────────────────────────────────────

class _LeaveApprovalCard extends StatelessWidget {
  const _LeaveApprovalCard({
    required this.empName,
    required this.initials,
    required this.typeName,
    required this.request,
    required this.accentColor,
    required this.onApprove,
    required this.onReject,
  });

  final String       empName;
  final String       initials;
  final String       typeName;
  final dynamic      request;
  final Color        accentColor;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accent bar per leave type
            Container(width: 4, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Employee row
                    Row(children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: accentColor.withValues(alpha: 0.12),
                        child: Text(initials,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                              fontSize: 13,
                            )),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(empName,
                                style: tt.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              '${_dfAppr.format(request.startDate)}'
                              ' \u2013 '
                              '${_dfAppr.format(request.endDate)}',
                              style: tt.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      // Days badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: accentColor.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          '${request.daysRequested.toStringAsFixed(0)}d',
                          style: tt.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: accentColor),
                        ),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.sm),

                    // Leave type + reason
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm - 1, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: accentColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(typeName,
                            style: tt.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: accentColor)),
                      ),
                      if (request.reason.isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            request.reason,
                            style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontStyle: FontStyle.italic),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ]),
                    const SizedBox(height: AppSpacing.sm),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: PayrollTokens.rose,
                              side: const BorderSide(
                                  color: PayrollTokens.rose)),
                          onPressed: onReject,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        FilledButton.icon(
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: const Text('Approve'),
                          style: FilledButton.styleFrom(
                              backgroundColor: PayrollTokens.green),
                          onPressed: onApprove,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
