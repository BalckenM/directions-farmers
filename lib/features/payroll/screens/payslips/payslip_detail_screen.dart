import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';
import '../../services/payslip_pdf_generator.dart';
import '../../widgets/payroll_widgets.dart';


final _zar    = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 2);
final _zarInt = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);
final _mf     = DateFormat('MMMM y');
final _df     = DateFormat('d MMMM y');

// Maps leave type codes (stored as snapshot keys) to human-readable labels.
String _leaveTypeLabel(String code) => switch (code.toUpperCase()) {
  'ANNUAL'              => 'Annual Leave',
  'SICK'                => 'Sick Leave',
  'MATERNITY'           => 'Maternity Leave',
  'PATERNITY'           => 'Paternity Leave',
  'FAMILY_RESPONSIBILITY' ||
  'FAMILY'              => 'Family Responsibility',
  'STUDY'               => 'Study Leave',
  'UNPAID'              => 'Unpaid Leave',
  _                     => _toTitleCase(code),
};

String _toTitleCase(String s) => s
    .replaceAll('_', ' ')
    .toLowerCase()
    .replaceAllMapped(RegExp(r'\b\w'), (m) => m.group(0)!.toUpperCase());

class PayslipDetailScreen extends ConsumerWidget {
  const PayslipDetailScreen({super.key, required this.payslipId});
  final String payslipId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPayslips = ref.watch(payslipsProvider(const PayslipFilter()));
    final payslip = allPayslips.where((p) => p.id == payslipId).firstOrNull;

    if (payslip == null) {
      return const FarmScaffold(
        appBar: FarmAppBar(title: 'Payslip'),
        body: Center(child: Text('Payslip not found.')),
      );
    }

