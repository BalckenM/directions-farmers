import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/date_picker_field.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import 'financial_screen.dart';

class AddFinancialTransactionScreen extends ConsumerStatefulWidget {
  const AddFinancialTransactionScreen({super.key});

  @override
  ConsumerState<AddFinancialTransactionScreen> createState() =>
      _AddFinancialTransactionScreenState();
}

class _AddFinancialTransactionScreenState
    extends ConsumerState<AddFinancialTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _type = 'expense';
  String? _category;
  DateTime? _date = DateTime.now();
  bool _submitting = false;

  static const _incomeCategories = [
    'Livestock Sales',
    'Milk Sales',
    'Wool Sales',
    'Egg Sales',
    'Crop Sales',
    'Government Grant / Subsidy',
    'Other Income',
  ];

  static const _expenseCategories = [
    'Feed & Supplements',
    'Veterinary & Medicines',
    'Labour & Wages',
    'Equipment & Repairs',
    'Fuel & Transport',
    'Dipping & Pest Control',
    'Fencing & Infrastructure',
    'Compliance & Permits',
    'Auction Fees',
    'Other Expense',
  ];

  List<String> get _categories =>
      _type == 'income' ? _incomeCategories : _expenseCategories;

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _amountCtrl.dispose();
    _referenceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    ref.invalidate(financialTransactionsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${_type == 'income' ? 'Income' : 'Expense'} recorded successfully'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Add Financial Entry'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Type toggle
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.card,
                side: BorderSide(color: cs.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Entry Type', style: theme.textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'income',
                          label: Text('Income'),
                          icon: Icon(Icons.arrow_downward_rounded),
                        ),
                        ButtonSegment(
                          value: 'expense',
                          label: Text('Expense'),
                          icon: Icon(Icons.arrow_upward_rounded),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (sel) => setState(() {
                        _type = sel.first;
                        _category = null;
                      }),
                      style: ButtonStyle(
                        iconColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return _type == 'income'
                                ? const Color(0xFF2E7D32)
                                : cs.error;
                          }
                          return null;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Category dropdown
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v),
              validator: (v) => v == null ? 'Select a category' : null,
            ),
            const SizedBox(height: AppSpacing.sm),

            FarmTextField(
              controller: _descriptionCtrl,
              label: 'Description *',
              hint: 'e.g. Sold 3 Bonsmara steers at Ermelo auction',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a description' : null,
            ),
            const SizedBox(height: AppSpacing.sm),

            FarmTextField(
              controller: _amountCtrl,
              label: 'Amount (ZAR) *',
              hint: '0.00',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              prefixIcon: const Icon(Icons.currency_exchange_rounded),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter an amount';
                final parsed = double.tryParse(v.trim());
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid amount greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),

            DatePickerField(
              label: 'Date *',
              value: _date,
              onChanged: (v) => setState(() => _date = v),
            ),
            const SizedBox(height: AppSpacing.sm),

            FarmTextField(
              controller: _referenceCtrl,
              label: 'Reference / Invoice No.',
              hint: 'Optional reference number',
            ),
            const SizedBox(height: AppSpacing.sm),

            FarmTextField(
              controller: _notesCtrl,
              label: 'Notes',
              hint: 'Any additional details',
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),

            PrimaryButton(
              label: 'Save Entry',
              isLoading: _submitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
