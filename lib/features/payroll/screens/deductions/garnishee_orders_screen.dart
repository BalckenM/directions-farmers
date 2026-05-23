// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/garnishee_order.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

typedef _C = PayrollTokens;

final _zar = NumberFormat.currency(
  locale: 'en_ZA',
  symbol: 'R ',
  decimalDigits: 0,
);
final _mFmt = DateFormat('d MMM y');

// ─────────────────────────────────────────────────────────────────────────────
// Garnishee Orders List Screen
// ─────────────────────────────────────────────────────────────────────────────

class GarnisheeOrdersScreen extends ConsumerStatefulWidget {
  /// When provided, filters to a specific employee's orders.
  const GarnisheeOrdersScreen({super.key, this.employeeId});
  final String? employeeId;

  @override
  ConsumerState<GarnisheeOrdersScreen> createState() =>
      _GarnisheeOrdersScreenState();
}

class _GarnisheeOrdersScreenState extends ConsumerState<GarnisheeOrdersScreen> {
  String _search = '';

  static const _statuses = [
    (label: 'All', status: null),
    (label: 'Active', status: GarnisheeStatus.active),
    (label: 'Satisfied', status: GarnisheeStatus.satisfied),
    (label: 'Suspended', status: GarnisheeStatus.suspended),
    (label: 'Cancelled', status: GarnisheeStatus.cancelled),
  ];

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(garnisheeOrdersProvider(widget.employeeId));
    final employees = ref.watch(employeesProvider);
    final empMap = {for (final e in employees) e.id: e.fullName};

    final title = widget.employeeId != null
        ? '${empMap[widget.employeeId] ?? 'Employee'} — Orders'
        : 'Garnishee Orders';

