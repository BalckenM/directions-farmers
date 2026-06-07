import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:mobile_app/core/router/app_routes.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';
import 'package:mobile_app/features/payroll/models/piecework_log.dart';
import 'package:mobile_app/features/payroll/providers/payroll_action_providers.dart';
import 'package:mobile_app/features/payroll/providers/payroll_providers.dart';

final _zar = NumberFormat.currency(
  locale: 'en_ZA',
  symbol: 'R ',
  decimalDigits: 2,
);
final _dateFmt = DateFormat('d MMM y');

class PieceworkLogsScreen extends ConsumerWidget {
  const PieceworkLogsScreen({super.key, this.employeeId});

  final String? employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = PieceworkFilter(employeeId: employeeId);
    final logs = ref.watch(pieceworkLogsProvider(filter));
    final employees = ref.watch(activeEmployeesProvider);

    String empName(String id) {
      final emp = employees.where((e) => e.id == id).firstOrNull;
      return emp != null ? '${emp.firstName} ${emp.lastName}' : id;
    }

    return FarmScaffold(
      appBar: FarmAppBar(
        title: employeeId != null ? 'Piecework Logs' : 'All Piecework Logs',
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Log Piecework',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => context.push(AppRoutes.payrollAddPieceworkLog),
      ),
      body: logs.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 56,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No piecework logs recorded yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: logs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final log = logs[i];
                return _PieceworkLogTile(
                  log: log,
                  employeeName: empName(log.employeeId),
                  onDelete: () => _confirmDelete(context, ref, log),
                );
              },
            ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PieceworkLog log,
  ) async {
    String reason = '';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => _DeleteReasonDialog(
        logDescription:
            '${log.payrollCode} — ${log.quantity} ${log.unit} on ${_dateFmt.format(log.date)}',
        onReasonChanged: (v) => reason = v,
      ),
    );

    if (ok == true && context.mounted) {
      if (reason.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A correction reason is required.')),
        );
        return;
      }
      await ref
          .read(pieceworkNotifierProvider.notifier)
          .deleteLog(log.id, reason.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Piecework log deleted.')));
      }
    }
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────

class _PieceworkLogTile extends StatelessWidget {
  const _PieceworkLogTile({
    required this.log,
    required this.employeeName,
    required this.onDelete,
  });

  final PieceworkLog log;
  final String employeeName;
  final VoidCallback onDelete;

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
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.assignment_outlined,
            color: AppColors.success,
            size: 20,
          ),
        ),
        title: Text(
          log.payrollCode,
          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              employeeName,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  '${log.quantity} ${log.unit} × ${_zar.format(log.ratePerUnit)}',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(width: 8),
                Text(
                  '= ${_zar.format(log.totalEarnings)}',
                  style: tt.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              _dateFmt.format(log.date),
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            if (log.notes != null) ...[
              const SizedBox(height: 2),
              Text(
                log.notes!,
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          tooltip: 'Delete log',
          onPressed: onDelete,
        ),
      ),
    );
  }
}

// ── Delete reason dialog ──────────────────────────────────────────────────────

class _DeleteReasonDialog extends StatefulWidget {
  const _DeleteReasonDialog({
    required this.logDescription,
    required this.onReasonChanged,
  });

  final String logDescription;
  final ValueChanged<String> onReasonChanged;

  @override
  State<_DeleteReasonDialog> createState() => _DeleteReasonDialogState();
}

class _DeleteReasonDialogState extends State<_DeleteReasonDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete piecework log?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.logDescription),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              labelText: 'Correction reason *',
              border: OutlineInputBorder(),
              hintText: 'e.g. Entered in wrong week',
            ),
            onChanged: widget.onReasonChanged,
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
