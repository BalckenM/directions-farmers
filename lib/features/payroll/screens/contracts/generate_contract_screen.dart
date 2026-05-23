import '../../theme/payroll_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/employment_contract.dart';
import '../../providers/payroll_providers.dart';
import '../../providers/payroll_action_providers.dart';


final _zar = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);

class GenerateContractScreen extends ConsumerStatefulWidget {
  const GenerateContractScreen({super.key});

  @override
  ConsumerState<GenerateContractScreen> createState() => _GenerateContractScreenState();
}

class _GenerateContractScreenState extends ConsumerState<GenerateContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobDescCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();

  ContractType _type = ContractType.permanent;
  String? _selectedEmployeeId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _generated = false;
  bool _saving = false;

  @override
  void dispose() {
    _jobDescCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (result != null) {
      setState(() { if (isStart) { _startDate = result; } else { _endDate = result; } });
    }
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a start date.')));
      return;
    }
    setState(() => _saving = true);

    final contract = EmploymentContract(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: _selectedEmployeeId!,
      type: _type,
      startDate: _startDate!,
      endDate: _endDate,
      jobDescription: _jobDescCtrl.text.trim(),
      grossMonthlySalary: double.parse(_salaryCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '')),
      status: ContractStatus.draft,
      createdAt: DateTime.now(),
    );

    await ref.read(contractNotifierProvider.notifier).add(contract);

    if (!mounted) return;
    setState(() { _saving = false; _generated = true; });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contract generated as draft.'), backgroundColor: PayrollTokens.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(activeEmployeesProvider);
    final dateFmt = DateFormat('d MMM yyyy');

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 246, 249),
      appBar: AppBar(
        backgroundColor: PayrollTokens.navy, foregroundColor: Colors.white, elevation: 0,
        title: const Text('Generate Contract', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Form card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Contract Details',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PayrollTokens.navy)),
                  const SizedBox(height: 16),

                  // Employee
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Employee *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    initialValue: _selectedEmployeeId,
                    items: employees.map((e) => DropdownMenuItem(
                      value: e.id,
                      child: Text(e.fullName),
                    )).toList(),
                    validator: (v) => v == null ? 'Select an employee' : null,
                    onChanged: (v) => setState(() => _selectedEmployeeId = v),
                  ),
                  const SizedBox(height: 16),

                  // Contract type
                  DropdownButtonFormField<ContractType>(
                    decoration: const InputDecoration(
                      labelText: 'Contract Type *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    initialValue: _type,
                    items: ContractType.values.map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(_contractTypeLabel(t)),
                    )).toList(),
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                  const SizedBox(height: 16),

                  // Dates row
                  Row(children: [
                    Expanded(child: _DateField(
                      label: 'Start Date *',
                      value: _startDate == null ? null : dateFmt.format(_startDate!),
                      onTap: () => _pickDate(true),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _DateField(
                      label: 'End Date (optional)',
                      value: _endDate == null ? null : dateFmt.format(_endDate!),
                      onTap: () => _pickDate(false),
                    )),
                  ]),
                  const SizedBox(height: 16),

                  // Job description
                  TextFormField(
                    controller: _jobDescCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Job Description *',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Salary
                  TextFormField(
                    controller: _salaryCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Gross Monthly Salary *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      prefixText: 'R ',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final n = double.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), ''));
                      if (n == null || n <= 0) return 'Enter a valid amount';
                      return null;
                    },
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: _generated ? PayrollTokens.teal : PayrollTokens.navy,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(_generated ? Icons.check_circle_outline : Icons.article_outlined),
                label: Text(
                  _generated ? 'Contract Generated' : 'Generate Contract',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                onPressed: _saving || _generated ? null : _generate,
              ),
            ),

            // Preview card after generation
            if (_generated && _selectedEmployeeId != null) ...[
              const SizedBox(height: 20),
              _ContractPreviewCard(
                employee: employees.firstWhere((e) => e.id == _selectedEmployeeId),
                type: _type,
                startDate: _startDate!,
                endDate: _endDate,
                jobDescription: _jobDescCtrl.text.trim(),
                grossSalary: double.tryParse(_salaryCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0,
                dateFmt: dateFmt,
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

String _contractTypeLabel(ContractType t) => switch (t) {
  ContractType.permanent  => 'Permanent',
  ContractType.fixedTerm  => 'Fixed Term',
  ContractType.seasonal   => 'Seasonal',
  ContractType.casual     => 'Casual',
};

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value, required this.onTap});
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(
            value ?? label,
            style: TextStyle(fontSize: 13, color: value != null ? Colors.black87 : Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          )),
        ]),
      ),
    );
  }
}

class _ContractPreviewCard extends StatelessWidget {
  const _ContractPreviewCard({
    required this.employee, required this.type, required this.startDate,
    required this.endDate, required this.jobDescription, required this.grossSalary,
    required this.dateFmt,
  });
  final dynamic employee;
  final ContractType type;
  final DateTime startDate;
  final DateTime? endDate;
  final String jobDescription;
  final double grossSalary;
  final DateFormat dateFmt;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: PayrollTokens.green.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: PayrollTokens.green.withValues(alpha: 0.3))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.check_circle, color: PayrollTokens.green, size: 20),
            const SizedBox(width: 8),
            const Text('Contract Preview (Draft)', style: TextStyle(fontWeight: FontWeight.w700, color: PayrollTokens.green)),
          ]),
          const Divider(height: 20),
          _Row('Employee', employee.fullName),
          _Row('Type', _contractTypeLabel(type)),
          _Row('Start Date', dateFmt.format(startDate)),
          if (endDate != null) _Row('End Date', dateFmt.format(endDate!)),
          _Row('Job Description', jobDescription),
          _Row('Gross Monthly Salary', _zar.format(grossSalary)),
          _Row('Status', 'Draft'),
        ]),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 140, child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PayrollTokens.navy))),
    ]),
  );
}