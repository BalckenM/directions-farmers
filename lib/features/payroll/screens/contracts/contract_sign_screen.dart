import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/employment_contract.dart';
import '../../providers/payroll_action_providers.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

final _zar    = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);
final _dateFmt = DateFormat('d MMM yyyy');

class ContractSignScreen extends ConsumerStatefulWidget {
  final String contractId;
  const ContractSignScreen({super.key, required this.contractId});

  @override
  ConsumerState<ContractSignScreen> createState() => _ContractSignScreenState();
}

class _ContractSignScreenState extends ConsumerState<ContractSignScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  bool _signed    = false;
  bool _saving    = false;
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool get _hasSignature => _strokes.any((s) => s.isNotEmpty);
  void _clearSignature() =>
      setState(() { _strokes.clear(); _currentStroke = []; });

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  /// Renders [_strokes] onto a 600×200 canvas and returns PNG bytes.
  Future<String> _rasteriseSignature() async {
    const w = 600.0;
    const h = 200.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w, h));

    // White background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = Colors.white,
    );

    // Replay strokes
    final paint = Paint()
      ..color = PayrollTokens.navy
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in _strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 1.5, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final p in stroke.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(w.toInt(), h.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return base64Encode(byteData!.buffer.asUint8List());
  }

  Future<void> _sign(EmploymentContract contract) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasSignature) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please draw your signature before signing.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final tt = Theme.of(ctx).textTheme;
        final cs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Icon(Icons.verified_outlined, size: 44, color: PayrollTokens.green),
              const SizedBox(height: AppSpacing.sm),
              Text('Sign & Lock Contract?',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This will permanently lock the contract as signed. '
                'This action cannot be undone.',
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: PayrollTokens.green),
                    onPressed: () => Navigator.pop(ctx, true),
                    icon: const Icon(Icons.lock_outline_rounded),
                    label: const Text('Sign & Lock'),
                  ),
                ),
              ]),
            ],
          ),
        );
      },
    );
    if (confirmed != true) return;

    setState(() => _saving = true);
    final signatureBase64 = await _rasteriseSignature();
    final updated = contract.copyWith(
      status:               ContractStatus.signed,
      signedAt:             DateTime.now(),
      signedByName:         _nameCtrl.text.trim(),
      signatureImageBase64: signatureBase64,
    );
    await ref.read(contractNotifierProvider.notifier).update(updated);
    setState(() { _saving = false; _signed = true; });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Contract signed successfully.'),
          backgroundColor: PayrollTokens.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs        = Theme.of(context).colorScheme;
    final tt        = Theme.of(context).textTheme;
    final contracts = ref.watch(contractsProvider(null));
    final contract  = contracts.where((c) => c.id == widget.contractId).firstOrNull;
    final employees = ref.watch(activeEmployeesProvider);

    if (contract == null) {
      return FarmScaffold(
        appBar: const FarmAppBar(title: 'Sign Contract'),
        body: const Center(child: Text('Contract not found.')),
      );
    }

    final employee = employees.where((e) => e.id == contract.employeeId).firstOrNull;
    final isSigned = _signed || contract.status == ContractStatus.signed;

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Sign Contract'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Contract summary card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: PayrollTokens.contractStatusColor(contract.status)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      PayrollTokens.contractStatusLabel(contract.status),
                      style: tt.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: PayrollTokens.contractStatusColor(contract.status),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(PayrollTokens.contractTypeLabel(contract.type),
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ]),
                const Divider(height: AppSpacing.lg),
                if (employee != null) _Row(label: 'Employee', value: employee.fullName),
                _Row(
                  label: 'Job Title',
                  value: contract.jobDescription.length > 60
                      ? '${contract.jobDescription.substring(0, 60)}\u2026'
                      : contract.jobDescription,
                ),
                _Row(label: 'Start Date',    value: _dateFmt.format(contract.startDate)),
                if (contract.endDate != null)
                  _Row(label: 'End Date',    value: _dateFmt.format(contract.endDate!)),
                _Row(label: 'Gross Salary',  value: _zar.format(contract.grossMonthlySalary)),
                if (contract.signedByName != null)
                  _Row(label: 'Signed By',   value: contract.signedByName!),
                if (contract.signedAt != null)
                  _Row(label: 'Signed At',   value: _dateFmt.format(contract.signedAt!)),
              ]),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (!isSigned) ...[
              Text('Signatory',
                  style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700, color: PayrollTokens.navy)),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name of Signatory *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // Signature canvas
              Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (d) => setState(() {
                      _currentStroke = [d.localPosition];
                      _strokes.add(_currentStroke);
                    }),
                    onPanUpdate: (d) =>
                        setState(() => _currentStroke.add(d.localPosition)),
                    onPanEnd: (_) =>
                        setState(() => _currentStroke = []),
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _hasSignature
                              ? PayrollTokens.navy.withValues(alpha: 0.4)
                              : cs.outlineVariant,
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: CustomPaint(
                          painter: _SignaturePainter(_strokes),
                          child: _hasSignature
                              ? null
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.draw_outlined,
                                          size: 28, color: cs.outlineVariant),
                                      const SizedBox(height: 6),
                                      Text('Draw your signature here',
                                          style: tt.bodySmall?.copyWith(
                                              color: cs.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4, right: 8,
                    child: TextButton.icon(
                      onPressed: _hasSignature ? _clearSignature : null,
                      icon: const Icon(Icons.refresh, size: 14),
                      label: Text('Clear', style: tt.labelSmall),
                      style: TextButton.styleFrom(
                        foregroundColor: cs.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: PayrollTokens.green,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  icon: _saving
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.verified_outlined),
                  label: Text('Sign & Lock Contract',
                      style: tt.titleSmall?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  onPressed: _saving ? null : () => _sign(contract),
                ),
              ),
            ] else ...[
              // Signed confirmation banner
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: PayrollTokens.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: PayrollTokens.green.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle_rounded,
                      color: PayrollTokens.green, size: 28),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Contract has been signed and locked.',
                      style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: PayrollTokens.green),
                    ),
                  ),
                ]),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ),
        Expanded(
          child: Text(value,
              style: tt.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600, color: PayrollTokens.navy)),
        ),
      ]),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter(this.strokes);
  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = PayrollTokens.navy
      ..strokeWidth = 2.0
      ..strokeCap   = StrokeCap.round
      ..strokeJoin  = StrokeJoin.round
      ..style       = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 1.5, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final p in stroke.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) => old.strokes != strokes;
}
