import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/audit_log_entry.dart';
import '../../providers/payroll_providers.dart';

enum _EntityFilter {
  all,
  payRun,
  employee,
  leave,
  alert,
  contract,
  communication,
}

class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  static const String _allActors = 'All actors';

  _EntityFilter _filter = _EntityFilter.all;
  String _searchQuery = '';
  String _actorFilter = _allActors;
  DateTimeRange? _dateRange;
  late TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  String _dateRangeLabel() {
    if (_dateRange == null) {
      return 'Any date';
    }
    final start = _fmtDate(_dateRange!.start);
    final end = _fmtDate(_dateRange!.end);
    return '$start - $end';
  }

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final allLog = ref.watch(allAuditLogProvider);
    final cs = Theme.of(context).colorScheme;
    final actorOptions = <String>{
      _allActors,
      ...allLog.map((entry) => entry.changedByName),
    }.toList()..sort();

    // Filter by entity type
    String? entityTypeFilter;
    switch (_filter) {
      case _EntityFilter.payRun:
        entityTypeFilter = 'PayRun';
      case _EntityFilter.employee:
        entityTypeFilter = 'PayrollEmployee';
      case _EntityFilter.leave:
        entityTypeFilter = 'LeaveRequest';
      case _EntityFilter.alert:
        entityTypeFilter = 'ComplianceAlert';
      case _EntityFilter.contract:
        entityTypeFilter = 'EmploymentContract';
      case _EntityFilter.communication:
        entityTypeFilter = 'CommunicationLog';
      case _EntityFilter.all:
        entityTypeFilter = null;
    }

    final rangeStart = _dateRange?.start;
    final rangeEnd = _dateRange == null
        ? null
        : DateTime(
            _dateRange!.end.year,
            _dateRange!.end.month,
            _dateRange!.end.day,
            23,
            59,
            59,
            999,
          );

    var filtered = allLog.where((e) {
      if (entityTypeFilter != null && e.entityType != entityTypeFilter) {
        return false;
      }
      if (_actorFilter != _allActors && e.changedByName != _actorFilter) {
        return false;
      }
      if (rangeStart != null && e.occurredAt.isBefore(rangeStart)) {
        return false;
      }
      if (rangeEnd != null && e.occurredAt.isAfter(rangeEnd)) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return e.changedByName.toLowerCase().contains(q) ||
            (e.description?.toLowerCase().contains(q) ?? false) ||
            e.action.toLowerCase().contains(q) ||
            e.entityType.toLowerCase().contains(q);
      }
      return true;
    }).toList()..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Audit Log',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search audit log…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Filter chips ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _EntityFilter.values.map((f) {
                  final label = switch (f) {
                    _EntityFilter.all => 'All',
                    _EntityFilter.payRun => 'Pay Runs',
                    _EntityFilter.employee => 'Employees',
                    _EntityFilter.leave => 'Leave',
                    _EntityFilter.alert => 'Alerts',
                    _EntityFilter.contract => 'Contracts',
                    _EntityFilter.communication => 'Messages',
                  };
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Actor',
                      border: OutlineInputBorder(),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _actorFilter,
                        items: actorOptions
                            .map(
                              (actor) => DropdownMenuItem<String>(
                                value: actor,
                                child: Text(actor),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _actorFilter = value);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDateRange,
                    icon: const Icon(Icons.date_range_outlined),
                    label: Text(_dateRangeLabel()),
                  ),
                ),
                if (_dateRange != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Clear date range',
                    onPressed: () => setState(() => _dateRange = null),
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ],
            ),
          ),
          // Count indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${filtered.length} entr${filtered.length == 1 ? 'y' : 'ies'}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // ── Log entries ──────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: const Icon(Icons.history_toggle_off_outlined),
                    title: 'No audit entries',
                    subtitle: _searchQuery.isNotEmpty
                        ? 'No entries match "$_searchQuery".'
                        : 'No audit events for this filter.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (_, i) => _AuditEntryTile(entry: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AuditEntryTile extends StatelessWidget {
  const _AuditEntryTile({required this.entry});
  final AuditLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (actionColor, actionIcon) = _actionStyle(entry.action);
    final hasSnapshot =
        entry.beforeSnapshot != null || entry.afterSnapshot != null;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: hasSnapshot
          ? ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              leading: _actionBadge(actionColor, actionIcon),
              title: _entryTitle(context, tt, cs),
              subtitle: _entrySubtitle(context, tt, cs),
              children: [_snapshotDiff(context, tt, cs)],
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _actionBadge(actionColor, actionIcon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _entryTitle(context, tt, cs),
                        const SizedBox(height: 2),
                        _entrySubtitle(context, tt, cs),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _actionBadge(Color color, IconData icon) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: 18, color: color),
  );

  Widget _entryTitle(BuildContext context, TextTheme tt, ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: Text(
            entry.description ??
                '${entry.action} on ${entry.entityType} (${entry.entityId})',
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _entityLabel(entry.entityType),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _entrySubtitle(BuildContext context, TextTheme tt, ColorScheme cs) {
    return Row(
      children: [
        Icon(Icons.person_outline, size: 13, color: cs.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          entry.changedByName,
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(width: 8),
        Icon(Icons.schedule, size: 13, color: cs.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          _fmt(entry.occurredAt),
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _snapshotDiff(BuildContext context, TextTheme tt, ColorScheme cs) {
    if (entry.beforeSnapshot == null && entry.afterSnapshot == null) {
      return const SizedBox.shrink();
    }
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.beforeSnapshot != null) ...[
            Text(
              'Before',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            ..._snapshotRows(entry.beforeSnapshot!, Colors.red[800]!, tt),
            const SizedBox(height: 8),
          ],
          if (entry.afterSnapshot != null) ...[
            Text(
              'After',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            ..._snapshotRows(entry.afterSnapshot!, Colors.green[700]!, tt),
          ],
        ],
      ),
    );
  }

  List<Widget> _snapshotRows(
    Map<String, dynamic> snap,
    Color color,
    TextTheme tt,
  ) {
    return snap.entries.map((e) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                '${e.key}:',
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            Expanded(
              child: Text(
                e.value?.toString() ?? '—',
                style: tt.labelSmall?.copyWith(color: color),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  (Color, IconData) _actionStyle(String action) {
    return switch (action.toUpperCase()) {
      'CREATE' => (Colors.green, Icons.add_circle_outline),
      'UPDATE' => (
        const Color.fromARGB(255, 245, 127, 23),
        Icons.edit_outlined,
      ),
      'APPROVE' => (Colors.blue, Icons.thumb_up_outlined),
      'DISBURSE' => (Colors.purple, Icons.payments_outlined),
      'SIGN' => (Colors.green, Icons.verified_outlined),
      'ACCRUE' => (Colors.indigo, Icons.event_repeat_outlined),
      'RESOLVE' => (Colors.teal, Icons.check_circle_outline),
      'DELETE' => (Colors.red, Icons.delete_outline),
      _ => (Colors.grey, Icons.radio_button_unchecked),
    };
  }

  String _entityLabel(String entityType) => switch (entityType) {
    'PayRun' => 'PAY RUN',
    'PayrollEmployee' => 'EMPLOYEE',
    'LeaveRequest' => 'LEAVE',
    'ComplianceAlert' => 'ALERT',
    'EmploymentContract' => 'CONTRACT',
    'CommunicationLog' => 'MESSAGE',
    _ => entityType.toUpperCase(),
  };

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
