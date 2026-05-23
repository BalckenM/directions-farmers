import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/employment_contract.dart';
import '../../models/payroll_employee.dart';
import '../../providers/payroll_providers.dart';
import '../../services/contract_pdf_service.dart';
import '../../theme/payroll_tokens.dart';

const _red = Color.fromARGB(255, 198, 40, 40);

final _zar = NumberFormat.currency(
  locale: 'en_ZA',
  symbol: 'R ',
  decimalDigits: 2,
);
final _dateFmt = DateFormat('d MMM yyyy');

class ContractDetailScreen extends ConsumerWidget {
  const ContractDetailScreen({super.key, required this.contractId});
  final String contractId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contracts = ref.watch(contractsProvider(null));
    final contract = contracts.where((c) => c.id == contractId).firstOrNull;
    if (contract == null) {
      return const FarmScaffold(
        appBar: FarmAppBar(title: 'Contract'),
        body: Center(child: Text('Contract not found.')),
      );
    }
    final employees = ref.watch(employeesProvider);
    final employee = employees
        .where((e) => e.id == contract.employeeId)
        .firstOrNull;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Employment Contract',
        actions: [
          if (contract.status == ContractStatus.draft)
            TextButton.icon(
              onPressed: () =>
                  context.push(AppRoutes.payrollSignContract(contractId)),
              icon: const Icon(
                Icons.draw_outlined,
                color: Colors.white,
                size: 18,
              ),
              label: const Text('Sign', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _EmployeeHeader(contract: contract, employee: employee),
          const SizedBox(height: 16),
          _StatusBanner(contract: contract),
          const SizedBox(height: 16),
          _ContractTermsCard(contract: contract),
          const SizedBox(height: 16),
          _SigningHistoryCard(contract: contract),
          const SizedBox(height: 16),
          _ComplianceCard(contract: contract),
          const SizedBox(height: 24),
          _ActionButtons(
            contract: contract,
            contractId: contractId,
            employee: employee,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Employee header ──────────────────────────────────────────────────────────
class _EmployeeHeader extends StatelessWidget {
  const _EmployeeHeader({required this.contract, required this.employee});
  final EmploymentContract contract;
  final PayrollEmployee? employee;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final name = employee?.fullName ?? contract.employeeId;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PayrollTokens.navy, Color(0xFF2B4F8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: tt.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contract.jobDescription,
                  style: tt.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _TypeBadge(contract.type),
                    const SizedBox(width: 8),
                    _VersionBadge(contract.version),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status banner ─────────────────────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.contract});
  final EmploymentContract contract;

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (contract.status) {
      ContractStatus.signed => (
        PayrollTokens.green,
        Icons.verified_outlined,
        'Active & Signed',
      ),
      ContractStatus.draft => (
        PayrollTokens.amber,
        Icons.edit_note_outlined,
        'Draft — Awaiting Signature',
      ),
      ContractStatus.expired => (_red, Icons.warning_amber_outlined, 'Expired'),
      ContractStatus.terminated => (_red, Icons.cancel_outlined, 'Terminated'),
    };
    final daysLeft = contract.endDate?.difference(DateTime.now()).inDays;
    final expiryNote = daysLeft != null && daysLeft >= 0 && daysLeft <= 30
        ? '  ·  Expires in $daysLeft day${daysLeft == 1 ? '' : 's'}'
        : '';

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label$expiryNote',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contract terms ────────────────────────────────────────────────────────────
class _ContractTermsCard extends StatelessWidget {
  const _ContractTermsCard({required this.contract});
  final EmploymentContract contract;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Contract Terms',
      icon: Icons.description_outlined,
      children: [
        _TermRow('Type', _contractTypeLabel(contract.type)),
        _TermRow('Job Description', contract.jobDescription),
        _TermRow(
          'Gross Monthly Salary',
          '${_zar.format(contract.grossMonthlySalary)} ${contract.currency}',
        ),
        _TermRow('Start Date', _dateFmt.format(contract.startDate)),
        if (contract.endDate != null)
          _TermRow('End Date', _dateFmt.format(contract.endDate!)),
        if (contract.endDate == null && contract.type == ContractType.permanent)
          _TermRow('Duration', 'Permanent (no fixed end date)'),
        _TermRow('Annual Cost', _zar.format(contract.grossMonthlySalary * 12)),
      ],
    );
  }
}

// ─── Signing history ───────────────────────────────────────────────────────────
class _SigningHistoryCard extends StatelessWidget {
  const _SigningHistoryCard({required this.contract});
  final EmploymentContract contract;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Signing History',
      icon: Icons.history_edu_outlined,
      children: [
        _TimelineEvent(
          date: contract.createdAt,
          label: 'Contract Created',
          icon: Icons.create_outlined,
          color: PayrollTokens.navy,
        ),
        if (contract.signedAt != null) ...[
          const _TimelineDivider(),
          _TimelineEvent(
            date: contract.signedAt!,
            label: 'Signed by ${contract.signedByName ?? 'Unknown'}',
            icon: Icons.draw_outlined,
            color: PayrollTokens.green,
          ),
        ],
        if (contract.status == ContractStatus.expired) ...[
          const _TimelineDivider(),
          _TimelineEvent(
            date: contract.endDate ?? contract.createdAt,
            label: 'Contract Expired',
            icon: Icons.event_busy_outlined,
            color: _red,
          ),
        ],
      ],
    );
  }
}

// ─── Compliance card ────────────────────────────────────────────────────────────
class _ComplianceCard extends StatelessWidget {
  const _ComplianceCard({required this.contract});
  final EmploymentContract contract;

