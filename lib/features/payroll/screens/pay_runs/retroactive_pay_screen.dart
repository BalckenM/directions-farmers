import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/features/payroll/providers/payroll_providers.dart';
import 'package:mobile_app/features/payroll/services/payroll_engine.dart';

import 'package:mobile_app/features/payroll/widgets/payroll_widgets.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/shared/widgets/farm_dropdown.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';
import 'package:mobile_app/shared/widgets/farm_text_field.dart';

final _zar = NumberFormat.currency(
  locale: 'en_ZA',
  symbol: 'R ',
  decimalDigits: 2,
);

// ─── Wage-change type ────────────────────────────────────────────────────────
enum _BackpayType { monthly, daily, hourly }

class RetroactivePayScreen extends ConsumerStatefulWidget {
  const RetroactivePayScreen({super.key});

  @override
  ConsumerState<RetroactivePayScreen> createState() =>
      _RetroactivePayScreenState();
}

class _RetroactivePayScreenState extends ConsumerState<RetroactivePayScreen> {
  String? _employeeId;
  _BackpayType _type = _BackpayType.monthly;
  bool _saving = false;

  final _oldRateCtrl = TextEditingController();
  final _newRateCtrl = TextEditingController();
  final _periodsCtrl = TextEditingController(text: '1');
  final _unitsCtrl = TextEditingController(text: '21.67');

  // Computed results
  double? _grossBackpay;
  double? _backpayPaye;

