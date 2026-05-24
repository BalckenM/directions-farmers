import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/communication_log.dart';
import '../../models/pay_group.dart';
import '../../models/payroll_employee.dart';
import '../../providers/payroll_action_providers.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

enum _RecipientScope { allEmployees, payGroup, selectedEmployees }

class _MessageTemplate {
  const _MessageTemplate({
    required this.code,
    required this.label,
    required this.subject,
    required this.body,
  });

  final String code;
  final String label;
  final String subject;
  final String body;
}

const List<_MessageTemplate> _messageTemplates = [
  _MessageTemplate(
    code: 'CUSTOM',
    label: 'Custom Message',
    subject: '',
    body: '',
  ),
  _MessageTemplate(
    code: 'PAY_RUN_READY',
    label: 'Payslip Ready',
    subject: 'Your payslip is ready',
    body:
        'Your latest payslip is ready for review. Please check the payroll module today.',
  ),
  _MessageTemplate(
    code: 'SHIFT_REMINDER',
    label: 'Shift Reminder',
    subject: 'Upcoming shift reminder',
    body:
        'This is a reminder to report for your assigned shift on time and confirm attendance on arrival.',
  ),
  _MessageTemplate(
    code: 'DOCUMENT_REQUEST',
    label: 'Document Request',
    subject: 'Payroll documents required',
    body:
        'Please submit the requested payroll documents to HR before close of business.',
  ),
];

class ComposeMessageScreen extends ConsumerStatefulWidget {
  const ComposeMessageScreen({super.key});

  @override
  ConsumerState<ComposeMessageScreen> createState() =>
      _ComposeMessageScreenState();
}

