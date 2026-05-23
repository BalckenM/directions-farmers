import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/employment_contract.dart';
import '../models/payroll_employee.dart';

// ─── Brand colours ───────────────────────────────────────────────────────────
final _navy  = PdfColor.fromHex('1E3A5F');
final _grey  = PdfColor.fromHex('757575');
final _line  = PdfColor.fromHex('E0E0E0');

final _zarFmt = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);
final _df     = DateFormat('d MMMM y');

/// Generates an employment contract PDF, optionally embedding a handwritten
/// signature captured as a base64-encoded PNG stored in [EmploymentContract.signatureImageBase64].
class ContractPdfService {
  const ContractPdfService();

  /// Returns PDF bytes for [contract] / [employee].
  Future<Uint8List> generate({
    required EmploymentContract contract,
    required PayrollEmployee employee,
  }) async {
    final doc = pw.Document(
      title: 'Employment Contract – ${employee.fullName}',
      author: '4Directions Farm Manager',
    );

    // Decode signature image if present
    pw.MemoryImage? sigImage;
    if (contract.signatureImageBase64 != null &&
        contract.signatureImageBase64!.isNotEmpty) {
      final bytes = base64Decode(contract.signatureImageBase64!);
      sigImage = pw.MemoryImage(bytes);
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 56),
        header: (ctx) => _header(ctx, contract, employee),
        footer: (ctx) => _footer(ctx, contract),
        build: (ctx) => [
          _body(contract, employee),
          if (sigImage != null) ...[
            pw.SizedBox(height: 24),
            _signatureSection(contract, sigImage),
          ],
        ],
      ),
    );

    return doc.save();
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  pw.Widget _header(
      pw.Context ctx, EmploymentContract contract, PayrollEmployee employee) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: pw.BoxDecoration(
        color: _navy,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Employment Contract',
            style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white),
          ),
          pw.Text(
            _contractTypeLabel(contract.type),
            style: pw.TextStyle(fontSize: 10, color: PdfColors.white),
          ),
        ],
      ),
    );
  }

  // ── Footer ──────────────────────────────────────────────────────────────────
  pw.Widget _footer(pw.Context ctx, EmploymentContract contract) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: _line, width: 0.5))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Contract ID: ${contract.id}',
              style: pw.TextStyle(fontSize: 8, color: _grey)),
          pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: _grey),
          ),
        ],
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────────
  pw.Widget _body(EmploymentContract contract, PayrollEmployee employee) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _section('PARTIES', [
          _row('Employee Name', employee.fullName),
          _row('Employee ID', employee.id),
          _row('Occupation', employee.occupationTitle),
          _row('Employment Type',
              _engagementTypeLabel(employee.engagementType)),
        ]),
        pw.SizedBox(height: 16),
        _section('CONTRACT DETAILS', [
          _row('Contract Type', _contractTypeLabel(contract.type)),
          _row('Start Date', _df.format(contract.startDate)),
          if (contract.endDate != null)
            _row('End Date', _df.format(contract.endDate!)),
          _row('Gross Monthly Salary',
              '${contract.currency} ${_zarFmt.format(contract.grossMonthlySalary)}'),
          _row('Version', '${contract.version}'),
          _row('Created', _df.format(contract.createdAt)),
        ]),
        pw.SizedBox(height: 16),
        _section('JOB DESCRIPTION', []),
        pw.Text(contract.jobDescription,
            style: pw.TextStyle(fontSize: 10, color: _grey)),
        pw.SizedBox(height: 16),
        _section('TERMS & CONDITIONS', []),
        ..._standardClauses(contract),
        if (contract.status == ContractStatus.signed) ...[
          pw.SizedBox(height: 16),
          _section('SIGNATURE DETAILS', [
            if (contract.signedByName != null)
              _row('Signed By', contract.signedByName!),
            if (contract.signedAt != null)
              _row('Date Signed', _df.format(contract.signedAt!)),
          ]),
        ],
      ],
    );
  }

  // ── Standard clauses ───────────────────────────────────────────────────────
  List<pw.Widget> _standardClauses(EmploymentContract contract) {
    final clauses = [
      '1. This contract is governed by the Basic Conditions of Employment Act (BCEA), Act 75 of 1997, and the Labour Relations Act (LRA), Act 66 of 1995.',
      '2. The employer shall deduct and pay over applicable statutory contributions including UIF and PAYE in accordance with South African legislation.',
      '3. Either party may terminate this contract by providing ${contract.type == ContractType.permanent ? 'four (4) weeks' : 'one (1) week\'s'} notice in writing.',
      '4. The employee agrees to perform duties with due diligence and to comply with all lawful instructions from the employer.',
      '5. This contract constitutes the entire agreement between the parties and supersedes all prior negotiations.',
    ];
    return clauses.map((c) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(c, style: pw.TextStyle(fontSize: 9, color: _grey)),
      );
    }).toList();
  }

  // ── Signature section ──────────────────────────────────────────────────────
  pw.Widget _signatureSection(
      EmploymentContract contract, pw.MemoryImage sigImage) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _line),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('EMPLOYEE SIGNATURE',
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _navy)),
          pw.SizedBox(height: 8),
          pw.Image(sigImage,
              width: 200, height: 66, fit: pw.BoxFit.contain),
          pw.SizedBox(height: 4),
          pw.Container(
            width: 200, height: 0.5,
            color: _grey,
          ),
          pw.SizedBox(height: 4),
          if (contract.signedByName != null)
            pw.Text(contract.signedByName!,
                style: pw.TextStyle(fontSize: 9, color: _grey)),
          if (contract.signedAt != null)
            pw.Text(_df.format(contract.signedAt!),
                style: pw.TextStyle(fontSize: 8, color: _grey)),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  pw.Widget _section(String title, List<_RowData> rows) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 6),
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('E8EDF5'),
            borderRadius: pw.BorderRadius.circular(2),
          ),
          child: pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _navy)),
        ),
        ...rows.map((r) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 120,
                    child: pw.Text(r.label,
                        style:
                            pw.TextStyle(fontSize: 9, color: _grey)),
                  ),
                  pw.Expanded(
                    child: pw.Text(r.value,
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: _navy)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  _RowData _row(String label, String value) => _RowData(label, value);

  String _contractTypeLabel(ContractType t) => switch (t) {
        ContractType.permanent   => 'Permanent',
        ContractType.fixedTerm   => 'Fixed Term',
        ContractType.seasonal    => 'Seasonal',
        ContractType.casual      => 'Casual',
      };

  String _engagementTypeLabel(dynamic e) {
    final s = e.toString().split('.').last;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _RowData {
  const _RowData(this.label, this.value);
  final String label;
  final String value;
}
