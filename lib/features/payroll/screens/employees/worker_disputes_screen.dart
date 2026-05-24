// Worker Disputes screen — view, file and manage payroll grievances.
//
// Farm workers can file disputes about pay, leave, overtime, and deductions.
// Supervisors and payroll managers can update dispute status.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/farm_text_field.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/worker_dispute.dart';
import '../../providers/dispute_provider.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

final _dateFmt = DateFormat('dd MMM yyyy');

// ─── Color mapping ─────────────────────────────────────────────────────────────

Color _statusColor(DisputeStatus s) => switch (s) {
      DisputeStatus.open        => PayrollTokens.rose,
      DisputeStatus.underReview => PayrollTokens.amber,
      DisputeStatus.resolved    => PayrollTokens.green,
      DisputeStatus.dismissed   => const Color(0xFF9E9E9E),
    };

// =============================================================================

class WorkerDisputesScreen extends ConsumerStatefulWidget {
  const WorkerDisputesScreen({super.key});

  @override
  ConsumerState<WorkerDisputesScreen> createState() =>
      _WorkerDisputesScreenState();
}

class _WorkerDisputesScreenState
    extends ConsumerState<WorkerDisputesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<WorkerDispute> _filter(
      List<WorkerDispute> all, int tabIndex) {
    return switch (tabIndex) {
      0 => all,
      1 => all.where((d) => d.status == DisputeStatus.open).toList(),
      2 => all.where((d) => d.status == DisputeStatus.underReview).toList(),
      3 => all.where((d) => d.status.isClosed).toList(),
      _ => all,
    };
  }

  @override
  Widget build(BuildContext context) {
    final all    = ref.watch(disputeProvider);
    final theme  = Theme.of(context);
    final cs     = theme.colorScheme;
    final openN  = all.where((d) => d.status == DisputeStatus.open).length;

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Worker Disputes'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:       () => _showFileDisputeSheet(context),
        label:           const Text('File Dispute'),
        icon:            const Icon(Icons.add_rounded),
        backgroundColor: PayrollTokens.navy,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── Summary header ──────────────────────────────────────────────
          _SummaryHeader(total: all.length, openCount: openN),
          // ── Tab bar ─────────────────────────────────────────────────────
          Container(
            color: cs.surface,
            child: TabBar(
              controller: _tabs,
              labelColor:          PayrollTokens.navy,
              unselectedLabelColor: cs.onSurfaceVariant,
              indicatorColor:      PayrollTokens.navy,
              indicatorWeight:     2.5,
              labelStyle:          theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              tabs: [
                const Tab(text: 'All'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Open'),
                      if (openN > 0) ...[
                        const SizedBox(width: 4),
                        _TabBadge(count: openN, color: PayrollTokens.rose),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'In Review'),
                const Tab(text: 'Closed'),
              ],
            ),
          ),
          // ── Tab views ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: List.generate(4, (i) {
                final filtered = _filter(all, i);
                if (filtered.isEmpty) {
                  return _EmptyTab(tabIndex: i);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md, AppSpacing.md, 96,
                  ),
                  itemCount:        filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) => _DisputeTile(
                    dispute:  filtered[idx],
                    onTap:    () => _showUpdateSheet(context, filtered[idx]),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── File dispute bottom sheet ──────────────────────────────────────────────

  void _showFileDisputeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context:    context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FileDisputeSheet(
        onFiled: (employeeId, employeeName, type, description) {
          ref.read(disputeProvider.notifier).fileDispute(
                employeeId:   employeeId,
                employeeName: employeeName,
                type:         type,
                description:  description,
              );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dispute filed successfully.')),
          );
        },
      ),
    );
  }

  // ── Update status bottom sheet ─────────────────────────────────────────────

  void _showUpdateSheet(BuildContext context, WorkerDispute dispute) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _UpdateStatusSheet(
        dispute:  dispute,
        onUpdate: (newStatus) {
          ref.read(disputeProvider.notifier).updateStatus(
                disputeId:  dispute.id,
                newStatus:  newStatus,
                resolvedBy: 'Manager',
              );
        },
      ),
    );
  }
}

