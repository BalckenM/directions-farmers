import '../../theme/payroll_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/farm_text_field.dart';
import '../../../../shared/widgets/farm_dropdown.dart';
import '../../providers/payroll_action_providers.dart';
import '../../providers/payroll_providers.dart';
import '../../widgets/payroll_widgets.dart';


final _dfLeave = DateFormat('d MMM y');

class LeaveRequestScreen extends ConsumerStatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  ConsumerState<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen> {
  String? _employeeId;
  String? _leaveTypeId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate   = DateTime.now().add(const Duration(days: 1));
  final _reasonCtrl = TextEditingController();

  int get _workingDays {
    int count = 0;
    var d = _startDate;
    while (!d.isAfter(_endDate)) {
      if (d.weekday != DateTime.saturday && d.weekday != DateTime.sunday) count++;
      d = d.add(const Duration(days: 1));
    }
    return count;
  }

  double get _daysRequested => _workingDays.toDouble();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employees  = ref.watch(activeEmployeesProvider);
    final leaveTypes = ref.watch(leaveTypesProvider);
    final balances   = _employeeId != null
        ? ref.watch(leaveBalancesProvider(_employeeId))
        : <dynamic>[];
    final isLoading = ref.watch(leaveNotifierProvider) is AsyncLoading;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final selBalance = balances.where((b) => b.leaveTypeId == _leaveTypeId).toList();

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Leave Request'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // -- Who section
          PrSectionCard(
            title: 'Who',
            icon: Icons.person_outline,
            iconColor: PayrollTokens.navy,
            children: [
              FarmDropdown<String?>(
                label: 'Employee *',
                value: _employeeId,
                prefixIcon: const Icon(Icons.badge_outlined),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Select employee')),
                  ...employees.map((e) => DropdownMenuItem(
                        value: e.id,
                        child: Text('${e.firstName} ${e.lastName}'),
                      )),
                ],
                onChanged: (v) => setState(() {
                  _employeeId  = v;
                  _leaveTypeId = null;
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              FarmDropdown<String?>(
                label: 'Leave Type *',
                value: _leaveTypeId,
                prefixIcon: const Icon(Icons.beach_access_outlined),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Select type')),
                  ...leaveTypes.map((lt) => DropdownMenuItem(
                        value: lt.id,
                        child: Text(lt.name),
                      )),
                ],
                onChanged: (v) => setState(() => _leaveTypeId = v),
              ),
              // Balance preview
              if (selBalance.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: PayrollTokens.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PayrollTokens.green.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.account_balance_wallet_outlined,
                            size: 16, color: PayrollTokens.green),
                        const SizedBox(width: 6),
                        Text('Balance available', style: tt.bodySmall),
                      ]),
                      Text(
                        '${selBalance.first.remaining.toStringAsFixed(1)} days',
                        style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold, color: PayrollTokens.green),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // -- When section
          PrSectionCard(
            title: 'When',
            icon: Icons.calendar_today_outlined,
            iconColor: PayrollTokens.teal,
            children: [
              Row(children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (d != null) {
                        setState(() {
                          _startDate = d;
                          if (_endDate.isBefore(d)) _endDate = d;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Start Date'),
                      child: Text(_dfLeave.format(_startDate)),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.arrow_forward, size: 18, color: Colors.grey),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _endDate.isBefore(_startDate)
                            ? _startDate
                            : _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime(2100),
                      );
                      if (d != null) setState(() => _endDate = d);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'End Date'),
                      child: Text(_dfLeave.format(_endDate)),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.schedule, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    '$_workingDays working day(s) requested',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ]),
              ),
              if (selBalance.isNotEmpty && _daysRequested > selBalance.first.remaining) ...[  
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 198, 40, 40).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color.fromARGB(255, 198, 40, 40).withValues(alpha: 0.35)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_outlined,
                        size: 16, color: Color.fromARGB(255, 198, 40, 40)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Insufficient balance � only ${selBalance.first.remaining.toStringAsFixed(1)} days available.',
                        style: tt.bodySmall?.copyWith(
                            color: const Color.fromARGB(255, 198, 40, 40),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ]),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // -- Reason section
          PrSectionCard(
            title: 'Reason',
            icon: Icons.notes_outlined,
            iconColor: PayrollTokens.navy,
            children: [
              FarmTextField(
                controller: _reasonCtrl,
                label: 'Reason *',
                maxLines: 3,
                hint: 'Briefly describe the reason for leave...',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: PayrollTokens.navy),
              onPressed: (_employeeId == null || _leaveTypeId == null || isLoading)
                  ? null
                  : _submit,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Submit Request'),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason.')));
      return;
    }
    final result = await ref.read(leaveNotifierProvider.notifier).submitRequest(
          employeeId:    _employeeId!,
          leaveTypeId:   _leaveTypeId!,
          startDate:     _startDate,
          endDate:       _endDate,
          daysRequested: _daysRequested,
          reason:        _reasonCtrl.text.trim(),
        );
    if (!mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave request submitted.'),
          backgroundColor: PayrollTokens.green,
        ),
      );
      if (context.canPop()) context.pop();
    }
  }
}