    final employees = ref.watch(activeEmployeesProvider);
    final employee  = employees.where((e) => e.id == payslip.employeeId).firstOrNull;
    final employer  = ref.watch(employerConfigProvider);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Payslip \u00b7 ${_mf.format(payslip.periodStart)}',
        actions: [
          // Share payslip PDF via native share sheet (WhatsApp, email, etc.)
          IconButton(
            icon:    const Icon(Icons.share_outlined),
            tooltip: 'Share PDF',
            onPressed: () async {
              try {
                final bytes = await PayslipPdfGenerator.generate(
                  payslip:  payslip,
                  employee: employee,
                );
                final filename =
                    'payslip_${payslip.employeeId}_${_mf.format(payslip.periodStart).replaceAll(' ', '_')}.pdf';
                await Printing.sharePdf(
                  bytes: Uint8List.fromList(bytes),
                  filename: filename,
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Share failed: $e')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print / Save PDF',
            onPressed: () async {
              try {
                final bytes = await PayslipPdfGenerator.generate(
                  payslip: payslip,
                  employee: employee,
                );
                await Printing.layoutPdf(
                  onLayout: (_) async => Uint8List.fromList(bytes),
                  name:
                      'payslip_${payslip.employeeId}_${_mf.format(payslip.periodStart).replaceAll(' ', '_')}.pdf',
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PDF generation failed: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // -- Employer header
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          employer.name.toUpperCase(),
                          style: tt.titleLarge?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PAYSLIP',
                          style: tt.labelMedium
                              ?.copyWith(color: Colors.white, letterSpacing: 2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employer.statutoryLine,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  Text(
                    _mf.format(payslip.periodStart),
                    style: tt.bodyMedium
                        ?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // -- Employee info
            PrSectionCard(
              title: 'Employee',
              icon: Icons.person_outline,
              iconColor: PayrollTokens.navy,
              children: [
                if (employee != null) ...[
                  PrInfoRow(
                      label: 'Name',
                      value: '${employee.firstName} ${employee.lastName}'),
                  PrInfoRow(
                      label: 'ID / Passport',
                      value: employee.idOrPassportNumber),
                  PrInfoRow(
                      label: 'Occupation', value: employee.occupationTitle),
                  if (employee.bankName != null)
                    PrInfoRow(
                      label: 'Bank',
                      value:
                          '${employee.bankName} \u00b7 ****${employee.bankAccountNumber?.substring(employee.bankAccountNumber!.length - 4)}',
                    ),
                ] else
                  PrInfoRow(label: 'Employee', value: payslip.employeeId),
                const Divider(height: 16),
                PrInfoRow(
                  label: 'Period',
                  value:
                      '${_df.format(payslip.periodStart)} \u2013 ${_df.format(payslip.periodEnd)}',
                ),
                PrInfoRow(
                    label: 'Pay Date', value: _df.format(payslip.payDate)),
                PrInfoRow(
                    label: 'Payslip #',
                    value: payslip.payslipNumber ?? '\u2014'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // -- Earnings
            PrSectionCard(
              title: 'Earnings',
              icon: Icons.trending_up_outlined,
              iconColor: PayrollTokens.green,
              children: [
                PrInfoRow(label: 'Basic Wage', value: _zarInt.format(payslip.basicWage)),
                if (payslip.overtimePay > 0)
                  PrInfoRow(label: 'Overtime Pay', value: _zarInt.format(payslip.overtimePay)),
                if (payslip.holidayPay > 0)
                  PrInfoRow(label: 'Holiday Pay', value: _zarInt.format(payslip.holidayPay)),
                if (payslip.inKindHousing > 0)
                  PrInfoRow(
                    label: 'Housing (in-kind)',
                    value: _zarInt.format(payslip.inKindHousing),
                    icon: Icons.home_outlined,
                  ),
                if (payslip.inKindFood > 0)
                  PrInfoRow(
                    label: 'Food (in-kind)',
                    value: _zarInt.format(payslip.inKindFood),
                    icon: Icons.restaurant_outlined,
                  ),
                if (payslip.otherEarnings > 0)
                  PrInfoRow(
                      label: 'Other Earnings',
                      value: _zarInt.format(payslip.otherEarnings)),
                const Divider(height: 12),
                PrInfoRow(
                  label: 'Gross Pay',
                  value: _zarInt.format(payslip.grossPay),
                  valueColor: PayrollTokens.navy,
                  valueStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // -- Deductions
            PrSectionCard(
              title: 'Deductions',
              icon: Icons.remove_circle_outline,
              iconColor: PayrollTokens.rose,
              children: [
                ...payslip.deductions.map((d) => PrInfoRow(
                      label: d.description +
                          (d.isStatutory ? ' (Statutory)' : ''),
                      value: _zarInt.format(d.amount),
                      valueColor: PayrollTokens.rose,
                    )),
                const Divider(height: 12),
                PrInfoRow(
                  label: 'Total Deductions',
                  value: '- ${_zarInt.format(payslip.totalDeductions)}',
                  valueColor: PayrollTokens.rose,
                  valueStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // -- Net pay banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.md + 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [PayrollTokens.teal, PayrollTokens.navy],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('NET PAY',
                      style: tt.titleMedium?.copyWith(color: Colors.white)),
                  Text(
                    _zarInt.format(payslip.netPay),
                    style: tt.headlineSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // -- UIF employer contribution info
            PrSectionCard(
              title: 'UIF Employer Contribution',
              icon: Icons.info_outline,
              iconColor: PayrollTokens.amber,
              children: [
                Text(
                  'Employer contributes ${_zar.format(payslip.grossPay * 0.01)} (1% of gross, paid by employer \u2014 not deducted from employee).',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // -- Leave balances snapshot
            if (payslip.leaveBalanceSnapshot.isNotEmpty) ...[
              PrSectionCard(
                title: 'Leave Balance Snapshot',
                icon: Icons.beach_access_outlined,
                iconColor: PayrollTokens.teal,
                children: payslip.leaveBalanceSnapshot.entries
                    .map((e) =>
                        PrInfoRow(label: _leaveTypeLabel(e.key), value: '${e.value.toStringAsFixed(1)} days'))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // -- Statutory notice
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Text(
                'This payslip is generated in accordance with the Basic Conditions of '
                'Employment Act (BCEA) and the Unemployment Insurance Act. UIF '
                'deductions are remitted to the Department of Labour. PAYE deductions '
                'are remitted to SARS.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