class _ComposeMessageScreenState extends ConsumerState<ComposeMessageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  CommunicationChannel _channel = CommunicationChannel.sms;
  _RecipientScope _recipientScope = _RecipientScope.allEmployees;
  String _templateCode = 'CUSTOM';
  String? _selectedPayGroupId;
  final Set<String> _selectedIds = {};
  bool _sending = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  bool get _showSubject =>
      _channel == CommunicationChannel.email ||
      _channel == CommunicationChannel.inApp;

  List<PayrollEmployee> _payGroupRecipients(List<PayrollEmployee> employees) {
    if (_selectedPayGroupId == null) {
      return const [];
    }
    return employees
        .where((employee) => employee.payGroupId == _selectedPayGroupId)
        .toList();
  }

  List<String> _resolveRecipientIds(List<PayrollEmployee> employees) {
    switch (_recipientScope) {
      case _RecipientScope.allEmployees:
        return employees.map((employee) => employee.id).toList();
      case _RecipientScope.payGroup:
        return _payGroupRecipients(
          employees,
        ).map((employee) => employee.id).toList();
      case _RecipientScope.selectedEmployees:
        return _selectedIds.toList();
    }
  }

  void _applyTemplate(String? code) {
    if (code == null) {
      return;
    }
    final template = _messageTemplates.firstWhere(
      (candidate) => candidate.code == code,
      orElse: () => _messageTemplates.first,
    );
    setState(() {
      _templateCode = template.code;
      if (template.code == 'CUSTOM') {
        return;
      }
      _subjectCtrl.text = template.subject;
      _bodyCtrl.text = template.body;
    });
  }

  Future<void> _send(List<PayrollEmployee> employees) async {
    if (!_formKey.currentState!.validate()) return;
    if (_recipientScope == _RecipientScope.payGroup &&
        _selectedPayGroupId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a pay group.')));
      return;
    }

    final recipientIds = _resolveRecipientIds(employees);
    if (recipientIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one recipient.')),
      );
      return;
    }
    setState(() => _sending = true);

    final log = await ref
        .read(communicationNotifierProvider.notifier)
        .send(
          channel: _channel,
          templateCode: _templateCode,
          subject: _showSubject ? _subjectCtrl.text.trim() : '',
          body: _bodyCtrl.text.trim(),
          recipientEmployeeIds: recipientIds,
          sentByUserId: 'current_user',
        );

    ref.invalidate(allAuditLogProvider);

    setState(() => _sending = false);

    if (log == null) return;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message sent to ${log.deliveredCount} recipients.'),
          backgroundColor: PayrollTokens.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(activeEmployeesProvider);
    final payGroups = ref.watch(activePayGroupsProvider);
    final payGroupRecipients = _payGroupRecipients(employees);
    final recipientCount = _resolveRecipientIds(employees).length;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 246, 249),
      appBar: AppBar(
        backgroundColor: PayrollTokens.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Compose Message',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _LabeledDropdown<String>(
                    label: 'Template',
                    value: _templateCode,
                    items: _messageTemplates
                        .map(
                          (template) => DropdownMenuItem<String>(
                            value: template.code,
                            child: Text(template.label),
                          ),
                        )
                        .toList(),
                    onChanged: _sending ? null : _applyTemplate,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Channel picker
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Channel',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: PayrollTokens.navy,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: CommunicationChannel.values.map((ch) {
                          final selected = _channel == ch;
                          final (label, icon) = _channelMeta(ch);
                          return ChoiceChip(
                            avatar: Icon(
                              icon,
                              size: 16,
                              color: selected
                                  ? Colors.white
                                  : PayrollTokens.navy,
                            ),
                            label: Text(label),
                            selected: selected,
                            selectedColor: PayrollTokens.navy,
                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : PayrollTokens.navy,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) => setState(() => _channel = ch),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Message card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (_showSubject) ...[
                        TextFormField(
                          controller: _subjectCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Subject *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.subject_outlined),
                          ),
                          validator: (v) =>
                              (_showSubject && (v == null || v.trim().isEmpty))
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _bodyCtrl,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Message Body *',
                          hintText: _channel == CommunicationChannel.sms
                              ? 'Max 160 characters for SMS'
                              : 'Enter your message',
                          border: const OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLength: _channel == CommunicationChannel.sms
                            ? 160
                            : null,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Recipients
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recipients',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: PayrollTokens.navy,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            [
                              _RecipientScope.allEmployees,
                              _RecipientScope.payGroup,
                              _RecipientScope.selectedEmployees,
                            ].map((scope) {
                              final label = switch (scope) {
                                _RecipientScope.allEmployees => 'All Employees',
                                _RecipientScope.payGroup => 'Pay Group',
                                _RecipientScope.selectedEmployees =>
                                  'Selected Employees',
                              };
                              return ChoiceChip(
                                label: Text(label),
                                selected: _recipientScope == scope,
                                selectedColor: PayrollTokens.teal,
                                labelStyle: TextStyle(
                                  color: _recipientScope == scope
                                      ? Colors.white
                                      : PayrollTokens.navy,
                                  fontWeight: FontWeight.w600,
                                ),
                                onSelected: (_) =>
                                    setState(() => _recipientScope = scope),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 12),
                      if (_recipientScope == _RecipientScope.allEmployees)
                        Text(
                          '${employees.length} active employees will receive this message.',
                          style: const TextStyle(color: PayrollTokens.navy),
                        ),
                      if (_recipientScope == _RecipientScope.payGroup) ...[
                        _LabeledDropdown<String>(
                          label: 'Pay Group',
                          value: _selectedPayGroupId,
                          placeholder: 'Select pay group',
                          items: payGroups
                              .map(
                                (group) => DropdownMenuItem<String>(
                                  value: group.id,
                                  child: Text(
                                    '${group.name} (${group.frequencyLabel})',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _sending
                              ? null
                              : (value) =>
                                    setState(() => _selectedPayGroupId = value),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${payGroupRecipients.length} employee${payGroupRecipients.length == 1 ? '' : 's'} in the selected pay group.',
                          style: const TextStyle(color: PayrollTokens.navy),
                        ),
                      ],
                      if (_recipientScope ==
                          _RecipientScope.selectedEmployees) ...[
                        const Divider(height: 24),
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: employees.length,
                            itemBuilder: (ctx, i) {
                              final employee = employees[i];
                              final payGroup = payGroups
                                  .where(
                                    (group) => group.id == employee.payGroupId,
                                  )
                                  .cast<PayGroup?>()
                                  .firstOrNull;
                              return CheckboxListTile(
                                dense: true,
                                activeColor: PayrollTokens.teal,
                                title: Text(
                                  employee.fullName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: PayrollTokens.navy,
                                  ),
                                ),
                                subtitle: Text(
                                  payGroup?.name ??
                                      employee.phone ??
                                      'No pay group assigned',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                value: _selectedIds.contains(employee.id),
                                onChanged: (value) => setState(() {
                                  if (value == true) {
                                    _selectedIds.add(employee.id);
                                  } else {
                                    _selectedIds.remove(employee.id);
                                  }
                                }),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: PayrollTokens.navy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    'Send Message ($recipientCount)',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: _sending ? null : () => _send(employees),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

(String, IconData) _channelMeta(CommunicationChannel ch) => switch (ch) {
  CommunicationChannel.sms => ('SMS', Icons.sms_outlined),
  CommunicationChannel.whatsapp => ('WhatsApp', Icons.chat_outlined),
  CommunicationChannel.email => ('Email', Icons.email_outlined),
  CommunicationChannel.inApp => ('In-App', Icons.notifications_outlined),
  CommunicationChannel.push => ('Push', Icons.campaign_outlined),
};

class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.placeholder,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: placeholder != null ? Text(placeholder!) : null,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