  @override
  Widget build(BuildContext context) {
    final issues = <_ComplianceIssue>[];

    if (contract.status == ContractStatus.draft) {
      issues.add(
        _ComplianceIssue(
          severity: 'warning',
          message:
              'Contract has not been signed. BCEA requires a written contract '
              'before the employee begins work.',
        ),
      );
    }

    if (contract.isExpired) {
      issues.add(
        _ComplianceIssue(
          severity: 'critical',
          message:
              'Contract is expired. Continued employment without a valid '
              'contract may constitute an implied indefinite contract under BCEA §213.',
        ),
      );
    }

    final daysLeft = contract.endDate?.difference(DateTime.now()).inDays;
    if (daysLeft != null && daysLeft >= 0 && daysLeft <= 30) {
      issues.add(
        _ComplianceIssue(
          severity: 'warning',
          message:
              'Contract expires in $daysLeft day${daysLeft == 1 ? '' : 's'}. '
              'Initiate renewal or confirm employment continuation.',
        ),
      );
    }

    if (issues.isEmpty) {
      return _Section(
        title: 'BCEA Compliance',
        icon: Icons.shield_outlined,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: PayrollTokens.green,
              ),
              const SizedBox(width: 8),
              Text(
                'No compliance issues detected.',
                style: TextStyle(
                  color: PayrollTokens.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return _Section(
      title: 'BCEA Compliance',
      icon: Icons.shield_outlined,
      children: issues.map((i) => _ComplianceRow(issue: i)).toList(),
    );
  }
}

// ─── Action buttons ─────────────────────────────────────────────────────────────
class _ActionButtons extends StatefulWidget {
  const _ActionButtons({
    required this.contract,
    required this.contractId,
    required this.employee,
  });
  final EmploymentContract contract;
  final String contractId;
  final PayrollEmployee? employee;

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<_ActionButtons> {
  bool _exporting = false;

  Future<void> _exportPdf() async {
    final employee = widget.employee;
    if (employee == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Employee data not found.')));
      return;
    }
    setState(() => _exporting = true);
    try {
      final bytes = await const ContractPdfService().generate(
        contract: widget.contract,
        employee: employee,
      );
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/contract_${widget.contractId}.pdf';
      await File(path).writeAsBytes(bytes, flush: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to $path'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contract = widget.contract;
    final contractId = widget.contractId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (contract.status == ContractStatus.draft)
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: PayrollTokens.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () =>
                context.push(AppRoutes.payrollSignContract(contractId)),
            icon: const Icon(Icons.draw_outlined),
            label: const Text('Sign Contract', style: TextStyle(fontSize: 16)),
          ),
        if (contract.status == ContractStatus.draft) const SizedBox(height: 10),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: PayrollTokens.navy,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: _exporting ? null : _exportPdf,
          icon: _exporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.picture_as_pdf_outlined),
          label: Text(
            contract.status == ContractStatus.signed
                ? 'Export Signed PDF'
                : 'Export Draft PDF',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: PayrollTokens.navy,
            side: const BorderSide(color: PayrollTokens.navy),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () => context.push(AppRoutes.payrollGenerateContract),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Generate New Contract Version'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: PayrollTokens.teal,
            side: const BorderSide(color: PayrollTokens.teal),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () =>
              context.push(AppRoutes.payrollContractDetail(contractId)),
          icon: const Icon(Icons.folder_open_outlined),
          label: const Text('All Contracts for This Employee'),
        ),
      ],
    );
  }
}

// ─── Reusable helpers ──────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: PayrollTokens.navy, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: tt.titleSmall?.copyWith(
                    color: PayrollTokens.navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _TermRow extends StatelessWidget {
  const _TermRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: tt.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({
    required this.date,
    required this.label,
    required this.icon,
    required this.color,
  });
  final DateTime date;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                _dateFmt.format(date),
                style: tt.bodySmall?.copyWith(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineDivider extends StatelessWidget {
  const _TimelineDivider();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 15, top: 4, bottom: 4),
    child: Container(width: 2, height: 20, color: Colors.grey.shade200),
  );
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge(this.type);
  final ContractType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _contractTypeLabel(type),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _VersionBadge extends StatelessWidget {
  const _VersionBadge(this.version);
  final int version;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'v$version',
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
    );
  }
}

class _ComplianceIssue {
  const _ComplianceIssue({required this.severity, required this.message});
  final String severity; // 'warning' | 'critical'
  final String message;
}

class _ComplianceRow extends StatelessWidget {
  const _ComplianceRow({required this.issue});
  final _ComplianceIssue issue;

  @override
  Widget build(BuildContext context) {
    final isCritical = issue.severity == 'critical';
    final color = isCritical ? _red : PayrollTokens.amber;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCritical ? Icons.error_outline : Icons.warning_amber_outlined,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              issue.message,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

String _contractTypeLabel(ContractType type) => switch (type) {
  ContractType.permanent => 'Permanent',
  ContractType.fixedTerm => 'Fixed-Term',
  ContractType.seasonal => 'Seasonal',
  ContractType.casual => 'Casual',
};
