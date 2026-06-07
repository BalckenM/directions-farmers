import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/router/app_routes.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_radius.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/features/payroll/models/leave_balance.dart';
import 'package:mobile_app/features/payroll/providers/payroll_providers.dart';
import 'package:mobile_app/features/payroll/theme/payroll_tokens.dart';
import 'package:mobile_app/shared/widgets/empty_state.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/shared/widgets/farm_dropdown.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';
import 'package:mobile_app/shared/widgets/avatar_widget.dart';

class LeaveBalanceScreen extends ConsumerStatefulWidget {
  const LeaveBalanceScreen({super.key});

  @override
  ConsumerState<LeaveBalanceScreen> createState() => _LeaveBalanceScreenState();
}

class _LeaveBalanceScreenState extends ConsumerState<LeaveBalanceScreen> {
  String? _employeeId;

  Color _barColor(double pct) => pct > 0.5
      ? AppColors.success
      : pct > 0.25
      ? AppColors.warning
      : AppColors.error;

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(activeEmployeesProvider);
    final balances = ref.watch(leaveBalancesProvider(_employeeId));
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final empMap = {
      for (final e in employees) e.id: '${e.firstName} ${e.lastName}',
    };
    final empImageMap = {for (final e in employees) e.id: e.profileImageUrl};

    // Group by employee when showing all
    final Map<String, List<LeaveBalance>> grouped = {};
    for (final b in balances) {
      grouped.putIfAbsent(b.employeeId, () => []).add(b);
    }

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Leave Balances'),
      body: Column(
        children: [
          // -- Filter bar ---------------------------------------------
          Container(
            color: cs.surface,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: FarmDropdown<String?>(
              label: 'Filter by employee',
              value: _employeeId,
              prefixIcon: const Icon(Icons.person_search_outlined),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All employees'),
                ),
                ...employees.map(
                  (e) => DropdownMenuItem(
                    value: e.id,
                    child: Text('${e.firstName} ${e.lastName}'),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _employeeId = v),
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant),

          // -- Balance list -------------------------------------------
          Expanded(
            child: balances.isEmpty
                ? const EmptyState(
                    icon: Icon(Icons.beach_access_outlined),
                    title: 'No leave balances',
                    subtitle: 'Leave balances will appear after setup.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, i) {
                      final empId = grouped.keys.elementAt(i);
                      final empBalances = grouped[empId]!;
                      final empName = empMap[empId] ?? empId;
                      final initials = empName
                          .split(' ')
                          .take(2)
                          .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
                          .join();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: AppRadius.card,
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // -- Employee header -------------------
                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: [
                                    AvatarWidget(
                                      imageUrl: empImageMap[empId],
                                      initials: initials,
                                      radius: 20,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            empName,
                                            style: tt.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            '${empBalances.length} leave type${empBalances.length == 1 ? '' : 's'}',
                                            style: tt.bodySmall?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => GoRouter.of(
                                        context,
                                      ).push(AppRoutes.payrollLeaveRequest),
                                      icon: const Icon(Icons.add, size: 16),
                                      label: const Text('Request'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.success,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: 4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(height: 1, color: cs.outlineVariant),

                              // -- Leave type rows -------------------
                              ...empBalances.map((b) {
                                final pct = b.totalEntitled > 0
                                    ? (b.remaining / b.totalEntitled).clamp(
                                        0.0,
                                        1.0,
                                      )
                                    : 0.0;
                                final barColor = _barColor(pct);

                                return _LeaveTypeRow(
                                  balance: b,
                                  barColor: barColor,
                                  pct: pct,
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LeaveTypeRow extends StatelessWidget {
  const _LeaveTypeRow({
    required this.balance,
    required this.barColor,
    required this.pct,
  });

  final LeaveBalance balance;
  final Color barColor;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Type name + remaining badge -------------------------
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: barColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  balance.leaveTypeName,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.chip,
                ),
                child: Text(
                  '${balance.remaining.toStringAsFixed(1)} days left',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: barColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // -- Progress bar ----------------------------------------
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 8),

          // -- Stat row: Entitled / Taken / Pending / Remaining ----
          Row(
            children: [
              _Stat('Entitled', balance.totalEntitled, cs, tt),
              _Stat('Taken', balance.taken, cs, tt),
              _Stat('Pending', balance.pending, cs, tt),
              _Stat(
                'Remaining',
                balance.remaining,
                cs,
                tt,
                color: barColor,
                bold: true,
              ),
            ],
          ),
          Divider(height: AppSpacing.md, color: cs.outlineVariant),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(
    this.label,
    this.value,
    this.cs,
    this.tt, {
    this.color,
    this.bold = false,
  });

  final String label;
  final double value;
  final ColorScheme cs;
  final TextTheme tt;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value.toStringAsFixed(1),
            style: tt.labelLarge?.copyWith(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: color ?? cs.onSurface,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
