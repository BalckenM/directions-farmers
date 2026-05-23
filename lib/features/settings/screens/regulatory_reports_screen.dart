import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';

// ── Report model ──────────────────────────────────────────────────────────────

enum _ReportStatus { available, pending, overdue }

class _ReportItem {
  final String title;
  final String subtitle;
  final String description;
  final String authority;
  final IconData icon;
  final Color color;
  final _ReportStatus status;
  final String? dueDate;
  final String? lastGenerated;

  const _ReportItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.authority,
    required this.icon,
    required this.color,
    required this.status,
    this.dueDate,
    this.lastGenerated,
  });
}

const _reports = [
  _ReportItem(
    title: 'IRP5 / IT3(a) Employee Certificates',
    subtitle: 'Annual tax certificates',
    description:
        'Employee income tax certificates issued to each staff member after year-end payroll. Required for SARS personal tax submissions.',
    authority: 'SARS (South African Revenue Service)',
    icon: Icons.receipt_long_rounded,
    color: AppColors.secondary,
    status: _ReportStatus.available,
    lastGenerated: '28 Feb 2024',
    dueDate: '31 May 2024',
  ),
  _ReportItem(
    title: 'EMP201 Monthly Declaration',
    subtitle: 'PAYE / UIF / SDL submission',
    description:
        'Monthly employer declaration of PAYE, UIF, and SDL deductions. Must be submitted to SARS by the 7th of the following month.',
    authority: 'SARS — eFiling',
    icon: Icons.assignment_turned_in_rounded,
    color: AppColors.primary,
    status: _ReportStatus.available,
    lastGenerated: '05 Mar 2024',
    dueDate: '07 Apr 2024',
  ),
  _ReportItem(
    title: 'Livestock Movement Certificate',
    subtitle: 'Animal traceability (LPA)',
    description:
        'Required for all livestock moved between farms or to an auction. Must accompany animals in transit under DAFF traceability regulations.',
    authority: 'DAFF / LPA (Livestock Production Authority)',
    icon: Icons.route_rounded,
    color: AppColors.info,
    status: _ReportStatus.available,
    lastGenerated: '12 Mar 2024',
  ),
  _ReportItem(
    title: 'Veterinary Health Certificate',
    subtitle: 'Livestock health status',
    description:
        'Required for interstate or export movements. Confirms animals are free from notifiable diseases. Issued by a registered veterinarian.',
    authority: 'State Veterinarian / CVO',
    icon: Icons.verified_rounded,
    color: AppColors.success,
    status: _ReportStatus.pending,
    dueDate: 'On request',
  ),
  _ReportItem(
    title: 'DAFF Quarterly Production Report',
    subtitle: 'Agricultural output statistics',
    description:
        'Quarterly report on livestock numbers, slaughter data, milk and egg production submitted to the Department of Agriculture.',
    authority: 'DAFF (Dept of Agriculture, Forestry & Fisheries)',
    icon: Icons.bar_chart_rounded,
    color: AppColors.tertiary,
    status: _ReportStatus.overdue,
    dueDate: '31 Mar 2024',
    lastGenerated: '01 Jan 2024',
  ),
  _ReportItem(
    title: 'COIDA Annual Return',
    subtitle: 'Workmen\'s compensation',
    description:
        'Annual return of earnings submitted to the Compensation Fund. All employers with workers must file. Used to calculate insurance premiums.',
    authority: 'Compensation Commissioner (Dept of Labour)',
    icon: Icons.health_and_safety_rounded,
    color: AppColors.warning,
    status: _ReportStatus.pending,
    dueDate: '31 Mar 2024',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class RegulatoryReportsScreen extends ConsumerWidget {
  const RegulatoryReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final overdue = _reports
        .where((r) => r.status == _ReportStatus.overdue)
        .length;

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Regulatory Reports',
        subtitle: 'Compliance & statutory documents',
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (overdue > 0) ...[
            // Warning banner
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(18),
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.error.withAlpha(80)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.error, size: 22),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '$overdue report${overdue > 1 ? 's are' : ' is'} overdue. Please action them as soon as possible.',
                      style: tt.bodySmall?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Summary stats
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.card,
              boxShadow: AppShadows.level1,
            ),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(children: [
              _StatPill(
                label: 'Available',
                value: _reports
                    .where((r) => r.status == _ReportStatus.available)
                    .length
                    .toString(),
                color: AppColors.success,
              ),
              _Divider(),
              _StatPill(
                label: 'Pending',
                value: _reports
                    .where((r) => r.status == _ReportStatus.pending)
                    .length
                    .toString(),
                color: AppColors.warning,
              ),
              _Divider(),
              _StatPill(
                label: 'Overdue',
                value: overdue.toString(),
                color: AppColors.error,
              ),
            ]),
          ),
          // Report cards
          ..._reports.map((r) => _ReportCard(report: r)),
        ],
      ),
    );
  }
}

// ── Report card ───────────────────────────────────────────────────────────────

class _ReportCard extends StatefulWidget {
  const _ReportCard({required this.report});
  final _ReportItem report;

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _expanded = false;
  bool _generating = false;

  Color get _statusColor => switch (widget.report.status) {
        _ReportStatus.available => AppColors.success,
        _ReportStatus.pending => AppColors.warning,
        _ReportStatus.overdue => AppColors.error,
      };

  String get _statusLabel => switch (widget.report.status) {
        _ReportStatus.available => 'Available',
        _ReportStatus.pending => 'Pending',
        _ReportStatus.overdue => 'Overdue',
      };

  Future<void> _generate() async {
    setState(() => _generating = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _generating = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.report.title} report generated'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = widget.report.color;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: AppRadius.card,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      borderRadius: AppRadius.button,
                    ),
                    child: Icon(widget.report.icon,
                        color: color, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.report.title,
                            style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(widget.report.subtitle,
                            style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _statusColor.withAlpha(20),
                          borderRadius: AppRadius.chip,
                        ),
                        child: Text(
                          _statusLabel,
                          style: tt.labelSmall?.copyWith(
                              color: _statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.report.description,
                      style: tt.bodySmall),
                  const SizedBox(height: AppSpacing.sm),
                  Row(children: [
                    Icon(Icons.account_balance_rounded,
                        size: 13, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(widget.report.authority,
                          style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontStyle: FontStyle.italic)),
                    ),
                  ]),
                  if (widget.report.dueDate != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.schedule_rounded,
                          size: 13, color: _statusColor),
                      const SizedBox(width: 4),
                      Text('Due: ${widget.report.dueDate}',
                          style: tt.bodySmall?.copyWith(
                              color: _statusColor,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ],
                  if (widget.report.lastGenerated != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 13, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                          'Last generated: ${widget.report.lastGenerated}',
                          style: tt.bodySmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: _generating ? null : _generate,
                    icon: _generating
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white))
                        : const Icon(Icons.download_rounded, size: 18),
                    label: Text(_generating
                        ? 'Generating…'
                        : 'Generate Report'),
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  const _StatPill({
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
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold, color: color)),
          Text(label, style: tt.labelSmall),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 32,
        child: VerticalDivider(
            color: Theme.of(context).colorScheme.outlineVariant),
      );
}
