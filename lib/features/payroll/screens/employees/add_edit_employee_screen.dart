import '../../theme/payroll_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_dropdown.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/farm_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../models/payroll_employee.dart';
import '../../providers/payroll_action_providers.dart';
import '../../providers/payroll_providers.dart';

final _dateFmt = DateFormat('d MMM y');

class AddEditEmployeeScreen extends ConsumerStatefulWidget {
  const AddEditEmployeeScreen({super.key, this.employeeId});
  final String? employeeId;

  @override
  ConsumerState<AddEditEmployeeScreen> createState() =>
      _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState
    extends ConsumerState<AddEditEmployeeScreen> {
  int _step = 0;

  final _formKey0 = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _idCtrl         = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _addressCtrl    = TextEditingController();
  final _nokNameCtrl    = TextEditingController();
  final _nokPhoneCtrl   = TextEditingController();
  final _occupationCtrl = TextEditingController();

  EngagementType _engagementType     = EngagementType.permanent;
  DisbursementMethod _disbursementMethod = DisbursementMethod.bank;
  DateTime _startDate = DateTime.now();
  bool _hasHousing = false;
  bool _hasFood    = false;

  @override
  void initState() {
    super.initState();
    if (widget.employeeId != null) {
      final emp = ref.read(employeeProvider(widget.employeeId!));
      if (emp != null) _populate(emp);
    }
  }

  void _populate(PayrollEmployee emp) {
    _firstNameCtrl.text  = emp.firstName;
    _lastNameCtrl.text   = emp.lastName;
    _idCtrl.text         = emp.idOrPassportNumber;
    _phoneCtrl.text      = emp.phone ?? '';
    _emailCtrl.text      = emp.email ?? '';
    _addressCtrl.text    = emp.address;
    _nokNameCtrl.text    = emp.nextOfKinName;
    _nokPhoneCtrl.text   = emp.nextOfKinPhone;
    _occupationCtrl.text = emp.occupationTitle;
    _engagementType      = emp.engagementType;
    _disbursementMethod  = emp.disbursementMethod;
    _startDate           = emp.startDate;
    _hasHousing          = emp.hasHousingBenefit;
    _hasFood             = emp.hasFoodBenefit;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _idCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _nokNameCtrl.dispose();
    _nokPhoneCtrl.dispose();
    _occupationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit         = widget.employeeId != null;
    final notifierState  = ref.watch(employeeNotifierProvider);
    final isSaving       = notifierState is AsyncLoading;

    return FarmScaffold(
      appBar: FarmAppBar(title: isEdit ? 'Edit Employee' : 'Add Employee'),
      body: SingleChildScrollView(
        child: Stepper(
        physics: const NeverScrollableScrollPhysics(),
        currentStep: _step,
        onStepContinue: () {
          if (_step == 0) {
            if (!(_formKey0.currentState?.validate() ?? false)) return;
            setState(() => _step++);
          } else if (_step == 1) {
            if (!(_formKey1.currentState?.validate() ?? false)) return;
            setState(() => _step++);
          } else {
            _save(context, isEdit);
          }
        },
        onStepCancel: () {
          if (_step > 0) setState(() => _step--);
        },
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: _step < 2 ? 'Next' : (isEdit ? 'Update' : 'Save'),
                  onPressed: isSaving && _step == 2
                      ? null
                      : details.onStepContinue,
                  isLoading: isSaving && _step == 2,
                ),
              ),
              if (_step > 0) ...[
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back'),
                ),
              ],
            ],
          ),
        ),
        steps: [
          // ── Step 1: Personal ───────────────────────────────────────────────
          Step(
            title: const Text('Personal'),
            isActive: _step >= 0,
            state: _step > 0 ? StepState.complete : StepState.indexed,
            content: Form(
              key: _formKey0,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _firstNameCtrl,
                    label: 'First Name',
                    hint: 'e.g. John',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _lastNameCtrl,
                    label: 'Last Name',
                    hint: 'e.g. Dlamini',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _idCtrl,
                    label: 'ID / Passport Number',
                    hint: '13-digit SA ID or passport',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _phoneCtrl,
                    label: 'Phone',
                    hint: '+27 82 000 0000',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'worker@example.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _addressCtrl,
                    label: 'Address',
                    hint: 'Street, suburb, city',
                    prefixIcon: const Icon(Icons.home_outlined),
                    maxLines: 2,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _nokNameCtrl,
                    label: 'Next of Kin Name',
                    hint: 'Full name',
                    prefixIcon: const Icon(Icons.family_restroom_rounded),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _nokPhoneCtrl,
                    label: 'Next of Kin Phone',
                    hint: '+27 83 000 0000',
                    prefixIcon: const Icon(Icons.contact_phone_outlined),
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),

          // ── Step 2: Employment ─────────────────────────────────────────────
          Step(
            title: const Text('Employment'),
            isActive: _step >= 1,
            state: _step > 1 ? StepState.complete : StepState.indexed,
            content: Form(
              key: _formKey1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FarmTextField(
                    controller: _occupationCtrl,
                    label: 'Occupation Title',
                    hint: 'e.g. Farm Worker',
                    prefixIcon: const Icon(Icons.work_outline_rounded),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmDropdown<EngagementType>(
                    label: 'Engagement Type',
                    value: _engagementType,
                    prefixIcon: const Icon(Icons.assignment_ind_outlined),
                    items: EngagementType.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                t.name[0].toUpperCase() + t.name.substring(1),
                              ),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _engagementType = v!),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Date picker
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        suffixIcon: Icon(Icons.edit_calendar_outlined, size: 18),
                      ),
                      child: Text(_dateFmt.format(_startDate)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Step 3: Pay & Benefits ─────────────────────────────────────────
          Step(
            title: const Text('Pay & Benefits'),
            isActive: _step >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FarmDropdown<DisbursementMethod>(
                  label: 'Payment Method',
                  value: _disbursementMethod,
                  prefixIcon: const Icon(Icons.payments_outlined),
                  items: DisbursementMethod.values
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              m.name[0].toUpperCase() + m.name.substring(1),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _disbursementMethod = v!),
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  value: _hasHousing,
                  onChanged: (v) => setState(() => _hasHousing = v),
                  title: const Text('Housing Benefit'),
                  secondary: const Icon(Icons.home_work_outlined),
                  activeThumbColor: PayrollTokens.navy,
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  value: _hasFood,
                  onChanged: (v) => setState(() => _hasFood = v),
                  title: const Text('Food / Meal Benefit'),
                  secondary: const Icon(Icons.restaurant_outlined),
                  activeThumbColor: PayrollTokens.navy,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, bool isEdit) async {
    final now      = DateTime.now();
    final existing = isEdit
        ? ref.read(employeeProvider(widget.employeeId!))
        : null;

    final employee = PayrollEmployee(
      id: existing?.id ?? 'emp_${now.millisecondsSinceEpoch}',
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      idOrPassportNumber: _idCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isNotEmpty
          ? _phoneCtrl.text.trim()
          : null,
      email: _emailCtrl.text.trim().isNotEmpty
          ? _emailCtrl.text.trim()
          : null,
      address: _addressCtrl.text.trim(),
      nextOfKinName: _nokNameCtrl.text.trim(),
      nextOfKinPhone: _nokPhoneCtrl.text.trim(),
      status: existing?.status ?? EmploymentStatus.active,
      engagementType: _engagementType,
      occupationTitle: _occupationCtrl.text.trim(),
      payGroupId: existing?.payGroupId,
      payStructureId: existing?.payStructureId,
      startDate: _startDate,
      disbursementMethod: _disbursementMethod,
      preferredLanguage: existing?.preferredLanguage ?? 'en',
      hasHousingBenefit: _hasHousing,
      hasFoodBenefit: _hasFood,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    final notifier = ref.read(employeeNotifierProvider.notifier);
    final result = isEdit
        ? await notifier.update(employee)
        : await notifier.add(employee);

    if (!context.mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit
              ? 'Employee updated successfully.'
              : 'Employee added successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } else {
      final err = ref.read(employeeNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${err ?? 'Unknown error'}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
