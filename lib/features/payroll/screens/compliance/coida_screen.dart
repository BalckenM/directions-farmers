import '../../theme/payroll_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/compliance_alert.dart';
import '../../providers/payroll_providers.dart';
import '../../services/payroll_engine.dart';


final _zar = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 2);

// COIDA rate and ceiling sourced from payroll engine to ensure consistency.
final double _coidaRate = SaStatutory.coidaDefaultRate;
final double _annualCeiling = SaStatutory.coidaAnnualCeiling;

class CoidaScreen extends ConsumerWidget {
  const CoidaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employees = ref.watch(activeEmployeesProvider);
    final payStructures = ref.watch(payStructuresProvider);
    final allAlerts = ref.watch(complianceAlertsProvider);
    final coidaAlerts = allAlerts
        .where((a) => a.code.toUpperCase().contains('COIDA'))
        .toList();

    final rows = employees.map((emp) {
      final struct = payStructures.where((s) => s.id == emp.payStructureId).firstOrNull;
      final monthly = struct?.baseRate ?? 0.0;
      final annual = (monthly * 12).clamp(0, _annualCeiling);
      final assessment = annual * _coidaRate;
      return (emp.fullName, monthly, annual, assessment);
    }).toList();

    final totalAnnual = rows.fold(0.0, (s, r) => s + r.$3);
    final totalAssessment = rows.fold(0.0, (s, r) => s + r.$4);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 246, 249),
      appBar: AppBar(
        backgroundColor: PayrollTokens.navy, foregroundColor: Colors.white,
        title: const Text('COIDA Returns', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_outlined),
            tooltip: 'Submit Annual Return',
            onPressed: () => _submit(context),
          ),
        ],
      ),
      body: Column(children: [
        // Info banner
        Container(
          color: PayrollTokens.indigo.withValues(alpha: 0.08),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            const Icon(Icons.info_outline, color: PayrollTokens.indigo, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('COIDA Assessment Rate: 0.53% of payroll',
                  style: TextStyle(color: PayrollTokens.indigo, fontWeight: FontWeight.w700, fontSize: 13)),
              Text('Annual earnings ceiling: ${_zar.format(_annualCeiling)}',
                  style: TextStyle(color: PayrollTokens.indigo.withValues(alpha: 0.7), fontSize: 12)),
            ])),
          ]),
        ),
        if (coidaAlerts.isNotEmpty)
          _AlertsBanner(alerts: coidaAlerts),
        // Summary
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: _StatCard('Employees', '${rows.length}', PayrollTokens.navy)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard('Total Earnings', _zar.format(totalAnnual), PayrollTokens.teal)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard('Assessment', _zar.format(totalAssessment), PayrollTokens.rose, large: true)),
          ]),
        ),
        // Table header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: const [
            Expanded(flex: 3, child: Text('Employee', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey))),
            Expanded(flex: 2, child: Text('Monthly', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey), textAlign: TextAlign.right)),
            Expanded(flex: 2, child: Text('Capped Annual', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey), textAlign: TextAlign.right)),
            Expanded(flex: 2, child: Text('Assessment', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey), textAlign: TextAlign.right)),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: rows.isEmpty
              ? const Center(child: Text('No active employees', style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, indent: 16),
                  itemBuilder: (ctx, i) {
                    final (name, monthly, annual, assessment) = rows[i];
                    final capped = monthly * 12 > _annualCeiling;
                    return Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(children: [
                        Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PayrollTokens.navy)),
                          if (capped)
                            const Text('Earnings capped', style: TextStyle(fontSize: 10, color: PayrollTokens.amber)),
                        ])),
                        Expanded(flex: 2, child: Text(_zar.format(monthly),
                            style: const TextStyle(fontSize: 12), textAlign: TextAlign.right)),
                        Expanded(flex: 2, child: Text(_zar.format(annual),
                            style: TextStyle(fontSize: 12, color: capped ? PayrollTokens.amber : Colors.black87),
                            textAlign: TextAlign.right)),
                        Expanded(flex: 2, child: Text(_zar.format(assessment),
                            style: const TextStyle(fontSize: 12, color: PayrollTokens.rose, fontWeight: FontWeight.w700),
                            textAlign: TextAlign.right)),
                      ]),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: PayrollTokens.teal),
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Submit Annual COIDA Return', style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: () => _submit(context),
            ),
          ),
        ),
      ]),
    );
  }

  void _submit(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Annual COIDA return submitted successfully'),
      backgroundColor: PayrollTokens.green,
    ));
  }
}

class _AlertsBanner extends StatelessWidget {
  const _AlertsBanner({required this.alerts});
  final List<ComplianceAlert> alerts;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PayrollTokens.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PayrollTokens.amber.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.warning_amber_outlined, color: PayrollTokens.amber),
        const SizedBox(width: 8),
        Expanded(child: Text('${alerts.length} COIDA alert(s) require attention',
            style: const TextStyle(color: PayrollTokens.amber, fontWeight: FontWeight.w600, fontSize: 13))),
      ]),
    );
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: large ? 14 : 13, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }
}