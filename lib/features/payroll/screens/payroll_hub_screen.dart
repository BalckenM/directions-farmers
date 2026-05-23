import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/compliance_alert.dart';
import '../models/leave_request.dart';
import '../models/pay_run.dart';
import '../providers/payroll_providers.dart';
import '../theme/payroll_tokens.dart';

// ─── Alias for brevity inside this file ──────────────────────────────────────
typedef _C = PayrollTokens;

final _zar  = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);
final _mFmt = DateFormat('d MMM y');

// ─── Root Screen ─────────────────────────────────────────────────────────────

class PayrollHubScreen extends ConsumerWidget {
  const PayrollHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats      = ref.watch(payrollDashboardStatsProvider);
    final payRuns    = List.of(ref.watch(allPayRunsProvider))
      ..sort((a, b) => a.periodStart.compareTo(b.periodStart));
    final critAlerts = ref.watch(criticalAlertsProvider);
    final pending    = ref.watch(pendingLeaveRequestsProvider);
    final empMap     = {
      for (final e in ref.watch(employeesProvider))
        e.id: '${e.firstName} ${e.lastName}'
    };
    final leaveTypes = ref.watch(leaveTypesProvider);
    final typeMap    = {for (final t in leaveTypes) t.id: t.name};

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Payroll',
        actions: [
          if (stats.openAlerts > 0)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon:    const Icon(Icons.notifications_outlined),
                  tooltip: 'Compliance alerts',
                  onPressed: () => context.push(AppRoutes.payrollCompliance),
                ),
                Positioned(
                  top:   8,
                  right: 8,
                  child: Container(
                    width:  8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _C.rose,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            )
          else
            IconButton(
              icon:    const Icon(Icons.notifications_outlined),
              tooltip: 'Compliance alerts',
              onPressed: () => context.push(AppRoutes.payrollCompliance),
            ),
          IconButton(
            icon:    const Icon(Icons.bar_chart_rounded),
            tooltip: 'Reports',
            onPressed: () => context.push(AppRoutes.payrollReports),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // ── Zone 1: Hero ─────────────────────────────────────────────────────
          _PeriodHeader(payRun: stats.latestPayRun),
          _FinancialMetrics(payRun: stats.latestPayRun),

          // ── Zone 2: Primary workflow actions ─────────────────────────────────
          _PrimaryActions(
            pendingLeave:  stats.pendingLeaveRequests,
            openAlerts:    stats.openAlerts,
            latestPayRun:  stats.latestPayRun,
            navContext:    context,
          ),

          // ── Zone 3: Analytics & status ────────────────────────────────────────
          _ComplianceSection(
            openCount:     stats.openAlerts,
            criticalCount: stats.criticalAlerts,
            onTap:         () => context.push(AppRoutes.payrollCompliance),
          ),
          if (stats.latestPayRun != null)
            _PayRunTracker(payRun: stats.latestPayRun!),
          _PayTrendSection(payRuns: payRuns),
          _WorkforceSection(stats: stats),
          if (critAlerts.isNotEmpty || pending.isNotEmpty)
            _PendingActions(
              alerts:        critAlerts,
              leaveRequests: pending,
              empMap:        empMap,
              typeMap:       typeMap,
              navContext:    context,
            ),

          // ── Zone 4: Module navigation ─────────────────────────────────────────
          _ModuleNav(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── 1. Period Header Card ────────────────────────────────────────────────────

class _PeriodHeader extends StatelessWidget {
  const _PeriodHeader({this.payRun});
  final PayRun? payRun;

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    final period = payRun == null
        ? 'No active pay run'
        : '${_mFmt.format(payRun!.periodStart)} – ${_mFmt.format(payRun!.periodEnd)}';
    final due = payRun == null ? '' : 'Pay date  ${_mFmt.format(payRun!.payDate)}';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLight
              ? [const Color.fromARGB(255, 30, 58, 95), const Color.fromARGB(255, 46, 89, 132)]
              : [const Color(0xFF0D1F35), const Color(0xFF1A3356)],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PAY PERIOD',
            style: theme.textTheme.labelSmall?.copyWith(
              color:         Colors.white.withAlpha(170),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            period,
            style: theme.textTheme.headlineSmall?.copyWith(
              color:      Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (due.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.event_outlined,
                        size: 13, color: Colors.white.withAlpha(160)),
                    const SizedBox(width: 4),
                    Text(
                      due,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.white.withAlpha(160)),
                    ),
                  ],
                ),
              const Spacer(),
              if (payRun != null)
                StatusChip(
                  label: PayrollTokens.payRunStatusLabel(payRun!.status),
                  color: PayrollTokens.payRunStatusColor(payRun!.status),
                ),
            ],
          ),
        ],
      ),
    );
  }
}


