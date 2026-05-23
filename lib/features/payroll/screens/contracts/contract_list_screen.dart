import 'package:flutter/material.dart';
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
import '../../models/employment_contract.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';
import '../../widgets/pr_amount_badge.dart';


class ContractListScreen extends ConsumerStatefulWidget {
  const ContractListScreen({super.key});

  @override
  ConsumerState<ContractListScreen> createState() => _ContractListScreenState();
}

class _ContractListScreenState extends ConsumerState<ContractListScreen> {
  ContractStatus? _filterStatus;

  static Color _statusColor(ContractStatus s) => switch (s) {
        ContractStatus.signed      => PayrollTokens.green,
        ContractStatus.draft       => PayrollTokens.amber,
        ContractStatus.expired     => PayrollTokens.rose,
        ContractStatus.terminated  => Colors.grey,
      };

  static String _statusLabel(ContractStatus s) => switch (s) {
        ContractStatus.signed      => 'Signed',
        ContractStatus.draft       => 'Draft',
        ContractStatus.expired     => 'Expired',
        ContractStatus.terminated  => 'Terminated',
      };

  static String _typeLabel(ContractType t) => switch (t) {
        ContractType.permanent  => 'Permanent',
        ContractType.fixedTerm  => 'Fixed Term',
        ContractType.seasonal   => 'Seasonal',
        ContractType.casual     => 'Casual',
      };

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final all = ref.watch(contractsProvider(null));
    final employees = ref.watch(activeEmployeesProvider);
    final empMap = {for (final e in employees) e.id: '${e.firstName} ${e.lastName}'};

    final filtered = _filterStatus == null
        ? all
        : all.where((c) => c.status == _filterStatus).toList();

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final zar = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Contracts'),
      body: Column(
        children: [
          // â”€â”€ Filter chips â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            color: cs.surface,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _filterStatus == null,
                    onTap: () => setState(() => _filterStatus = null),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ...ContractStatus.values.map((s) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: _FilterChip(
                          label: _statusLabel(s),
                          color: _statusColor(s),
                          selected: _filterStatus == s,
                          onTap: () => setState(
                              () => _filterStatus = _filterStatus == s ? null : s),
                        ),
                      )),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant),

          // â”€â”€ Contract list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icon(Icons.description_outlined),
                    title: 'No contracts',
                    subtitle: 'Employment contracts will appear here.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final c = filtered[i];
                      final empName = empMap[c.employeeId] ?? c.employeeId;
                      return _ContractCard(
                        contract: c,
                        employeeName: empName,
                        statusColor: _statusColor(c.status),
                        statusLabel: _statusLabel(c.status),
                        typeLabel: _typeLabel(c.type),
                        zar: zar,
                        tt: tt,
                        cs: cs,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ContractCard extends StatelessWidget {
  const _ContractCard({
    required this.contract,
    required this.employeeName,
    required this.statusColor,
    required this.statusLabel,
    required this.typeLabel,
    required this.zar,
    required this.tt,
    required this.cs,
  });

  final EmploymentContract contract;
  final String employeeName;
  final Color statusColor;
  final String statusLabel;
  final String typeLabel;
  final NumberFormat zar;
  final TextTheme tt;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    int? daysLeft;
    Color? expiryColor;
    if (contract.endDate != null && contract.isActive) {
      daysLeft = contract.endDate!.difference(now).inDays;
      expiryColor = daysLeft < 0 ? PayrollTokens.rose : daysLeft < 30 ? PayrollTokens.amber : null;
    }

    final initials = employeeName
        .split(' ')
        .take(2)
        .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
        .join();

    return InkWell(
      onTap: () => GoRouter.of(context).push(AppRoutes.payrollContractDetail(contract.id)),
      borderRadius: AppRadius.card,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.card,
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // â”€â”€ Left accent bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              // â”€â”€ Content â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: PayrollTokens.navy.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: tt.titleSmall?.copyWith(
                              color: PayrollTokens.navy, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    employeeName,
                                    style: tt.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                PrAmountBadge(
                                  amount: '${zar.format(contract.grossMonthlySalary)}/mo',
                                  backgroundColor: PayrollTokens.teal.withValues(alpha: 0.12),
                                  textColor: PayrollTokens.teal,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              contract.jobDescription,
                              style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                StatusChip(
                                  label: statusLabel,
                                  color: statusColor,
                                  small: true,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                StatusChip(
                                  label: typeLabel,
                                  color: PayrollTokens.navy,
                                  small: true,
                                ),
                                if (daysLeft != null) ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  StatusChip(
                                    label: daysLeft < 0
                                        ? 'Expired'
                                        : '$daysLeft days left',
                                    color: expiryColor ?? PayrollTokens.green,
                                    icon: Icons.schedule_outlined,
                                    small: true,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                    ],
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final activeColor = color ?? PayrollTokens.navy;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.12)
              : cs.surfaceContainerHighest,
          borderRadius: AppRadius.chip,
          border: Border.all(
            color: selected ? activeColor : cs.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? activeColor : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
