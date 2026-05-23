import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/payroll_repository.dart';
import '../../models/incident_record.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Incidents List Screen
// ─────────────────────────────────────────────────────────────────────────────

class IncidentsScreen extends ConsumerStatefulWidget {
  const IncidentsScreen({super.key});

  @override
  ConsumerState<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends ConsumerState<IncidentsScreen> {
  static const _tabs = [
    (label: 'All', status: null),
    (label: 'Open', status: IncidentStatus.open),
    (label: 'Investigating', status: IncidentStatus.underInvestigation),
    (label: 'Resolved', status: IncidentStatus.resolved),
    (label: 'Closed', status: IncidentStatus.closed),
  ];

  @override
  Widget build(BuildContext context) {
    final allIncidents = ref.watch(allIncidentsProvider);
    final employees = ref.watch(employeesProvider);
    final empMap = {for (final e in employees) e.id: e.fullName};

    return DefaultTabController(
      length: _tabs.length,
      child: FarmScaffold(
        appBar: FarmAppBar(
          title: 'Incidents',
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _tabs
                .map(
                  (t) => Tab(
                    text: t.status == null
                        ? 'All (${allIncidents.length})'
                        : '${t.label} (${allIncidents.where((i) => i.status == t.status).length})',
                  ),
                )
                .toList(),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddIncidentSheet(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Incident'),
          backgroundColor: PayrollTokens.green,
        ),
        body: TabBarView(
          children: _tabs.map((t) {
            final incidents = t.status == null
                ? allIncidents
                : allIncidents.where((i) => i.status == t.status).toList();
            final sorted = List<IncidentRecord>.from(incidents)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return sorted.isEmpty
                ? EmptyState(
                    icon: const Icon(Icons.folder_open_outlined),
                    title: 'No incidents',
                    subtitle:
                        'No ${t.label.toLowerCase()} incidents on record.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: sorted.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) => _IncidentCard(
                      incident: sorted[i],
                      empName:
                          empMap[sorted[i].employeeId] ?? sorted[i].employeeId,
                      onTap: () => _openDetail(ctx, sorted[i].id),
                    ),
                  );
          }).toList(),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, String incidentId) {
    context.push(AppRoutes.payrollIncidentDetail(incidentId));
  }

  Future<void> _showAddIncidentSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddIncidentSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Incident Card
// ─────────────────────────────────────────────────────────────────────────────

class _IncidentCard extends StatelessWidget {
  const _IncidentCard({
    required this.incident,
    required this.empName,
    required this.onTap,
  });
  final IncidentRecord incident;
  final String empName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (typeColor, typeIcon) = _typeStyle(incident.type);
    final (statusBg, statusFg, statusLabel) = _statusStyle(incident.status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: incident.isOpen
            ? BorderSide(color: typeColor.withValues(alpha: 0.4), width: 1.5)
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
              // Top row: type badge + status chip
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(typeIcon, size: 12, color: typeColor),
                        const SizedBox(width: 4),
                        Text(
                          incident.typeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: typeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusFg,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                incident.title,
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                incident.description,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
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
                  const SizedBox(width: 12),
                  Icon(
                    Icons.event_outlined,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _fmt(incident.incidentDate),
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const Spacer(),
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

  (Color, IconData) _typeStyle(IncidentType t) => switch (t) {
    IncidentType.disciplinary => (
      PayrollTokens.rose,
      Icons.warning_amber_rounded,
    ),
    IncidentType.grievance => (
      PayrollTokens.amber,
      Icons.report_problem_outlined,
    ),
    IncidentType.healthAndSafety => (
      PayrollTokens.sky,
      Icons.health_and_safety_outlined,
    ),
    IncidentType.misconduct => (PayrollTokens.rose, Icons.report_outlined),
    IncidentType.other => (const Color(0xFF757575), Icons.help_outline_rounded),
  };

  (Color, Color, String) _statusStyle(IncidentStatus s) => switch (s) {
    IncidentStatus.open => (
      PayrollTokens.rose.withValues(alpha: 0.1),
      PayrollTokens.rose,
      'Open',
    ),
    IncidentStatus.underInvestigation => (
      PayrollTokens.amber.withValues(alpha: 0.1),
      PayrollTokens.amber,
      'Investigating',
    ),
    IncidentStatus.resolved => (
      PayrollTokens.green.withValues(alpha: 0.1),
      PayrollTokens.green,
      'Resolved',
    ),
    IncidentStatus.closed => (
      const Color(0xFF757575).withValues(alpha: 0.15),
      const Color(0xFF757575),
      'Closed',
    ),
  };

  String _fmt(DateTime dt) => DateFormat('d MMM y').format(dt);
}

// ─────────────────────────────────────────────────────────────────────────────
// Incident Detail Screen
// ─────────────────────────────────────────────────────────────────────────────

class IncidentDetailScreen extends ConsumerWidget {
  const IncidentDetailScreen({super.key, required this.incidentId});
  final String incidentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incident = ref.watch(incidentByIdProvider(incidentId));
    if (incident == null) {
      return FarmScaffold(
        appBar: const FarmAppBar(title: 'Incident Detail'),
        body: const EmptyState(
          icon: Icon(Icons.search_off_outlined),
          title: 'Incident not found',
          subtitle: 'The incident you are looking for does not exist.',
        ),
      );
    }

    final employees = ref.watch(employeesProvider);
    final empMap = {for (final e in employees) e.id: e.fullName};
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (typeColor, typeIcon) = _typeStyle(incident.type);

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Incident Detail'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Title / Type ─────────────────────────────────────────────
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: incident.isOpen
                  ? BorderSide(
                      color: typeColor.withValues(alpha: 0.4),
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
                          color: typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(typeIcon, size: 14, color: typeColor),
                            const SizedBox(width: 6),
                            Text(
                              incident.typeLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: typeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _statusChip(context, incident.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    incident.title,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    incident.description,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Details card ─────────────────────────────────────────────
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _detailRow(
                    context,
                    Icons.person_outline,
                    'Employee',
                    empMap[incident.employeeId] ?? incident.employeeId,
                  ),
                  _divider(),
                  _detailRow(
                    context,
                    Icons.event_outlined,
                    'Incident Date',
                    _fmt(incident.incidentDate),
                  ),
                  _divider(),
                  _detailRow(
                    context,
                    Icons.report_outlined,
                    'Reported By',
                    incident.reportedByUserId,
                  ),
                  _divider(),
                  _detailRow(
                    context,
                    Icons.access_time,
                    'Logged',
                    _fmtFull(incident.createdAt),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Timeline ────────────────────────────────────────────────
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timeline',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  _timelineStep(
                    context,
                    Icons.report_outlined,
                    'Incident Reported',
                    _fmtFull(incident.createdAt),
                    PayrollTokens.sky,
                  ),
                  if (incident.status == IncidentStatus.underInvestigation ||
                      incident.status == IncidentStatus.resolved ||
                      incident.status == IncidentStatus.closed)
                    _timelineStep(
                      context,
                      Icons.search_outlined,
                      'Under Investigation',
                      null,
                      PayrollTokens.amber,
                    ),
                  if (incident.status == IncidentStatus.resolved ||
                      incident.status == IncidentStatus.closed)
                    _timelineStep(
                      context,
                      Icons.check_circle_outline_rounded,
                      'Resolved',
                      incident.resolvedAt != null
                          ? _fmtFull(incident.resolvedAt!)
                          : null,
                      PayrollTokens.green,
                    ),
                  if (incident.status == IncidentStatus.closed)
                    _timelineStep(
                      context,
                      Icons.lock_outline,
                      'Closed',
                      null,
                      const Color(0xFF757575),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Action taken ─────────────────────────────────────────────
          if (incident.actionTaken != null)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Action Taken',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      incident.actionTaken!,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Resolve button (if open/investigating) ───────────────────
          if (incident.isOpen) ...[
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Resolve Incident',
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () => _showResolveDialog(context, ref, incident),
              isLoading: false,
              isExpanded: true,
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(
            label,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 28);

  Widget _timelineStep(
    BuildContext context,
    IconData icon,
    String label,
    String? dateStr,
    Color color,
  ) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (dateStr != null)
                  Text(
                    dateStr,
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(BuildContext context, IncidentStatus s) {
    final tt = Theme.of(context).textTheme;
    final (bg, fg, lbl) = switch (s) {
      IncidentStatus.open => (
        PayrollTokens.rose.withValues(alpha: 0.1),
        PayrollTokens.rose,
        'Open',
      ),
      IncidentStatus.underInvestigation => (
        PayrollTokens.amber.withValues(alpha: 0.1),
        PayrollTokens.amber,
        'Investigating',
      ),
      IncidentStatus.resolved => (
        PayrollTokens.green.withValues(alpha: 0.1),
        PayrollTokens.green,
        'Resolved',
      ),
      IncidentStatus.closed => (
        const Color(0xFF757575).withValues(alpha: 0.15),
        const Color(0xFF757575),
        'Closed',
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        lbl,
        style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Future<void> _showResolveDialog(
    BuildContext context,
    WidgetRef ref,
    IncidentRecord incident,
  ) async {
    final actionCtrl = TextEditingController(text: incident.actionTaken ?? '');
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            Text(
              'Resolve Incident',
              style: Theme.of(
                ctx,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              incident.title,
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: actionCtrl,
              autofocus: true,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Action taken',
                hintText: 'Describe the resolution and action taken…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: PayrollTokens.green,
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Mark Resolved'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      final updated = incident.copyWith(
        status: IncidentStatus.resolved,
        actionTaken: actionCtrl.text.trim().isNotEmpty
            ? actionCtrl.text.trim()
            : 'Resolved by management',
        resolvedAt: DateTime.now(),
        resolvedByUserId: 'usr_manager',
      );
      ref.read(payrollRepositoryProvider).updateIncident(updated);
      ref.invalidate(allIncidentsProvider);
      ref.invalidate(openIncidentsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incident resolved successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  (Color, IconData) _typeStyle(IncidentType t) => switch (t) {
    IncidentType.disciplinary => (
      PayrollTokens.rose,
      Icons.warning_amber_rounded,
    ),
    IncidentType.grievance => (
      PayrollTokens.amber,
      Icons.report_problem_outlined,
    ),
    IncidentType.healthAndSafety => (
      PayrollTokens.sky,
      Icons.health_and_safety_outlined,
    ),
    IncidentType.misconduct => (PayrollTokens.rose, Icons.report_outlined),
    IncidentType.other => (const Color(0xFF757575), Icons.help_outline_rounded),
  };

  String _fmt(DateTime dt) => DateFormat('d MMM y').format(dt);
  String _fmtFull(DateTime dt) => DateFormat('d MMM y, HH:mm').format(dt);
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Incident Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddIncidentSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddIncidentSheet> createState() => _AddIncidentSheetState();
}

class _AddIncidentSheetState extends ConsumerState<_AddIncidentSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  IncidentType _type = IncidentType.disciplinary;
  String? _selectedEmployeeId;
  DateTime _incidentDate = DateTime.now();
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(activeEmployeesProvider);
    final tt = Theme.of(context).textTheme;
    final mq = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, mq.viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log New Incident', style: tt.titleLarge),
          const SizedBox(height: 20),

          // Employee
          DropdownButtonFormField<String>(
            initialValue: _selectedEmployeeId,
            hint: const Text('Select Employee'),
            decoration: const InputDecoration(
              labelText: 'Employee',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            items: employees
                .map(
                  (e) => DropdownMenuItem(value: e.id, child: Text(e.fullName)),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedEmployeeId = v),
          ),
          const SizedBox(height: 14),

          // Type
          DropdownButtonFormField<IncidentType>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: 'Incident Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: IncidentType.values
                .map(
                  (t) => DropdownMenuItem(value: t, child: Text(_typeLabel(t))),
                )
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 14),

          // Title
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Title / Short description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),

          // Description
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Full description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),

          // Incident date
          OutlinedButton.icon(
            icon: const Icon(Icons.event_outlined),
            label: Text(
              'Incident Date: ${_incidentDate.day.toString().padLeft(2, '0')}/${_incidentDate.month.toString().padLeft(2, '0')}/${_incidentDate.year}',
            ),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _incidentDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _incidentDate = picked);
            },
          ),
          const SizedBox(height: 20),

          PrimaryButton(
            label: 'Log Incident',
            isLoading: _submitting,
            isExpanded: true,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedEmployeeId == null ||
        _titleCtrl.text.trim().isEmpty ||
        _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    final incident = IncidentRecord(
      id: 'inc_${DateTime.now().millisecondsSinceEpoch}',
      employeeId: _selectedEmployeeId!,
      type: _type,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      incidentDate: _incidentDate,
      status: IncidentStatus.open,
      reportedByUserId: 'usr_manager',
      createdAt: DateTime.now(),
    );
    ref.read(payrollRepositoryProvider).addIncident(incident);
    ref.invalidate(allIncidentsProvider);
    ref.invalidate(openIncidentsProvider);
    setState(() => _submitting = false);
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident logged successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _typeLabel(IncidentType t) => switch (t) {
    IncidentType.disciplinary => 'Disciplinary',
    IncidentType.grievance => 'Grievance',
    IncidentType.healthAndSafety => 'Health & Safety',
    IncidentType.misconduct => 'Misconduct',
    IncidentType.other => 'Other',
  };
}
