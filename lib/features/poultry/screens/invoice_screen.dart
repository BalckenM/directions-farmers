import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../providers/poultry_providers.dart';

class InvoiceScreen extends ConsumerStatefulWidget {
  const InvoiceScreen({super.key, required this.flockId});

  final String flockId;

  @override
  ConsumerState<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends ConsumerState<InvoiceScreen> {
  bool _generating = false;
  String? _selectedFlockId;

  String get _effectiveFlockId => _selectedFlockId ?? widget.flockId;

  Future<void> _generateAndPreview() async {
    setState(() => _generating = true);
    try {
      final flock =
          ref.read(flockDetailProvider(_effectiveFlockId)).value;
      final harvest =
          ref.read(flockHarvestRecordsProvider(_effectiveFlockId)).value;
      final meds =
          ref.read(flockMedicationLogsProvider(_effectiveFlockId)).value;

      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (ctx) => [
            // ── Header ───────────────────────────────────────────────────
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '4Directions Farm',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(
                            AppColors.poultryColor.toARGB32()),
                      ),
                    ),
                    pw.Text('Poultry Operations',
                        style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('BATCH INVOICE',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        )),
                    pw.Text(
                      'Generated: ${DateTime.now().toString().substring(0, 10)}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 12),

            // ── Flock Details ─────────────────────────────────────────────
            if (flock != null) ...[
              pw.Text('Flock Details',
                  style: pw.TextStyle(
                      fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              _pdfTable([
                ['Batch Name', flock.batchName],
                ['Production Type', flock.productionType.toUpperCase()],
                ['House', flock.houseId],
                ['Placement Count', '${flock.placementCount} birds'],
                ['Current Count', '${flock.currentCount} birds'],
                [
                  'Age',
                  '${flock.dayOfAge} days'
                ],
                ['Status', flock.status.toUpperCase()],
              ]),
              pw.SizedBox(height: 16),
            ],

            // ── Harvest Summary ───────────────────────────────────────────
            if (harvest != null && harvest.isNotEmpty) ...[
              pw.Text('Harvest Records',
                  style: pw.TextStyle(
                      fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: [
                  'Date',
                  'Birds',
                  'Live Wt (kg)',
                  'Price/kg',
                  'Revenue'
                ],
                data: harvest
                    .map((h) => [
                          h.harvestDate,
                          '${h.birdsHarvested}',
                          h.totalLiveWeightKg.toStringAsFixed(1),
                          h.pricePerKgZar != null
                              ? 'R ${h.pricePerKgZar!.toStringAsFixed(2)}'
                              : '—',
                          h.pricePerKgZar != null
                              ? 'R ${h.totalRevenueZar.toStringAsFixed(0)}'
                              : '—',
                        ])
                    .toList(),
                border: pw.TableBorder.all(
                    color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey200),
                cellHeight: 24,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 16),
            ],

            // ── Medication Summary ────────────────────────────────────────
            if (meds != null && meds.isNotEmpty) ...[
              pw.Text('Medication Log',
                  style: pw.TextStyle(
                      fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Drug', 'Dosage', 'Route', 'W/D Days'],
                data: meds
                    .map((m) => [
                          m.date,
                          m.drugName,
                          m.dosage,
                          m.route.replaceAll('_', ' '),
                          '${m.withdrawalDays}d',
                        ])
                    .toList(),
                border: pw.TableBorder.all(
                    color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey200),
                cellHeight: 24,
              ),
              pw.SizedBox(height: 16),
            ],

            // ── Cost Estimate ─────────────────────────────────────────────
            if (flock != null) ...[
              pw.Text('Cost Estimate',
                  style: pw.TextStyle(
                      fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              () {
                final chickCost = flock.placementCount * 18.50;
                final feedCost =
                    (flock.feedConsumedTotalKg ??
                            flock.placementCount *
                                0.18 *
                                flock.dayOfAge) *
                        7.80;
                final medCost = (meds?.length ?? 0) * 280.0;
                const otherCost = 1850.0;
                final total = chickCost + feedCost + medCost + otherCost;
                return _pdfTable([
                  [
                    'Day-Old Chick Cost',
                    'R ${chickCost.toStringAsFixed(0)}'
                  ],
                  ['Feed Cost', 'R ${feedCost.toStringAsFixed(0)}'],
                  [
                    'Medication & Vaccines',
                    'R ${medCost.toStringAsFixed(0)}'
                  ],
                  ['Labour & Other', 'R ${otherCost.toStringAsFixed(0)}'],
                  ['TOTAL', 'R ${total.toStringAsFixed(0)}'],
                ]);
              }(),
            ],

            pw.SizedBox(height: 24),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Text(
              '* Figures are estimates. Final invoice subject to actual weights and prices.',
              style: pw.TextStyle(
                  fontSize: 9,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey600),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (_) async => doc.save(),
        name: 'batch_invoice_${widget.flockId}.pdf',
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  pw.Widget _pdfTable(List<List<String>> rows) {
    return pw.Table(
      border:
          pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      children: rows.map((row) {
        final isLast = row == rows.last;
        return pw.TableRow(
          decoration: isLast
              ? const pw.BoxDecoration(color: PdfColors.grey100)
              : null,
          children: row
              .map((cell) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 5),
                    child: pw.Text(
                      cell,
                      style: isLast
                          ? pw.TextStyle(fontWeight: pw.FontWeight.bold)
                          : null,
                    ),
                  ))
              .toList(),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // When no flockId supplied (entry from hub), show a flock picker first.
    if (_effectiveFlockId.isEmpty) {
      final flocksAsync = ref.watch(flocksProvider);
      return FarmScaffold(
        drawer: null,
        appBar: const FarmAppBar(title: 'Generate Invoice'),
        body: flocksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (flocks) {
            if (flocks.isEmpty) {
              return const Center(child: Text('No flocks found. Add a flock first.'));
            }
            final tt = Theme.of(context).textTheme;
            final cs = Theme.of(context).colorScheme;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text('Select a flock to invoice',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: flocks.length,
                    itemBuilder: (_, i) {
                      final f = flocks[i];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.poultryColorContainer,
                          child: Icon(Icons.egg_outlined, color: AppColors.poultryColor),
                        ),
                        title: Text(f.batchName),
                        subtitle: Text(
                          '${f.productionType.toUpperCase()} · ${f.currentCount} birds · Day ${f.dayOfAge}',
                          style: tt.bodySmall?.copyWith(color: cs.outline),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => setState(() => _selectedFlockId = f.id),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    final flockAsync = ref.watch(flockDetailProvider(_effectiveFlockId));

    return FarmScaffold(
      drawer: null,
      appBar: FarmAppBar(
        title: 'Generate Invoice',
        // Show back-to-picker arrow when reached via hub (no widget.flockId)
        leading: widget.flockId.isEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedFlockId = null),
              )
            : null,
      ),
      body: flockAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (flock) {
          if (flock == null) {
            return const Center(child: Text('Flock not found.'));
          }
          final tt = Theme.of(context).textTheme;
          final cs = Theme.of(context).colorScheme;

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePaddingHorizontal,
              vertical: AppSpacing.pagePaddingVertical,
            ),
            children: [
              // Summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.poultryColor
                                .withValues(alpha: 0.12),
                            child: const Icon(Icons.receipt_long_outlined,
                                color: AppColors.poultryColor, size: 20),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(flock.batchName,
                                    style: tt.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  '${flock.productionType.toUpperCase()} · ${flock.houseId} · Day ${flock.dayOfAge}',
                                  style: tt.bodySmall?.copyWith(
                                      color: cs.outline),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text("What's included", style: tt.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              _IncludeRow(
                icon: Icons.info_outline,
                label: 'Flock details & status',
              ),
              _IncludeRow(
                icon: Icons.scale_outlined,
                label: 'Harvest records (if available)',
              ),
              _IncludeRow(
                icon: Icons.medical_services_outlined,
                label: 'Medication log with withdrawal dates',
              ),
              _IncludeRow(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Estimated cost breakdown',
              ),
              const SizedBox(height: AppSpacing.xl),

              // Generate button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _generating ? null : _generateAndPreview,
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.poultryColor),
                  icon: _generating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(_generating
                      ? 'Generating PDF…'
                      : 'Preview & Print Invoice'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'A PDF preview will open in the browser. You can print or save it from there.',
                style: tt.bodySmall?.copyWith(color: cs.outline),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IncludeRow extends StatelessWidget {
  const _IncludeRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.poultryColor),
          const SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
      ),
    );
  }
}
