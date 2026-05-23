import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/shift.dart';
import '../../providers/payroll_action_providers.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

final _dfDay   = DateFormat('E');       // Mon, Tue …
final _dfDate  = DateFormat('d');       // 1, 2 …
final _dfMonth = DateFormat('MMM yyyy');
final _dfShift = DateFormat('EEE d MMM');

class RosterBoardScreen extends ConsumerStatefulWidget {
  const RosterBoardScreen({super.key});

  @override
  ConsumerState<RosterBoardScreen> createState() => _RosterBoardScreenState();
}

class _RosterBoardScreenState extends ConsumerState<RosterBoardScreen> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
  }

  List<DateTime> get _days =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  void _prevWeek() =>
      setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
  void _nextWeek() =>
      setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(activeEmployeesProvider);
    final days      = _days;
    final today     = DateTime.now();
    final tt        = Theme.of(context).textTheme;
    bool isToday(DateTime d) =>
        d.year == today.year && d.month == today.month && d.day == today.day;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Roster \u2014 ${_dfMonth.format(_weekStart)}',
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _prevWeek,
            tooltip: 'Previous week',
          ),
          TextButton(
            onPressed: () => setState(() {
              final now2 = DateTime.now();
              _weekStart = now2.subtract(Duration(days: now2.weekday - 1));
            }),
            child: const Text('Today',
                style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextWeek,
            tooltip: 'Next week',
          ),
          const SizedBox(width: AppSpacing.xs),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {
              if (v == 'piecework') {
                context.push(AppRoutes.payrollAddPieceworkLog);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'piecework',
                child: ListTile(
                  leading: Icon(Icons.agriculture_outlined),
                  title: Text('Log Piecework'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: PayrollTokens.navy,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Shift',
            style: TextStyle(color: Colors.white)),
        onPressed: () => context.push(AppRoutes.payrollAddShift),
      ),
      body: employees.isEmpty
          ? const Center(child: Text('No active employees.'))
          : Column(
              children: [
                // ── Day-header row ─────────────────────────────────────
                _DayHeaderRow(days: days, isToday: isToday, tt: tt),
                const Divider(height: 1),

                // ── Employee rows ──────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    itemCount: employees.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 100),
                    itemBuilder: (context, idx) {
                      final emp = employees[idx];
                      return _EmployeeRosterRow(
                        employeeId: emp.id,
                        employeeName:
                            '${emp.firstName} ${emp.lastName}',
                        weekStart: _weekStart,
                        days: days,
                        isToday: isToday,
                        tt: tt,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Day header ────────────────────────────────────────────────────────────────

class _DayHeaderRow extends StatelessWidget {
  const _DayHeaderRow({
    required this.days,
    required this.isToday,
    required this.tt,
  });
  final List<DateTime> days;
  final bool Function(DateTime) isToday;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          // Employee name column header
          SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Text('Employee',
                  style: tt.labelSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
          ...days.map((d) {
            final today = isToday(d);
            return Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: today
                    ? BoxDecoration(
                        color: PayrollTokens.navy,
                        borderRadius: BorderRadius.circular(6),
                      )
                    : null,
                margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _dfDay.format(d),
                      style: tt.labelSmall?.copyWith(
                        color: today
                            ? Colors.white.withValues(alpha: 0.7)
                            : cs.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      _dfDate.format(d),
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: today ? Colors.white : cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Employee row ──────────────────────────────────────────────────────────────

class _EmployeeRosterRow extends ConsumerWidget {
  const _EmployeeRosterRow({
    required this.employeeId,
    required this.employeeName,
    required this.weekStart,
    required this.days,
    required this.isToday,
    required this.tt,
  });
  final String employeeId;
  final String employeeName;
  final DateTime weekStart;
  final List<DateTime> days;
  final bool Function(DateTime) isToday;
  final TextTheme tt;

  Shift? _shiftForDay(List<Shift> shifts, DateTime day) {
    for (final s in shifts) {
      if (s.date.year == day.year &&
          s.date.month == day.month &&
          s.date.day == day.day) {
        return s;
      }
    }
    return null;
  }

  void _onCellTap(
      BuildContext context, WidgetRef ref, DateTime day, Shift? shift) {
    if (shift == null) {
      context.push(AppRoutes.payrollAddShift, extra: day);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final btt = Theme.of(ctx).textTheme;
        final bcs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md,
              AppSpacing.lg, AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: bcs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: PayrollTokens.navy.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.calendar_month_outlined,
                        size: 24, color: PayrollTokens.navy),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shift.taskCode,
                            style: btt.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          '${_dfShift.format(day)}  •  '
                          '${shift.startTime}–${shift.endTime}',
                          style: btt.bodySmall
                              ?.copyWith(color: bcs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (shift.fieldOrArea != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Padding(
                  padding: const EdgeInsets.only(left: 48),
                  child: Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 14, color: bcs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(shift.fieldOrArea!,
                          style: btt.bodySmall
                              ?.copyWith(color: bcs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Shift'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push(
                            AppRoutes.payrollEditShift(shift.id),
                            extra: shift);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                          backgroundColor: PayrollTokens.rose),
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.white),
                      label: const Text('Delete',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref
                            .read(shiftNotifierProvider.notifier)
                            .delete(shift.id);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shifts = ref.watch(
        shiftsProvider(ShiftFilter(weekStart: weekStart, employeeId: employeeId)));
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          // Name
          SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Text(
                employeeName,
                style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Day cells
          ...days.map((d) {
            final isWknd    = d.weekday >= 6;
            final todayMark = isToday(d);
            final shift     = _shiftForDay(shifts, d);
            final hasShift  = shift != null;

            // Determine cell color
            Color bgColor;
            if (todayMark && hasShift) {
              bgColor = PayrollTokens.sky.withValues(alpha: 0.25);
            } else if (todayMark) {
              bgColor = PayrollTokens.sky.withValues(alpha: 0.12);
            } else if (hasShift) {
              bgColor = PayrollTokens.green.withValues(alpha: 0.14);
            } else if (isWknd) {
              bgColor = PayrollTokens.amber.withValues(alpha: 0.10);
            } else {
              bgColor = cs.surfaceContainerLow.withValues(alpha: 0.5);
            }

            return Expanded(
              child: GestureDetector(
                onTap: () => _onCellTap(context, ref, d, shift),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6),
                    border: todayMark
                        ? Border.all(
                            color: PayrollTokens.navy.withValues(alpha: 0.5),
                            width: 1.5)
                        : Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  alignment: Alignment.center,
                  child: hasShift
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              shift.taskCode.length > 6
                                  ? shift.taskCode.substring(0, 6)
                                  : shift.taskCode,
                              style: tt.labelSmall?.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: PayrollTokens.green,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              shift.startTime,
                              style: tt.labelSmall?.copyWith(
                                fontSize: 9,
                                color: PayrollTokens.navy,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          isWknd ? 'OFF' : '--',
                          style: tt.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isWknd
                                ? PayrollTokens.amber
                                : cs.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                        ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
