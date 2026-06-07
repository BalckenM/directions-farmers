import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/payslip.dart';
import '../../providers/payroll_providers.dart';
import '../../../../shared/widgets/avatar_widget.dart';

final _periodFmt = DateFormat('MMM yyyy');
final _dateFmt   = DateFormat('d MMM yyyy');
final _zarFmt    = NumberFormat.currency(
    locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);

String _dd(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/'
    '${d.year}';

const _kPage = 12;

// ─── Screen ───────────────────────────────────────────────────────────────────

class PayslipListScreen extends ConsumerStatefulWidget {
  const PayslipListScreen({super.key, this.employeeId});
  final String? employeeId;

  @override
  ConsumerState<PayslipListScreen> createState() => _PayslipListState();
}

class _PayslipListState extends ConsumerState<PayslipListScreen> {
  bool?     _paidFilter; // null=all  true=paid  false=pending
  DateTime? _from;
  DateTime? _to;
  int       _shown = _kPage;

  bool get _scoped => widget.employeeId != null;

  Future<void> _pickFrom() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _from ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _to ?? DateTime.now(),
    );
    if (d != null) setState(() { _from = d; _shown = _kPage; });
  }

  Future<void> _pickTo() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _to ?? DateTime.now(),
      firstDate: _from ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() { _to = d; _shown = _kPage; });
  }

  @override
  Widget build(BuildContext context) {
    final all    = ref.watch(
        payslipsProvider(PayslipFilter(employeeId: widget.employeeId)));
    final empMap = <String, String>{
      for (final e in ref.watch(activeEmployeesProvider))
        e.id: '${e.firstName} ${e.lastName}',
    };
    final empImageMap = <String, String?>{
      for (final e in ref.watch(activeEmployeesProvider))
        e.id: e.profileImageUrl,
    };
    final now = DateTime.now();

    // ── Filter ──────────────────────────────────────────────────────────────
    final filtered = all.where((ps) {
      if (_from != null && ps.payDate.isBefore(_from!))    return false;
      if (_to   != null) {
        final ceil = DateTime(_to!.year, _to!.month, _to!.day, 23, 59, 59);
        if (ps.payDate.isAfter(ceil))                       return false;
      }
      if (_paidFilter != null) {
        final isPaid = ps.payDate.isBefore(now) ||
            ps.payDate.isAtSameMomentAs(now);
        if (isPaid != _paidFilter)                          return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.payDate.compareTo(a.payDate));

    final visible = filtered.take(_shown).toList();
    final hasMore = filtered.length > _shown;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Payslips',
        subtitle: '${filtered.length} record${filtered.length == 1 ? '' : 's'}',
      ),
      body: Column(
        children: [
          // ── Filter pills ─────────────────────────────────────────────────
          _FilterRow(
            paidFilter: _paidFilter,
            from: _from,
            to: _to,
            onPaidChanged: (v) =>
                setState(() { _paidFilter = v; _shown = _kPage; }),
            onPickFrom: _pickFrom,
            onPickTo:   _pickTo,
            onClearFrom: () => setState(() { _from = null; _shown = _kPage; }),
            onClearTo:   () => setState(() { _to   = null; _shown = _kPage; }),
          ),

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: const Icon(Icons.receipt_long_outlined),
                    title: _hasFilters
                        ? 'No payslips match'
                        : 'No payslips yet',
                    subtitle: _hasFilters
                        ? 'Try different filters.'
                        : 'Payslips appear after payroll runs.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.md,
                        AppSpacing.md, AppSpacing.xxl),
                    itemCount: visible.length + (hasMore ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) {
                      if (i == visible.length) {
                        return _LoadMoreBtn(
                          remaining: filtered.length - _shown,
                          onTap: () =>
                              setState(() => _shown += _kPage),
                        );
                      }
                      final ps = visible[i];
                      return _PayslipCard(
                        payslip: ps,
                        employeeName: empMap[ps.employeeId],
                        employeeImageUrl: empImageMap[ps.employeeId],
                        showEmployee: !_scoped,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool get _hasFilters =>
      _paidFilter != null || _from != null || _to != null;
}

// ─── Filter pills row ─────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final bool?               paidFilter;
  final DateTime?           from;
  final DateTime?           to;
  final ValueChanged<bool?> onPaidChanged;
  final VoidCallback        onPickFrom;
  final VoidCallback        onPickTo;
  final VoidCallback        onClearFrom;
  final VoidCallback        onClearTo;

  const _FilterRow({
    required this.paidFilter,
    required this.from,
    required this.to,
    required this.onPaidChanged,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onClearFrom,
    required this.onClearTo,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                // Status pills — fixed width, evenly spaced
                Expanded(
                  child: _TogglePill(
                    label: 'All',
                    icon: Icons.receipt_long_outlined,
                    selected: paidFilter == null,
                    color: AppColors.primary,
                    onTap: () => onPaidChanged(null),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _TogglePill(
                    label: 'Paid',
                    icon: Icons.check_circle_outline_rounded,
                    selected: paidFilter == true,
                    color: AppColors.success,
                    onTap: () => onPaidChanged(
                        paidFilter == true ? null : true),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _TogglePill(
                    label: 'Pending',
                    icon: Icons.schedule_outlined,
                    selected: paidFilter == false,
                    color: AppColors.warning,
                    onTap: () => onPaidChanged(
                        paidFilter == false ? null : false),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Date pills
                Expanded(
                  child: _DatePill(
                    label: from != null ? _dd(from!) : 'From',
                    active: from != null,
                    icon: Icons.calendar_today_outlined,
                    onTap: onPickFrom,
                    onClear: from != null ? onClearFrom : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _DatePill(
                    label: to != null ? _dd(to!) : 'To',
                    active: to != null,
                    icon: Icons.event_outlined,
                    onTap: onPickTo,
                    onClear: to != null ? onClearTo : null,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant),
        ],
      ),
    );
  }
}

// ─── Toggle pill (status) ─────────────────────────────────────────────────────

class _TogglePill extends StatelessWidget {
  final String     label;
  final IconData   icon;
  final bool       selected;
  final Color      color;
  final VoidCallback onTap;

  const _TogglePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected
                  ? color
                  : color.withValues(alpha: 0.35),
              width: selected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 13,
                color: selected
                    ? color
                    : color.withValues(alpha: 0.7)),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: selected
                        ? color
                        : color.withValues(alpha: 0.8),
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─── Date pill ────────────────────────────────────────────────────────────────

class _DatePill extends StatelessWidget {
  final String       label;
  final bool         active;
  final IconData     icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DatePill({
    required this.label,
    required this.active,
    required this.icon,
    required this.onTap,
    this.onClear,
  });

  static const _teal = Color(0xFF00695C);

  @override
  Widget build(BuildContext context) {
    final col = active ? _teal : _teal.withValues(alpha: 0.65);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? _teal.withValues(alpha: 0.13)
              : _teal.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: active
                  ? _teal
                  : _teal.withValues(alpha: 0.35),
              width: active ? 1.5 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: col),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: active ? _teal : _teal.withValues(alpha: 0.8),
                    fontWeight: active
                        ? FontWeight.w700
                        : FontWeight.w500)),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded,
                    size: 12, color: col),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Compact payslip card ─────────────────────────────────────────────────────

class _PayslipCard extends StatelessWidget {
  const _PayslipCard({
    required this.payslip,
    this.employeeName,
    this.employeeImageUrl,
    required this.showEmployee,
  });

  final Payslip payslip;
  final String? employeeName;
  final String? employeeImageUrl;
  final bool    showEmployee;

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final now    = DateTime.now();
    final isPaid = payslip.payDate.isBefore(now) ||
        payslip.payDate.isAtSameMomentAs(now);
    final accent = isPaid ? AppColors.success : AppColors.primary;

    final initials = (employeeName ?? payslip.employeeId)
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return InkWell(
      onTap: () => GoRouter.of(context)
          .push(AppRoutes.payrollPayslipDetail(payslip.id)),
      borderRadius: AppRadius.card,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.card,
          border: Border.all(
              color: accent.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
                color: accent.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 10),
                  child: Row(
                    children: [
                      // Avatar with colored border
                      AvatarWidget(
                        imageUrl: employeeImageUrl,
                        initials: initials,
                        radius: 19,
                        backgroundColor: accent.withValues(alpha: 0.12),
                        foregroundColor: accent,
                      ),
                      const SizedBox(width: AppSpacing.sm),

                      // Main info
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            // Period + employee name
                            Row(children: [
                              Text(
                                _periodFmt.format(
                                    payslip.periodStart),
                                style: tt.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: accent),
                              ),
                              if (showEmployee &&
                                  employeeName != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                      color: cs.onSurfaceVariant,
                                      shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    employeeName!,
                                    style: tt.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ]),
                            const SizedBox(height: 3),
                            // Pay date + breakdown
                            Row(children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 11,
                                  color: AppColors.tertiary),
                              const SizedBox(width: 3),
                              Text(
                                _dateFmt.format(payslip.payDate),
                                style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 11),
                              ),
                              const SizedBox(width: 8),
                              Text('·',
                                  style: tt.bodySmall?.copyWith(
                                      color: cs.outlineVariant)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'G ${_zarFmt.format(payslip.grossPay)}  D ${_zarFmt.format(payslip.totalDeductions)}',
                                  style: tt.labelSmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),

                      // Right: net pay + status
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Solid net pay badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _zarFmt.format(payslip.netPay),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.2),
                            ),
                          ),
                          const SizedBox(height: 5),
                          StatusChip(
                            label: isPaid ? 'Paid' : 'Pending',
                            color: accent,
                            icon: isPaid
                                ? Icons.check_circle_outline
                                : Icons.schedule_outlined,
                            small: true,
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded,
                          size: 18,
                          color: accent),
                    ],
                  ),
                ),
      ),
    );
  }
}

// ─── Load more button ─────────────────────────────────────────────────────────

class _LoadMoreBtn extends StatelessWidget {
  final int          remaining;
  final VoidCallback onTap;

  const _LoadMoreBtn(
      {required this.remaining, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.expand_more_rounded,
              size: 18, color: AppColors.primary),
          label: Text(
            'Load $remaining more',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm),
          ),
        ),
      ),
    );
  }
}
