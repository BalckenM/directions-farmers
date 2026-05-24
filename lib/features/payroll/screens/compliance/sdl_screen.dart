// SDL (Skills Development Levy) compliance screen.
//
// SDL = 1% of total gross payroll per month, payable if the employer''s
// annual payroll exceeds R500,000 (SARS threshold). Small employers below
// this threshold are exempt. Paid together with PAYE/UIF on EMP201.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/pay_run.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

final _zarD = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 2);

const double _sdlRate            = 0.01;
const double _sdlAnnualThreshold = 500000.0;

// ─────────────────────────────────────────────────────────────────────────────

class SdlScreen extends ConsumerWidget {
  const SdlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPayRuns = ref.watch(allPayRunsProvider);

    final disbursed = allPayRuns
        .where((r) =>
            r.status == PayRunStatus.disbursed ||
            r.status == PayRunStatus.approved ||
            r.status == PayRunStatus.calculated)
        .toList()
      ..sort((a, b) => b.payDate.compareTo(a.payDate));

    // Rolling 12-month gross payroll
    final cutoff      = DateTime.now().subtract(const Duration(days: 365));
    final last12Gross = disbursed
        .where((r) => r.payDate.isAfter(cutoff))
        .fold(0.0, (s, r) => s + r.totalGross);

    final isLiable  = last12Gross > _sdlAnnualThreshold;
    final annualSdl = isLiable ? last12Gross * _sdlRate : 0.0;

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'SDL — Skills Development Levy'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _StatusHeader(isLiable: isLiable, annualGross: last12Gross),
          const SizedBox(height: 14),
          _MetricsRow(
            isLiable:    isLiable,
            annualGross: last12Gross,
            annualSdl:   annualSdl,
          ),
          const SizedBox(height: 18),
          _PayRunBreakdown(disbursed: disbursed, isLiable: isLiable),
          const SizedBox(height: 24),
          const _RegulatoryNote(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Liability status header ──────────────────────────────────────────────────

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.isLiable, required this.annualGross});

  final bool   isLiable;
  final double annualGross;

  @override
  Widget build(BuildContext context) {
    final tt          = Theme.of(context).textTheme;
    final statusColor = isLiable ? PayrollTokens.rose : PayrollTokens.green;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PayrollTokens.navy, Color.fromARGB(255, 46, 89, 132)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school_outlined, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SKILLS DEVELOPMENT LEVY',
                      style: tt.labelSmall?.copyWith(
                        color: Colors.white.withAlpha(170),
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLiable ? 'SDL Liable' : 'SDL Exempt',
                      style: tt.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: isLiable ? 'LIABLE' : 'EXEMPT',
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Rolling 12-month payroll: ${_zarD.format(annualGross)}',
            style: tt.bodySmall?.copyWith(color: Colors.white.withAlpha(180)),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (annualGross / (_sdlAnnualThreshold * 1.5)).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white.withAlpha(30),
              valueColor: AlwaysStoppedAnimation<Color>(
                isLiable ? const Color(0xFFFF7043) : const Color(0xFF81C784),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Threshold: ${_zarD.format(_sdlAnnualThreshold)} annual gross',
            style: tt.labelSmall?.copyWith(color: Colors.white.withAlpha(130)),
          ),
        ],
      ),
    );
  }
}

// ─── Key metrics row ──────────────────────────────────────────────────────────

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.isLiable,
    required this.annualGross,
    required this.annualSdl,
  });

  final bool   isLiable;
  final double annualGross;
  final double annualSdl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon:        Icons.account_balance_wallet_outlined,
            accentColor: PayrollTokens.teal,
            label:       'Annual Gross',
            value:       _zarD.format(annualGross),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon:        Icons.percent_rounded,
            accentColor: PayrollTokens.indigo,
            label:       'SDL Rate',
            value:       '1.0%',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon:        Icons.payments_outlined,
            accentColor: isLiable ? PayrollTokens.rose : PayrollTokens.green,
            label:       'Annual SDL',
            value:       isLiable ? _zarD.format(annualSdl) : 'Exempt',
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.accentColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color    accentColor;
  final String   label;
  final String   value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
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
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color:      cs.onSurface,
            ),
            maxLines:  1,
            overflow:  TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Per pay-run breakdown ─────────────────────────────────────────────────────

class _PayRunBreakdown extends StatelessWidget {
  const _PayRunBreakdown({required this.disbursed, required this.isLiable});

  final List<PayRun> disbursed;
  final bool         isLiable;

  static final _df = DateFormat('dd MMM yy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color:        cs.surface,
        borderRadius: BorderRadius.circular(16),
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
          // section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width:  34,
                  height: 34,
                  decoration: BoxDecoration(
                    color:        PayrollTokens.navy.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    size:  18,
                    color: PayrollTokens.navy,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pay Run Breakdown',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'SDL per pay run · latest first',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          // column headings
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Period',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:       cs.onSurfaceVariant,
                      fontWeight:  FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Gross',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:       cs.onSurfaceVariant,
                      fontWeight:  FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'SDL (1%)',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:       cs.onSurfaceVariant,
                      fontWeight:  FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
          const Divider(height: 1),

          if (disbursed.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: EmptyState(
                icon:     const Icon(Icons.receipt_long_outlined, size: 56),
                title:    'No pay runs found',
                subtitle: 'Completed pay runs will appear here.',
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics:    const NeverScrollableScrollPhysics(),
              itemCount:  disbursed.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final r   = disbursed[i];
                final sdl = isLiable ? r.totalGross * _sdlRate : 0.0;
                return _PayRunRow(
                  period: '${_df.format(r.periodStart)} – ${_df.format(r.periodEnd)}',
                  gross:  _zarD.format(r.totalGross),
                  sdl:    sdl > 0 ? _zarD.format(sdl) : '—',
                  liable: isLiable,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _PayRunRow extends StatelessWidget {
  const _PayRunRow({
    required this.period,
    required this.gross,
    required this.sdl,
    required this.liable,
  });

  final String period;
  final String gross;
  final String sdl;
  final bool   liable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              period,
              style: theme.textTheme.bodySmall?.copyWith(
                color:      cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              gross,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              sdl,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                color:      liable ? PayrollTokens.rose : cs.onSurfaceVariant,
                fontWeight: liable ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            liable ? Icons.check_circle_outline : Icons.remove_circle_outline,
            size:  16,
            color: liable ? PayrollTokens.rose : PayrollTokens.green,
          ),
        ],
      ),
    );
  }
}

// ─── Regulatory note ──────────────────────────────────────────────────────────

class _RegulatoryNote extends StatelessWidget {
  const _RegulatoryNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        PayrollTokens.sky.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: PayrollTokens.sky.withAlpha(40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: PayrollTokens.sky),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'SDL is paid monthly via your EMP201 return, together with PAYE '
              'and UIF. Employers with an annual payroll below '
              'R500,000 are fully exempt. Rate: 1% of gross monthly payroll.',
              style: theme.textTheme.bodySmall?.copyWith(
                color:  cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