// ─── 2. Financial Metrics ─────────────────────────────────────────────────────

class _FinancialMetrics extends StatelessWidget {
  const _FinancialMetrics({this.payRun});
  final PayRun? payRun;

  @override
  Widget build(BuildContext context) {
    final gross      = payRun?.totalGross ?? 0;
    final net        = payRun?.totalNet ?? 0;
    final deductions = payRun?.totalDeductions ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(child: _MetricCard(
            label:       'Gross Pay',
            value:       _zar.format(gross),
            icon:        Icons.account_balance_wallet_outlined,
            accentColor: _C.teal,
          )),
          const SizedBox(width: 10),
          Expanded(child: _MetricCard(
            label:       'Net Pay',
            value:       _zar.format(net),
            icon:        Icons.payments_outlined,
            accentColor: _C.indigo,
          )),
          const SizedBox(width: 10),
          Expanded(child: _MetricCard(
            label:       'Deductions',
            value:       _zar.format(deductions),
            icon:        Icons.remove_circle_outline,
            accentColor: _C.rose,
          )),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String   label;
  final String   value;
  final IconData icon;
  final Color    accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Container(
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
          Container(
            width:  34,
            height: 34,
            decoration: BoxDecoration(
              color:        accentColor.withAlpha(22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color:      cs.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ─── 2.5. Primary Actions Row ─────────────────────────────────────────────────

class _PrimaryActions extends StatelessWidget {
  const _PrimaryActions({
    required this.pendingLeave,
    required this.openAlerts,
    required this.latestPayRun,
    required this.navContext,
  });

  final int          pendingLeave;
  final int          openAlerts;
  final PayRun?      latestPayRun;
  final BuildContext navContext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _PrimaryActionBtn(
              icon:    Icons.receipt_long_rounded,
              label:   'Pay Runs',
              color:   _C.teal,
              onTap:   () => navContext.push(AppRoutes.payrollPayRuns),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PrimaryActionBtn(
              icon:    Icons.event_available_outlined,
              label:   'Leave',
              color:   _C.purple,
              badge:   pendingLeave > 0 ? pendingLeave : null,
              onTap:   () => navContext.push(AppRoutes.payrollLeave),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PrimaryActionBtn(
              icon:    Icons.verified_user_outlined,
              label:   'Compliance',
              color:   openAlerts > 0 ? _C.rose : _C.teal,
              badge:   openAlerts > 0 ? openAlerts : null,
              onTap:   () => navContext.push(AppRoutes.payrollCompliance),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PrimaryActionBtn(
              icon:    Icons.people_rounded,
              label:   'Employees',
              color:   _C.navy,
              onTap:   () => navContext.push(AppRoutes.payrollEmployees),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionBtn extends StatelessWidget {
  const _PrimaryActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;
  final int?         badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Material(
      color:        cs.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border:       Border.all(color: cs.outlineVariant),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment:    Alignment.topCenter,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width:  38,
                    height: 38,
                    decoration: BoxDecoration(
                      color:        color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color:      cs.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines:  1,
                    overflow:  TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (badge != null)
                Positioned(
                  top:   -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color:        color,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color:      Colors.white,
                        fontSize:   10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 3. Pay Spend Trend Chart ────────────────────────────────────────────────

typedef _TrendPoint = ({String label, double gross, double net, bool isReal});

class _PayTrendSection extends StatelessWidget {
  const _PayTrendSection({required this.payRuns});
  final List<PayRun> payRuns;

  List<_TrendPoint> _buildData() {
    final data = <_TrendPoint>[];
    final base = payRuns.isNotEmpty ? payRuns.first.periodStart : DateTime.now();

    // Three synthetic preceding months for visual context
    const variance = [3100.0, 1800.0, 900.0];
    for (var i = 3; i >= 1; i--) {
      final dt = DateTime(base.year, base.month - i);
      data.add((
        label:  DateFormat('MMM').format(dt),
        gross:  payRuns.isNotEmpty
                    ? payRuns.first.totalGross - variance[3 - i]
                    : 28000.0,
        net:    payRuns.isNotEmpty
                    ? payRuns.first.totalNet - variance[3 - i] * 0.85
                    : 24800.0,
        isReal: false,
      ));
    }
    for (final r in payRuns) {
      data.add((
        label:  DateFormat('MMM').format(r.periodStart),
        gross:  r.totalGross,
        net:    r.totalNet,
        isReal: true,
      ));
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;
    final data  = _buildData();

    final maxRaw = data.fold<double>(0, (m, e) => math.max(m, e.gross));
    final maxY   = (maxRaw / 1000 * 1.25).ceilToDouble();

    return _SectionCard(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title:    'Payroll Spend Trend',
            subtitle: '6-month view · Gross vs Net (R thousands)',
            icon:     Icons.bar_chart_rounded,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 188,
            child: BarChart(
              BarChartData(
                maxY:     maxY,
                minY:     0,
                gridData: FlGridData(
                  show:             true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color:       cs.outlineVariant.withAlpha(90),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles:   true,
                      reservedSize: 38,
                      getTitlesWidget: (v, _) => Text(
                        'R${v.toInt()}k',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color:    cs.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles:   true,
                      reservedSize: 26,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= data.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            data[i].label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: data[i].isReal
                                  ? cs.onSurface
                                  : cs.onSurfaceVariant.withAlpha(100),
                              fontWeight: data[i].isReal
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: data.asMap().entries.map((e) {
                  final real = e.value.isReal;
                  return BarChartGroupData(
                    x:         e.key,
                    barsSpace: 3,
                    barRods: [
                      BarChartRodData(
                        toY:          e.value.gross / 1000,
                        color:        real ? _C.navy : _C.navy.withAlpha(45),
                        width:        11,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY:          e.value.net / 1000,
                        color:        real ? _C.teal : _C.teal.withAlpha(45),
                        width:        11,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => cs.inverseSurface,
                    getTooltipItem: (group, _, rod, rodIdx) {
                      final lbl = rodIdx == 0 ? 'Gross' : 'Net';
                      final amt = (rod.toY * 1000).round();
                      return BarTooltipItem(
                        '$lbl\n${_zar.format(amt)}',
                        TextStyle(
                          color:      cs.onInverseSurface,
                          fontSize:   11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: _C.navy, label: 'Gross'),
              const SizedBox(width: 20),
              _Legend(color: _C.teal, label: 'Net'),
              const SizedBox(width: 20),
              _Legend(color: _C.navy.withAlpha(45), label: 'Estimated'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color  color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width:  10,
          height: 10,
          decoration: BoxDecoration(
            color:        color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

// ─── 4. Workforce Breakdown ───────────────────────────────────────────────────

class _WorkforceSection extends StatelessWidget {
  const _WorkforceSection({required this.stats});
  final PayrollDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final total = stats.totalActiveEmployees;

    return _SectionCard(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title:    'Workforce',
            subtitle: '$total active employee${total == 1 ? '' : 's'}',
            icon:     Icons.people_alt_outlined,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width:  110,
                height: 110,
                child: total == 0
                    ? const Center(child: Text('—'))
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(110, 110),
                            painter: _DonutPainter(
                              segments: [
                                (value: stats.permanentCount.toDouble(), color: _C.permanent),
                                (value: stats.seasonalCount.toDouble(),  color: _C.seasonal),
                                (value: stats.casualCount.toDouble(),    color: _C.casual),
                              ],
                              total:       total.toDouble(),
                              strokeWidth: 18,
                            ),
                          ),
                          Text(
                            '$total',
                            style: TextStyle(
                              fontSize:   22,
                              fontWeight: FontWeight.w800,
                              color:      _C.permanent,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WorkforceLegendRow(
                      color: _C.permanent,
                      label: 'Permanent',
                      count: stats.permanentCount,
                      total: total,
                    ),
                    const SizedBox(height: 12),
                    _WorkforceLegendRow(
                      color: _C.seasonal,
                      label: 'Seasonal',
                      count: stats.seasonalCount,
                      total: total,
                    ),
                    const SizedBox(height: 12),
                    _WorkforceLegendRow(
                      color: _C.casual,
                      label: 'Casual',
                      count: stats.casualCount,
                      total: total,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkforceLegendRow extends StatelessWidget {
  const _WorkforceLegendRow({
    required this.color,
    required this.label,
    required this.count,
    required this.total,
  });

  final Color  color;
  final String label;
  final int    count;
  final int    total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;
    final pct   = total == 0 ? 0.0 : count / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface),
              ),
            ),
            Text(
              '$count',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color:      cs.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${(pct * 100).round()}%)',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value:           pct,
            minHeight:       4,
            backgroundColor: color.withAlpha(28),
            valueColor:      AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.segments,
    required this.total,
    required this.strokeWidth,
  });

  final List<({double value, Color color})> segments;
  final double total;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;
    final c     = Offset(size.width / 2, size.height / 2);
    final r     = (math.min(size.width, size.height) - strokeWidth) / 2;
    const gap   = 0.05;
    const start = -math.pi / 2;
    var angle   = start;

    for (final seg in segments) {
      if (seg.value <= 0) continue;
      final sweep = (seg.value / total) * 2 * math.pi - gap;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        angle + gap / 2,
        sweep,
        false,
        Paint()
          ..style       = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap   = StrokeCap.butt
          ..color       = seg.color,
      );
      angle += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.total != total;
}

// ─── 5. Compliance Health ─────────────────────────────────────────────────────

class _ComplianceSection extends StatelessWidget {
  const _ComplianceSection({
    required this.openCount,
    required this.criticalCount,
    required this.onTap,
  });

  final int          openCount;
  final int          criticalCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    final score = math.max(
        0, 100 - criticalCount * 15 - (openCount - criticalCount) * 5);
    final scoreColor = score >= 80
        ? const Color(0xFF1B5E20)
        : score >= 55
            ? _C.amber
            : _C.rose;

    return _SectionCard(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      onTap:  onTap,
      child: Row(
        children: [
          SizedBox(
            width:  68,
            height: 68,
            child: CustomPaint(
              painter: _RingGaugePainter(
                  fraction: score / 100, color: scoreColor),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color:      scoreColor,
                        height:     1,
                      ),
                    ),
                    Text(
                      '/100',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scoreColor.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compliance Health',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  openCount == 0
                      ? 'All systems clear'
                      : '$openCount open alert${openCount == 1 ? '' : 's'}'
                        '${criticalCount > 0 ? ' · $criticalCount critical' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: openCount > 0
                        ? scoreColor
                        : const Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:           score / 100,
                    minHeight:       6,
                    backgroundColor: scoreColor.withAlpha(28),
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _showScoreRubric(context, score),
                child: Icon(Icons.info_outline,
                    color: cs.onSurfaceVariant, size: 18),
              ),
              const SizedBox(height: 4),
              Icon(Icons.chevron_right, color: cs.outlineVariant, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  void _showScoreRubric(BuildContext context, int score) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'How is the score calculated?',
              style: Theme.of(ctx).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _RubricRow(label: 'Start score',             value: '100'),
            _RubricRow(label: 'Per critical alert',      value: '−15'),
            _RubricRow(label: 'Per non-critical alert',  value: '−5'),
            const Divider(height: 24),
            _RubricRow(
              label: 'Your current score',
              value: '$score / 100',
              bold:  true,
              color: score >= 80
                  ? PayrollTokens.green
                  : score >= 55
                      ? PayrollTokens.amber
                      : PayrollTokens.rose,
            ),
            const SizedBox(height: 12),
            Text(
              'Resolve open compliance alerts to improve your score. '
              'Critical alerts (NMWA breaches, missing bank details) '
              'carry a higher penalty.',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RubricRow extends StatelessWidget {
  const _RubricRow({
    required this.label,
    required this.value,
    this.bold  = false,
    this.color,
  });
  final String label;
  final String value;
  final bool   bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(
          child: Text(label, style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
        ),
        Text(
          value,
          style: tt.bodyMedium?.copyWith(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color:      color ?? cs.onSurface,
          ),
        ),
      ]),
    );
  }
}

class _RingGaugePainter extends CustomPainter {
  const _RingGaugePainter({required this.fraction, required this.color});
  final double fraction;
  final Color  color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (math.min(size.width, size.height) - 8) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      0,
      2 * math.pi,
      false,
      Paint()
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color       = color.withAlpha(28),
    );
    if (fraction > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        fraction * 2 * math.pi,
        false,
        Paint()
          ..style       = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap   = StrokeCap.round
          ..color       = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingGaugePainter old) => old.fraction != fraction;
}

// ─── 6. Pay Run Status Tracker ────────────────────────────────────────────────

class _PayRunTracker extends StatelessWidget {
  const _PayRunTracker({required this.payRun});
  final PayRun payRun;

  static const _stages = [
    PayRunStatus.draft,
    PayRunStatus.calculated,
    PayRunStatus.pendingApproval,
    PayRunStatus.approved,
    PayRunStatus.disbursed,
  ];
  static const _labels = [
    'Draft', 'Calculated', 'Approval', 'Approved', 'Disbursed'
  ];

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final cs         = theme.colorScheme;
    final currentIdx = payRun.status == PayRunStatus.cancelled
        ? -1
        : _stages.indexOf(payRun.status);

    return _SectionCard(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SectionTitle(
                  title:    'Pay Run Status',
                  subtitle: DateFormat('MMMM y').format(payRun.periodStart),
                  icon:     Icons.receipt_long_outlined,
                ),
              ),
              if (payRun.status == PayRunStatus.cancelled)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:        _C.rose.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Cancelled',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: _C.rose, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_stages.length, (i) {
              final isComplete = i < currentIdx;
              final isCurrent  = i == currentIdx;
              final connLeft   = i > 0 && (i - 1) < currentIdx;
              final connRight  = i < _stages.length - 1 && i < currentIdx;

              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (i > 0)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: connLeft
                                  ? _C.teal
                                  : cs.outlineVariant,
                            ),
                          ),
                        Container(
                          width:  26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isComplete
                                ? _C.teal
                                : isCurrent
                                    ? _C.navy
                                    : Colors.transparent,
                            border: Border.all(
                              color: isComplete
                                  ? _C.teal
                                  : isCurrent
                                      ? _C.navy
                                      : cs.outlineVariant,
                              width: 2,
                            ),
                          ),
                          child: isComplete
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 13)
                              : isCurrent
                                  ? Center(
                                      child: Container(
                                        width:  8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : null,
                        ),
                        if (i < _stages.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: connRight
                                  ? _C.teal
                                  : cs.outlineVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _labels[i],
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize:   11,
                        fontWeight: isCurrent
                            ? FontWeight.w700
                            : FontWeight.normal,
                        color: isCurrent
                            ? _C.navy
                            : cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── 7. Pending Actions ───────────────────────────────────────────────────────

class _PendingActions extends StatelessWidget {
  const _PendingActions({
    required this.alerts,
    required this.leaveRequests,
    required this.empMap,
    required this.typeMap,
    required this.navContext,
  });

  final List<ComplianceAlert>  alerts;
  final List<LeaveRequest>     leaveRequests;
  final Map<String, String>    empMap;
  final Map<String, String>    typeMap;
  final BuildContext           navContext;

  @override
  Widget build(BuildContext context) {
    final total = alerts.length + leaveRequests.length;

    return _SectionCard(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title:    'Action Required',
            subtitle: '$total item${total == 1 ? '' : 's'} need attention',
            icon:     Icons.priority_high_rounded,
          ),
          const Divider(height: 20),
          ...alerts.take(3).map(
            (a) => _ActionItem(
              icon:      Icons.shield_outlined,
              iconColor: a.severity == ComplianceSeverity.critical
                  ? _C.rose
                  : _C.amber,
              title:    a.title,
              subtitle: a.description,
              onTap: () => navContext.push(AppRoutes.payrollCompliance),
            ),
          ),
          ...leaveRequests.take(2).map((lr) {
            final empName  = empMap[lr.employeeId] ?? 'Unknown Employee';
            final typeName = typeMap[lr.leaveTypeId] ?? 'Leave';
            return _ActionItem(
              icon:      Icons.event_available_outlined,
              iconColor: _C.purple,
              title:     '$empName · Leave Request',
              subtitle:  '$typeName · awaiting approval',
              onTap: () => navContext.push(AppRoutes.payrollLeave),
            );
          }),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData      icon;
  final Color         iconColor;
  final String        title;
  final String        subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width:  36,
              height: 36,
              decoration: BoxDecoration(
                color:        iconColor.withAlpha(22),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color:      cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 12, color: cs.outlineVariant),
          ],
        ),
      ),
    );
  }
}

// ─── 8. Module Navigation ─────────────────────────────────────────────────────

class _Module {
  const _Module({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.route,
    required this.color,
  });
  final IconData icon;
  final String   label;
  final String   subtitle;
  final String   route;
  final Color    color;
}

class _ModuleNav extends StatelessWidget {
  const _ModuleNav();

  // Primary: high-frequency daily-use modules (shown as 2-col tiles)
  static const _primary = <_Module>[
    _Module(icon: Icons.receipt_long_rounded,     label: 'Pay Runs',      subtitle: 'Process payroll',     route: AppRoutes.payrollPayRuns,       color: _C.teal),
    _Module(icon: Icons.schedule_rounded,         label: 'Attendance',    subtitle: 'Time & clock-in',     route: AppRoutes.payrollAttendance,    color: _C.indigo),
    _Module(icon: Icons.description_outlined,     label: 'Payslips',      subtitle: 'Employee slips',      route: AppRoutes.payrollPayslips,      color: _C.sky),
    _Module(icon: Icons.account_balance_outlined, label: 'Deductions',    subtitle: 'UIF · PAYE · COIDA',  route: AppRoutes.payrollDeductions,    color: _C.amber),
    _Module(icon: Icons.payments_outlined,        label: 'Disbursements', subtitle: 'Payment status',      route: AppRoutes.payrollDisbursements, color: _C.teal),
    _Module(icon: Icons.bar_chart_rounded,        label: 'Reports',       subtitle: 'Analytics & exports', route: AppRoutes.payrollReports,       color: _C.navy),
  ];

  // Secondary: admin / HR / compliance modules (shown as compact 3-col icon grid)
  static const _secondary = <_Module>[
    _Module(icon: Icons.verified_user_outlined, label: 'Compliance',     subtitle: 'BCEA · LRA · NMWA', route: AppRoutes.payrollCompliance,     color: _C.rose),
    _Module(icon: Icons.history_outlined,       label: 'Audit Log',      subtitle: 'Change history',    route: AppRoutes.payrollAuditLog,       color: _C.indigo),
    _Module(icon: Icons.warning_amber_outlined, label: 'Incidents',      subtitle: 'Disciplinary & IR', route: AppRoutes.payrollIncidents,      color: _C.amber),
    _Module(icon: Icons.notifications_outlined,         label: 'Communications', subtitle: 'SMS & alerts',      route: AppRoutes.payrollCommunications, color: _C.purple),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary modules — 2-column tiles
          Text(
            'Modules',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap:   true,
            physics:      const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:   2,
              mainAxisSpacing:  10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.8,
            ),
            itemCount:   _primary.length,
            itemBuilder: (context, i) => _ModuleTile(module: _primary[i]),
          ),
          const SizedBox(height: 16),

          // Secondary modules — compact 4-column icon buttons
          Text(
            'Admin & Compliance',
            style: theme.textTheme.labelMedium?.copyWith(
              color:      cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _secondary.map((m) => Expanded(
              child: _CompactModuleTile(module: m),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.module});
  final _Module module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Material(
      color:        cs.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(module.route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border:       Border.all(color: cs.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width:  36,
                height: 36,
                decoration: BoxDecoration(
                  color:        module.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(module.icon, color: module.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:  MainAxisAlignment.center,
                  children: [
                    Text(
                      module.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:      cs.onSurface,
                      ),
                    ),
                    Text(
                      module.subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:    cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Compact secondary module tile ────────────────────────────────────────────

class _CompactModuleTile extends StatelessWidget {
  const _CompactModuleTile({required this.module});
  final _Module module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Material(
      color:        Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(module.route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width:  36,
                height: 36,
                decoration: BoxDecoration(
                  color:        module.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(module.icon, color: module.color, size: 18),
              ),
              const SizedBox(height: 5),
              Text(
                module.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color:      cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines:  2,
                overflow:  TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared Layout Widgets ────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.margin, this.onTap});

  final Widget              child;
  final EdgeInsetsGeometry? margin;
  final VoidCallback?       onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final card = Container(
      decoration: BoxDecoration(
        color:        cs.surface,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withAlpha(10),
            blurRadius: 8,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          type:  MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child:   child,
            ),
          ),
        ),
      ),
    );

    return margin != null ? Padding(padding: margin!, child: card) : card;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String   title;
  final String   subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:       MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

