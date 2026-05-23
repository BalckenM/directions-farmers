import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/deduction_rule.dart';
import '../../providers/payroll_action_providers.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

class DeductionsScreen extends ConsumerWidget {
  const DeductionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(deductionRulesProvider(null));

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Deduction Rules',
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.gavel_outlined, size: 18),
            label: const Text('Garnishee Orders'),
            onPressed: () => context.push(AppRoutes.payrollGarnisheeOrders),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Rule'),
        backgroundColor: PayrollTokens.navy,
      ),
      body: rules.isEmpty
          ? const Center(
              child: Text(
                'No deduction rules yet.\nTap + to add one.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: rules.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final r = rules[i];
                final (accentColor, _) = _typeAccent(r.type);
                final typeLabel = _typeLabelStatic(r.type);
                final valueText = r.basis == DeductionBasis.percentage
                    ? '${r.value.toStringAsFixed(1)}%'
                    : 'R ${r.value.toStringAsFixed(0)}';
                return Opacity(
                  opacity: r.isActive ? 1.0 : 0.55,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left accent bar
                            Container(width: 4, color: accentColor),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    // Type badge circle
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: accentColor.withValues(
                                          alpha: 0.12,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          r.code.length > 4
                                              ? r.code.substring(0, 4)
                                              : r.code,
                                          style: TextStyle(
                                            color: accentColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Label + meta
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            r.label,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  decoration: r.isActive
                                                      ? null
                                                      : TextDecoration
                                                            .lineThrough,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              // Type chip
                                              _SmallChip(
                                                label: typeLabel,
                                                color: accentColor,
                                              ),
                                              // Value chip
                                              _SmallChip(
                                                label: valueText,
                                                color: PayrollTokens.navy,
                                              ),
                                              // Cap chip
                                              if (r.cappedAt != null)
                                                _SmallChip(
                                                  label:
                                                      'cap R${r.cappedAt!.toStringAsFixed(0)}',
                                                  color: PayrollTokens.amber,
                                                ),
                                              // Inactive chip
                                              if (!r.isActive)
                                                _SmallChip(
                                                  label: 'Inactive',
                                                  color: Colors.grey,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Actions menu
                                    PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        size: 18,
                                      ),
                                      onSelected: (v) async {
                                        if (v == 'edit') {
                                          _openSheet(context, ref, r);
                                        } else if (v == 'toggle') {
                                          await ref
                                              .read(
                                                deductionNotifierProvider
                                                    .notifier,
                                              )
                                              .updateRule(
                                                r.copyWith(
                                                  isActive: !r.isActive,
                                                ),
                                              );
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        PopupMenuItem(
                                          value: 'toggle',
                                          child: Text(
                                            r.isActive
                                                ? 'Deactivate'
                                                : 'Activate',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _openSheet(BuildContext ctx, WidgetRef ref, DeductionRule? existing) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _DeductionSheet(existing: existing, ref: ref),
    );
  }
}

// ─── Add/edit bottom sheet ─────────────────────────────────────────────────────
class _DeductionSheet extends ConsumerStatefulWidget {
  const _DeductionSheet({this.existing, required this.ref});
  final DeductionRule? existing;
  final WidgetRef ref;

  @override
  ConsumerState<_DeductionSheet> createState() => _DeductionSheetState();
}

class _DeductionSheetState extends ConsumerState<_DeductionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _labelCtrl;
  late final TextEditingController _valueCtrl;
  late final TextEditingController _capCtrl;

  late DeductionType _type;
  late DeductionBasis _basis;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _codeCtrl = TextEditingController(text: e?.code ?? '');
    _labelCtrl = TextEditingController(text: e?.label ?? '');
    _valueCtrl = TextEditingController(text: e?.value.toString() ?? '');
    _capCtrl = TextEditingController(
      text: e?.cappedAt != null ? e!.cappedAt!.toString() : '',
    );
    _type = e?.type ?? DeductionType.voluntary;
    _basis = e?.basis ?? DeductionBasis.fixedAmount;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _labelCtrl.dispose();
    _valueCtrl.dispose();
    _capCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isEdit ? 'Edit Rule' : 'New Deduction Rule',
                    style: tt.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Code + Label row
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: _codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'Code'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _labelCtrl,
                    decoration: const InputDecoration(labelText: 'Label'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Type dropdown
            DropdownButtonFormField<DeductionType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: DeductionType.values
                  .map(
                    (t) =>
                        DropdownMenuItem(value: t, child: Text(_typeLabel(t))),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),

            // Basis toggle
            Text('Basis', style: tt.labelMedium),
            const SizedBox(height: 8),
            SegmentedButton<DeductionBasis>(
              segments: const [
                ButtonSegment(
                  value: DeductionBasis.fixedAmount,
                  label: Text('Fixed (R)'),
                ),
                ButtonSegment(
                  value: DeductionBasis.percentage,
                  label: Text('Percentage (%)'),
                ),
              ],
              selected: {_basis},
              onSelectionChanged: (s) => setState(() => _basis = s.first),
            ),
            const SizedBox(height: 16),

            // Value + cap row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _valueCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: InputDecoration(
                      labelText: _basis == DeductionBasis.percentage
                          ? 'Percentage (%)'
                          : 'Amount (R)',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _capCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Cap at (R)',
                      hintText: 'Optional',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: PayrollTokens.navy,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: _submit,
                child: Text(isEdit ? 'Save Changes' : 'Add Rule'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final e = widget.existing;
    final rule = DeductionRule(
      id: e?.id ?? 'dr_${DateTime.now().millisecondsSinceEpoch}',
      code: _codeCtrl.text.trim().toUpperCase(),
      label: _labelCtrl.text.trim(),
      type: _type,
      basis: _basis,
      value: double.parse(_valueCtrl.text),
      cappedAt: _capCtrl.text.isEmpty ? null : double.parse(_capCtrl.text),
      isActive: e?.isActive ?? true,
      createdAt: e?.createdAt ?? DateTime.now(),
    );
    if (e == null) {
      await ref.read(deductionNotifierProvider.notifier).addRule(rule);
    } else {
      await ref.read(deductionNotifierProvider.notifier).updateRule(rule);
    }
    if (mounted) Navigator.pop(context);
  }

  String _typeLabel(DeductionType t) => switch (t) {
    DeductionType.statutory => 'Statutory',
    DeductionType.voluntary => 'Voluntary',
    DeductionType.benefit => 'Benefit',
    DeductionType.garnishee => 'Garnishee',
  };
}

// --- Helpers -----------------------------------------------------------------

(Color, String) _typeAccent(DeductionType t) => switch (t) {
  DeductionType.statutory => (const Color.fromARGB(255, 40, 53, 147), 'STAT'),
  DeductionType.voluntary => (const Color.fromARGB(255, 0, 105, 92), 'VOL'),
  DeductionType.benefit => (const Color.fromARGB(255, 106, 27, 154), 'BEN'),
  DeductionType.garnishee => (const Color.fromARGB(255, 198, 40, 40), 'GARN'),
};

String _typeLabelStatic(DeductionType t) => switch (t) {
  DeductionType.statutory => 'Statutory',
  DeductionType.voluntary => 'Voluntary',
  DeductionType.benefit => 'Benefit',
  DeductionType.garnishee => 'Garnishee',
};

// --- Small chip ---------------------------------------------------------------

class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
