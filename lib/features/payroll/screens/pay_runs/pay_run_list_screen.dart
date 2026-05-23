import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/pay_run.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';
import '../../widgets/payroll_widgets.dart';

final _dateFmt = DateFormat('d MMM y');
final _zarFmt  = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);

// ─── Screen ───────────────────────────────────────────────────────────────────

class PayRunListScreen extends ConsumerStatefulWidget {
  const PayRunListScreen({super.key});

  @override
  ConsumerState<PayRunListScreen> createState() => _PayRunListScreenState();
}

class _PayRunListScreenState extends ConsumerState<PayRunListScreen> {
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _initialLoadDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final payRuns = ref.watch(allPayRunsProvider);

    if (!_initialLoadDone && payRuns.isEmpty) {
      return FarmScaffold(
        appBar: const FarmAppBar(title: 'Pay Runs'),
        floatingActionButton: _fab(context),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer.list(count: 4, itemHeight: 80),
        ),
      );
    }
    _initialLoadDone = true;

    if (payRuns.isEmpty) {
      return FarmScaffold(
        appBar: const FarmAppBar(title: 'Pay Runs'),
        floatingActionButton: _fab(context),
        body: EmptyState(
          icon: const Icon(Icons.receipt_long_outlined, size: 56),
          title: 'No pay runs yet',
          subtitle: 'Tap "New Run" to calculate your first payroll.',
        ),
      );
    }

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Pay Runs'),
      floatingActionButton: _fab(context),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(allPayRunsProvider),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            100,
          ),
          itemCount: payRuns.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) => _PayRunTile(run: payRuns[i]),
        ),
      ),
    );
  }

  Widget _fab(BuildContext context) => FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.payrollRunPayroll),
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('New Run'),
        backgroundColor: PayrollTokens.navy,
        foregroundColor: Colors.white,
      );
}

// ─── Pay run tile ─────────────────────────────────────────────────────────────

class _PayRunTile extends StatelessWidget {
  const _PayRunTile({required this.run});
  final PayRun run;

  @override
  Widget build(BuildContext context) {
    final cs          = Theme.of(context).colorScheme;
    final tt          = Theme.of(context).textTheme;
    final period      = '${_dateFmt.format(run.periodStart)} – ${_dateFmt.format(run.periodEnd)}';
    final statusColor = PayrollTokens.payRunStatusColor(run.status);

    return Material(
      color:        cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(AppRoutes.payrollPayRunDetail(run.id)),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border:       Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              // Status icon badge
              Container(
                width:  44,
                height: 44,
                decoration: BoxDecoration(
                  color:        statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.receipt_long_outlined, color: statusColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              // Period & employee count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      period,
                      style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${run.employeeCount} employee${run.employeeCount == 1 ? '' : 's'}',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              // Amount + status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PrAmountBadge(amount: _zarFmt.format(run.totalNet)),
                  const SizedBox(height: AppSpacing.xs),
                  StatusChip(
                    label: PayrollTokens.payRunStatusLabel(run.status),
                    color: statusColor,
                    small: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