  @override
  void dispose() {
    _oldRateCtrl.dispose();
    _newRateCtrl.dispose();
    _periodsCtrl.dispose();
    _unitsCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveBackPay() async {
    if (_grossBackpay == null || _employeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Select an employee before saving the back-pay record.',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(payrollRepositoryProvider);
      await repo.createTransaction({
        'employeeId': _employeeId,
        'type': 'retroactive',
        'description': 'Retroactive back-pay (${_typeLabel(_type)})',
        'amount': _grossBackpay,
        'currency': 'ZAR',
        'method': 'bank',
        'status': 'initiated',
        'transactionDate': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Back-pay record saved to transactions.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _typeLabel(_BackpayType t) => switch (t) {
    _BackpayType.monthly => 'Monthly salary',
    _BackpayType.daily => 'Daily rate',
    _BackpayType.hourly => 'Hourly rate',
  };

  String _unitsLabel(_BackpayType t) => switch (t) {
    _BackpayType.monthly => 'Months affected',
    _BackpayType.daily => 'Days per period',
    _BackpayType.hourly => 'Hours per period',
  };

  String _unitsHint(_BackpayType t) => switch (t) {
    _BackpayType.monthly => '3',
    _BackpayType.daily => '21.67',
    _BackpayType.hourly => '173.33',
  };

  void _compute() {
    final oldRate = double.tryParse(_oldRateCtrl.text);
    final newRate = double.tryParse(_newRateCtrl.text);
    final periods = int.tryParse(_periodsCtrl.text);
    final units = double.tryParse(_unitsCtrl.text);

    if (oldRate == null || newRate == null || periods == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    if (newRate <= oldRate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New rate must be greater than the old rate.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    double gross;
    if (_type == _BackpayType.monthly) {
      gross = BackpayCalculator.computeRetroactiveMonthlySalary(
        oldMonthly: oldRate,
        newMonthly: newRate,
        monthsAffected: periods,
      );
    } else {
      gross = BackpayCalculator.computeRetroactivePay(
        oldRate: oldRate,
        newRate: newRate,
        periodsAffected: periods,
        unitsPerPeriod:
            units ?? (_type == _BackpayType.hourly ? 173.33 : 21.67),
      );
    }

    // Monthly gross estimate for PAYE calculation
    final currentMonthlyGross = _type == _BackpayType.monthly
        ? newRate
        : newRate * (units ?? 173.33);
    final paye = BackpayCalculator.computeBackpayPaye(
      currentMonthlyGross: currentMonthlyGross,
      totalBackpay: gross,
      monthsAffected: periods,
    );

    setState(() {
      _grossBackpay = gross;
      _backpayPaye = paye;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final employees = ref.watch(activeEmployeesProvider);

    final netBackpay = (_grossBackpay ?? 0) - (_backpayPaye ?? 0);

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Retroactive Back-Pay'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ── Info banner ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Calculate back-pay when a wage increase is applied '
                    'retroactively. PAYE on the lump sum is estimated using '
                    'the spread-over-period method (SARS Interpretation Note 17).',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Employee (optional) ────────────────────────────────────────
          PrSectionCard(
            title: 'Employee',
            icon: Icons.person_outline_rounded,
            iconColor: AppColors.primary,
            children: [
              FarmDropdown<String?>(
                label: 'Employee (optional)',
                value: _employeeId,
                hint: 'Select employee',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('— None selected —'),
                  ),
                  ...employees.map(
                    (e) => DropdownMenuItem<String?>(
                      value: e.id,
                      child: Text('${e.firstName} ${e.lastName}'),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _employeeId = v),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Wage change type ───────────────────────────────────────────
          PrSectionCard(
            title: 'Wage-Change Type',
            icon: Icons.compare_arrows_rounded,
            iconColor: AppColors.primary,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: _BackpayType.values.map((t) {
                  final sel = _type == t;
                  return ChoiceChip(
                    label: Text(_typeLabel(t)),
                    selected: sel,
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    side: BorderSide(
                      color: sel ? AppColors.primary : cs.outlineVariant,
                    ),
                    labelStyle: TextStyle(
                      color: sel ? AppColors.primary : cs.onSurfaceVariant,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _type = t;
                        _grossBackpay = null;
                        _backpayPaye = null;
                        // Reset sensible defaults
                        if (t == _BackpayType.monthly) {
                          _periodsCtrl.text = '3';
                          _unitsCtrl.text = '';
                        } else if (t == _BackpayType.daily) {
                          _periodsCtrl.text = '3';
                          _unitsCtrl.text = '21.67';
                        } else {
                          _periodsCtrl.text = '3';
                          _unitsCtrl.text = '173.33';
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Rate inputs ────────────────────────────────────────────────
          PrSectionCard(
            title: 'Rate Details',
            icon: Icons.payments_outlined,
            iconColor: AppColors.success,
            children: [
              Row(
                children: [
                  Expanded(
                    child: FarmTextField(
                      controller: _oldRateCtrl,
                      label: 'Old Rate (R)',
                      hint: '5 000.00',
                      prefixIcon: const Icon(Icons.arrow_downward_rounded),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FarmTextField(
                      controller: _newRateCtrl,
                      label: 'New Rate (R)',
                      hint: '5 500.00',
                      prefixIcon: const Icon(Icons.arrow_upward_rounded),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: FarmTextField(
                      controller: _periodsCtrl,
                      label: 'Periods Affected',
                      hint: '3',
                      prefixIcon: const Icon(Icons.calendar_month_outlined),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  if (_type != _BackpayType.monthly) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FarmTextField(
                        controller: _unitsCtrl,
                        label: _unitsLabel(_type),
                        hint: _unitsHint(_type),
                        prefixIcon: const Icon(Icons.schedule_rounded),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Calculate button ───────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Calculate Back-Pay'),
              onPressed: _compute,
            ),
          ),

          // ── Results ─────────────────────────────────────────────────────
          if (_grossBackpay != null) ...[
            const SizedBox(height: AppSpacing.lg),
            PrSectionCard(
              title: 'Calculation Result',
              icon: Icons.receipt_long_rounded,
              iconColor: AppColors.success,
              children: [
                PrInfoRow(
                  label: 'Gross Back-Pay',
                  value: _zar.format(_grossBackpay),
                  valueStyle: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                PrInfoRow(
                  label: 'Estimated PAYE on Back-Pay',
                  value: _zar.format(_backpayPaye),
                  valueStyle: const TextStyle(color: AppColors.error),
                ),
                const Divider(height: AppSpacing.md),
                PrInfoRow(
                  label: 'Estimated Net to Employee',
                  value: _zar.format(netBackpay),
                  valueStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'PAYE is estimated using the spread-over-period method. '
                    'Actual deduction may vary based on annual income YTD.',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('Print / Share'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Back-pay summary sharing will be available in the next update.',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Save Record'),
                    onPressed: _saving ? null : _saveBackPay,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