    return DefaultTabController(
      length: _statuses.length,
      child: FarmScaffold(
      appBar: FarmAppBar(
        title: title,
        bottom: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _statuses.map((t) {
            final count = t.status == null
                ? orders.length
                : orders.where((o) => o.status == t.status).length;
            return Tab(text: '${t.label} ($count)');
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.payrollGarnisheeAdd),
        icon: const Icon(Icons.add),
        label: const Text('Add Order'),
        backgroundColor: _C.navy,
      ),
      body: Column(
        children: [
          _SearchBar(onChanged: (v) => setState(() => _search = v)),
          Expanded(
            child: TabBarView(
              children: _statuses.map((t) {
                var filtered = t.status == null
                    ? orders
                    : orders.where((o) => o.status == t.status).toList();
                if (_search.isNotEmpty) {
                  final q = _search.toLowerCase();
                  filtered = filtered.where((o) {
                    final name = (empMap[o.employeeId] ?? '').toLowerCase();
                    return o.creditorName.toLowerCase().contains(q) ||
                        o.courtOrderRef.toLowerCase().contains(q) ||
                        name.contains(q);
                  }).toList();
                }
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: const Icon(Icons.gavel_outlined),
                    title: 'No ${t.label.toLowerCase()} garnishee orders',
                    subtitle:
                        'Court emoluments attachment orders will appear here.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _GarnisheeCard(
                    order: filtered[i],
                    empName:
                        empMap[filtered[i].employeeId] ??
                        filtered[i].employeeId,
                    onTap: () => context.push(
                      AppRoutes.payrollGarnisheeDetail(filtered[i].id),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search by creditor, reference, employee…',
          prefixIcon: const Icon(Icons.search, size: 20),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Garnishee Card
// ─────────────────────────────────────────────────────────────────────────────

class _GarnisheeCard extends StatelessWidget {
  const _GarnisheeCard({
    required this.order,
    required this.empName,
    required this.onTap,
  });
  final GarnisheeOrder order;
  final String empName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final (statusColor, statusLabel) = _statusStyle(order.status);
    final pct = order.totalOwed > 0
        ? (order.amountDeducted / order.totalOwed).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: order.isActive
            ? BorderSide(color: _C.rose.withValues(alpha: 0.4), width: 1.5)
            : BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _C.rose.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.gavel_outlined,
                      size: 18,
                      color: _C.rose,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.creditorName,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          order.courtOrderRef,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(label: statusLabel, color: statusColor),
                ],
              ),
              const SizedBox(height: 10),
              // Employee row
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    empName,
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Text(
                    '${_zar.format(order.monthlyDeductionAmount)}/mo',
                    style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _C.rose,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recovered',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${_zar.format(order.amountDeducted)} / ${_zar.format(order.totalOwed)}',
                              style: tt.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6,
                            backgroundColor: cs.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                            valueColor: AlwaysStoppedAnimation(
                              pct >= 1.0 ? _C.green : _C.rose,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, String) _statusStyle(GarnisheeStatus s) => switch (s) {
    GarnisheeStatus.active => (_C.rose, 'Active'),
    GarnisheeStatus.satisfied => (_C.green, 'Satisfied'),
    GarnisheeStatus.suspended => (_C.amber, 'Suspended'),
    GarnisheeStatus.cancelled => (const Color(0xFF757575), 'Cancelled'),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Garnishee Order Detail Screen
// ─────────────────────────────────────────────────────────────────────────────

class GarnisheeDetailScreen extends ConsumerWidget {
  const GarnisheeDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(garnisheeByIdProvider(orderId));
    if (order == null) {
      return FarmScaffold(
        appBar: const FarmAppBar(title: 'Garnishee Order'),
        body: const EmptyState(
          icon: Icon(Icons.search_off_outlined),
          title: 'Order not found',
          subtitle: 'This garnishee order no longer exists.',
        ),
      );
    }
    final employees = ref.watch(employeesProvider);
    final empMap = {for (final e in employees) e.id: e.fullName};
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final pct = order.totalOwed > 0
        ? (order.amountDeducted / order.totalOwed).clamp(0.0, 1.0)
        : 0.0;
    final (statusColor, statusLabel) = _statusStyle(order.status);

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Garnishee Order',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit order',
            onPressed: () =>
                context.push(AppRoutes.payrollGarnisheeEdit(order.id)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Status card ────────────────────────────────────────────────
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: order.isActive
                  ? BorderSide(
                      color: _C.rose.withValues(alpha: 0.4),
                      width: 1.5,
                    )
                  : BorderSide(color: cs.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.gavel_outlined,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              statusLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _zar.format(order.monthlyDeductionAmount),
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: _C.rose,
                        ),
                      ),
                      Text(
                        ' / mo',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    order.creditorName,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Ref: ${order.courtOrderRef}',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Recovery progress ─────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(
                  title: 'Recovery Progress',
                  icon: Icons.trending_up_outlined,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _AmtBlock(
                      label: 'Total Owed',
                      value: _zar.format(order.totalOwed),
                      color: cs.onSurface,
                    ),
                    _AmtBlock(
                      label: 'Recovered',
                      value: _zar.format(order.amountDeducted),
                      color: _C.green,
                    ),
                    _AmtBlock(
                      label: 'Outstanding',
                      value: _zar.format(order.outstandingBalance),
                      color: _C.rose,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 10,
                    backgroundColor: cs.outlineVariant.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation(
                      pct >= 1.0 ? _C.green : _C.rose,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${(pct * 100).toStringAsFixed(0)}% recovered',
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Details ────────────────────────────────────────────────────
          _SectionCard(
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.person_outline,
                  label: 'Employee',
                  value: empMap[order.employeeId] ?? order.employeeId,
                ),
                _divider(),
                _DetailRow(
                  icon: Icons.business_outlined,
                  label: 'Creditor',
                  value: order.creditorName,
                ),
                _divider(),
                _DetailRow(
                  icon: Icons.gavel_outlined,
                  label: 'Court Order Ref',
                  value: order.courtOrderRef,
                ),
                _divider(),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Registered',
                  value: _mFmt.format(order.createdAt),
                ),
                if (order.satisfiedAt != null) ...[
                  _divider(),
                  _DetailRow(
                    icon: Icons.check_circle_outline,
                    label: 'Satisfied On',
                    value: _mFmt.format(order.satisfiedAt!),
                  ),
                ],
              ],
            ),
          ),

          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: 'Notes', icon: Icons.notes_outlined),
                  const SizedBox(height: 8),
                  Text(
                    order.notes!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 28);

  (Color, String) _statusStyle(GarnisheeStatus s) => switch (s) {
    GarnisheeStatus.active => (_C.rose, 'Active'),
    GarnisheeStatus.satisfied => (_C.green, 'Satisfied'),
    GarnisheeStatus.suspended => (_C.amber, 'Suspended'),
    GarnisheeStatus.cancelled => (const Color(0xFF757575), 'Cancelled'),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          title,
          style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _AmtBlock extends StatelessWidget {
  const _AmtBlock({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(
            label,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