// ─── Summary header ────────────────────────────────────────────────────────────

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.total, required this.openCount});

  final int total;
  final int openCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 14, AppSpacing.md, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PayrollTokens.navy, Color.fromARGB(255, 46, 89, 132)],
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          _SummaryChip(
            icon:  Icons.gavel_outlined,
            label: 'Total',
            value: '$total',
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          _SummaryChip(
            icon:  Icons.radio_button_unchecked_rounded,
            label: 'Open',
            value: '$openCount',
            color: const Color(0xFFFF7043),
          ),
          const SizedBox(width: 12),
          _SummaryChip(
            icon:  Icons.check_circle_outline,
            label: 'Resolved',
            value: '${total - openCount}',
            color: const Color(0xFF81C784),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:        Colors.white.withAlpha(18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: tt.titleSmall?.copyWith(
                  color:      Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: tt.labelSmall?.copyWith(
                  color: Colors.white.withAlpha(160),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Tab badge ─────────────────────────────────────────────────────────────────

class _TabBadge extends StatelessWidget {
  const _TabBadge({required this.count, required this.color});

  final int   count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color:        color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize:   10,
          color:      Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Dispute tile ──────────────────────────────────────────────────────────────

class _DisputeTile extends StatelessWidget {
  const _DisputeTile({required this.dispute, required this.onTap});

  final WorkerDispute dispute;
  final VoidCallback  onTap;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final cs     = theme.colorScheme;
    final color  = _statusColor(dispute.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        cs.surface,
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withAlpha(10),
              blurRadius: 6,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width:  38,
                  height: 38,
                  decoration: BoxDecoration(
                    color:        color.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.gavel_outlined, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dispute.employeeName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        dispute.type.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  label: dispute.status.label,
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // description
            Text(
              dispute.description,
              maxLines:  2,
              overflow:  TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color:  cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            // footer
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size:  13,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Filed ${_dateFmt.format(dispute.filedAt)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                if (dispute.resolvedBy != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.person_outline, size: 13, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    dispute.resolvedBy!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
                const Spacer(),
                Icon(Icons.chevron_right_rounded, size: 16, color: cs.outlineVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty tab ────────────────────────────────────────────────────────────────

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.tabIndex});

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    final (icon, title, subtitle) = switch (tabIndex) {
      1 => (
          Icons.check_circle_outline,
          'No open disputes',
          'All disputes have been addressed.',
        ),
      2 => (
          Icons.manage_search_outlined,
          'Nothing in review',
          'Disputes under review will appear here.',
        ),
      3 => (
          Icons.archive_outlined,
          'No closed disputes',
          'Resolved and dismissed disputes appear here.',
        ),
      _ => (
          Icons.gavel_outlined,
          'No disputes filed',
          'Tap the button below to file a new dispute.',
        ),
    };

    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: EmptyState(
        icon:     Icon(icon, size: 56),
        title:    title,
        subtitle: subtitle,
      ),
    );
  }
}

// ─── File dispute bottom sheet ─────────────────────────────────────────────────

class _FileDisputeSheet extends ConsumerStatefulWidget {
  const _FileDisputeSheet({required this.onFiled});

  final void Function(
    String employeeId,
    String employeeName,
    DisputeType type,
    String description,
  ) onFiled;

  @override
  ConsumerState<_FileDisputeSheet> createState() => _FileDisputeSheetState();
}

class _FileDisputeSheetState extends ConsumerState<_FileDisputeSheet> {
  final _desc = TextEditingController();
  String?        _selectedEmployeeId;
  String?        _selectedEmployeeName;
  DisputeType    _type = DisputeType.payDiscrepancy;

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedEmployeeId == null || _desc.text.trim().isEmpty) return;
    widget.onFiled(
      _selectedEmployeeId!,
      _selectedEmployeeName!,
      _type,
      _desc.text.trim(),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(activeEmployeesProvider);
    final theme     = Theme.of(context);
    final cs        = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.md, AppSpacing.md,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // sheet handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color:        cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color:        PayrollTokens.navy.withAlpha(18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.gavel_outlined, size: 18, color: PayrollTokens.navy),
              ),
              const SizedBox(width: 12),
              Text(
                'File a Dispute',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Employee dropdown
          Text('Employee', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border:         OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            hint:    const Text('Select employee'),
            initialValue:   _selectedEmployeeId,
            items: employees.map((e) {
              return DropdownMenuItem(
                value: e.id,
                child: Text('${e.firstName} ${e.lastName}'),
              );
            }).toList(),
            onChanged: (v) {
              if (v == null) return;
              final emp = employees.firstWhere((e) => e.id == v);
              setState(() {
                _selectedEmployeeId   = v;
                _selectedEmployeeName = '${emp.firstName} ${emp.lastName}';
              });
            },
          ),
          const SizedBox(height: 14),

          // Dispute type dropdown
          Text('Dispute Type', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          DropdownButtonFormField<DisputeType>(
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            initialValue: _type,
            items: DisputeType.values.map((t) {
              return DropdownMenuItem(value: t, child: Text(t.label));
            }).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _type = v);
            },
          ),
          const SizedBox(height: 14),

          // Description
          FarmTextField(
            controller: _desc,
            label:      'Description',
            hint:       'Describe the dispute in detail…',
            maxLines:   4,
            minLines:   3,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 18),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: PayrollTokens.navy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: (_selectedEmployeeId != null &&
                      _desc.text.trim().isNotEmpty)
                  ? _submit
                  : null,
              child: const Text('Submit Dispute'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Update status bottom sheet ───────────────────────────────────────────────

class _UpdateStatusSheet extends StatelessWidget {
  const _UpdateStatusSheet({required this.dispute, required this.onUpdate});

  final WorkerDispute            dispute;
  final void Function(DisputeStatus) onUpdate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color:        cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color:        PayrollTokens.navy.withAlpha(18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.update_rounded,
                  size: 18,
                  color: PayrollTokens.navy,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Status',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      dispute.employeeName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          ...DisputeStatus.values.map((s) {
            final active = dispute.status == s;
            final color  = _statusColor(s);
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              dense:      true,
              leading: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color:        color.withAlpha(active ? 40 : 18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  active
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size:  18,
                  color: color,
                ),
              ),
              title: Text(
                s.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                  color:      active ? color : cs.onSurface,
                ),
              ),
              onTap: () {
                if (!active) onUpdate(s);
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
