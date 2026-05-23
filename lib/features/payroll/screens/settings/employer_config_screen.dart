import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/employer_config.dart';
import '../../providers/payroll_action_providers.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

class EmployerConfigScreen extends ConsumerStatefulWidget {
  const EmployerConfigScreen({super.key});

  @override
  ConsumerState<EmployerConfigScreen> createState() =>
      _EmployerConfigScreenState();
}

class _EmployerConfigScreenState extends ConsumerState<EmployerConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _regCtrl;
  late TextEditingController _uifCtrl;
  late TextEditingController _payeCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final config = ref.read(employerConfigProvider);
    _nameCtrl = TextEditingController(text: config.name);
    _regCtrl = TextEditingController(text: config.registrationNumber);
    _uifCtrl = TextEditingController(text: config.uifReferenceNumber);
    _payeCtrl = TextEditingController(text: config.payeNumber);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _regCtrl.dispose();
    _uifCtrl.dispose();
    _payeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final config = EmployerConfig(
      name: _nameCtrl.text.trim(),
      registrationNumber: _regCtrl.text.trim(),
      uifReferenceNumber: _uifCtrl.text.trim(),
      payeNumber: _payeCtrl.text.trim(),
    );
    await ref
        .read(employerConfigNotifierProvider.notifier)
        .updateConfig(config);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employer configuration saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 246, 249),
      appBar: AppBar(
        backgroundColor: PayrollTokens.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Employer Configuration',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader('Company Details'),
              _FieldCard(children: [
                _FormField(
                  ctrl: _nameCtrl,
                  label: 'Company / Trading Name',
                  hint: 'e.g. 4 Directions Farm (Pty) Ltd',
                  required: true,
                ),
                _FormField(
                  ctrl: _regCtrl,
                  label: 'Registration Number',
                  hint: 'e.g. 2020/123456/07',
                  required: true,
                ),
              ]),
              const SizedBox(height: 16),
              _SectionHeader('Tax & UIF References'),
              _FieldCard(children: [
                _FormField(
                  ctrl: _uifCtrl,
                  label: 'UIF Reference Number',
                  hint: 'e.g. UIF-1234567',
                  required: true,
                ),
                _FormField(
                  ctrl: _payeCtrl,
                  label: 'PAYE Number',
                  hint: 'e.g. 7123456789',
                  required: true,
                ),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: PayrollTokens.navy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _saving ? 'Saving...' : 'Save Configuration',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  onPressed: _saving ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: PayrollTokens.navy,
          ),
        ),
      );
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: children
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: c,
                    ))
                .toList(),
          ),
        ),
      );
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.required = false,
  });
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final bool required;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
      );
}
