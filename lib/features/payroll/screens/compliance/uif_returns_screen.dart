import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mobile_app/features/payroll/providers/payroll_providers.dart';
import 'package:mobile_app/features/payroll/services/uif_export_service.dart';

final _zar = NumberFormat.currency(
  locale: 'en_ZA',
  symbol: 'R ',
  decimalDigits: 2,
);

enum FiledStatus { notFiled, filed, exported }

class UifReturnsScreen extends ConsumerStatefulWidget {
  const UifReturnsScreen({super.key});

  @override
  ConsumerState<UifReturnsScreen> createState() => _UifReturnsScreenState();
}

class _UifReturnsScreenState extends ConsumerState<UifReturnsScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  FiledStatus _filedStatus = FiledStatus.notFiled;

  String _fmt(DateTime d) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[d.month]} ${d.year}';
  }

  void _prevMonth() => setState(
    () => _selectedMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month - 1,
    ),
  );
  void _nextMonth() => setState(
    () => _selectedMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(activeEmployeesProvider);
    final alerts = ref.watch(complianceAlertsProvider);
    final uifAlerts = alerts.where((a) => a.code.startsWith('UIF')).toList();

    // UIF rate: 1% employee + 1% employer
    const double uifRate = 0.01;
    // Mock UIF income per employee based on pay structures
    final uifRows = employees.map((emp) {
      final uifIncome = 17712.0; // SARS 2024 UIF ceiling per month
      return (
        emp.fullName,
        uifIncome,
        uifIncome * uifRate, // employee contribution
        uifIncome * uifRate, // employer contribution
      );
    }).toList();

    final totalEmployee = uifRows.fold(0.0, (s, r) => s + r.$3);
    final totalEmployer = uifRows.fold(0.0, (s, r) => s + r.$4);
    final totalUif = totalEmployee + totalEmployer;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'UIF Returns',
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export UI-19',
            onPressed: () =>
                _exportUI19(context, uifRows, _fmt(_selectedMonth)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Period selector
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: _prevMonth,
                ),
                Expanded(
                  child: Text(
                    _fmt(_selectedMonth),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          if (uifAlerts.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_outlined,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${uifAlerts.length} UIF compliance alert(s) require attention',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Summary row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    'Employee Contr.',
                    _zar.format(totalEmployee),
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    'Employer Contr.',
                    _zar.format(totalEmployer),
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    'Total UIF',
                    _zar.format(totalUif),
                    AppColors.success,
                    large: true,
                  ),
                ),
              ],
            ),
          ),
          // Table
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.table_chart_outlined,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'UI-19 Breakdown',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${uifRows.length} employees',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  const _TableHeader(),
                  const Divider(height: 1),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: uifRows.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 16),
              itemBuilder: (ctx, i) {
                final (name, income, empContr, emplContr) = uifRows[i];
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _zar.format(income),
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _zar.format(empContr),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _zar.format(emplContr),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Export button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text(
                  'Generate UI-19 Export',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: () =>
                    _exportUI19(context, uifRows, _fmt(_selectedMonth)),
              ),
            ),
          ),
          // Mark as Filed button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(
                  _filedStatus != FiledStatus.notFiled
                      ? Icons.check_circle_outline
                      : Icons.mark_email_read_outlined,
                  color: _filedStatus != FiledStatus.notFiled
                      ? AppColors.success
                      : AppColors.primary,
                ),
                label: Text(
                  _filedStatus != FiledStatus.notFiled
                      ? 'Filed \u2713'
                      : 'Mark as Filed',
                  style: TextStyle(
                    color: _filedStatus != FiledStatus.notFiled
                        ? AppColors.success
                        : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _filedStatus != FiledStatus.notFiled
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
                onPressed: _filedStatus != FiledStatus.notFiled
                    ? null
                    : () => setState(() => _filedStatus = FiledStatus.filed),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportUI19(
    BuildContext context,
    List<(String, double, double, double)> rows,
    String period,
  ) async {
    // Build payslip-shaped data for the service from the displayed rows.
    final payslips = ref.read(payslipsProvider(const PayslipFilter()));
    final employees = ref.read(activeEmployeesProvider);
    final config = ref.read(payrollRepositoryProvider).getEmployerConfig();

    // Filter payslips by the currently selected month.
    final monthStart = _selectedMonth;
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);
    final filtered = payslips
        .where(
          (p) =>
              !p.periodEnd.isBefore(monthStart) &&
              !p.periodStart.isAfter(monthEnd),
        )
        .toList();

    final csv = UifExportService.generateUi19Csv(
      payslips: filtered,
      employees: employees,
      config: config,
      period: DateFormat('yyyy-MM').format(monthStart),
    );

    final dir = await getApplicationDocumentsDirectory();
    final filename = UifExportService.filenameFor(config, monthStart);
    await File('${dir.path}/$filename').writeAsString(csv);
    if (context.mounted) {
      setState(() => _filedStatus = FiledStatus.exported);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported: $filename (${filtered.length} payslips)'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.color, {this.large = false});
  final String label, value;
  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: large ? 14 : 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 244, 246, 249),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              'Employee',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'UIF Income',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Emp. (1%)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Emplr (1%)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
