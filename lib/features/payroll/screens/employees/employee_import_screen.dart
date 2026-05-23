import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/payroll_employee.dart';
import '../../providers/payroll_action_providers.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

class EmployeeImportScreen extends ConsumerStatefulWidget {
  const EmployeeImportScreen({super.key});

  @override
  ConsumerState<EmployeeImportScreen> createState() =>
      _EmployeeImportScreenState();
}

class _EmployeeImportScreenState extends ConsumerState<EmployeeImportScreen> {
  String? _pickedFileName;
  List<List<String>> _parsedRows = [];
  List<bool> _rowValid = [];
  bool _importing = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    final content = utf8.decode(file.bytes!);
    final lines = const LineSplitter().convert(content);
    final dataLines = lines.where((l) => l.trim().isNotEmpty).skip(1).toList();

    final parsed = dataLines.map((l) {
      return l.split(',').map((c) => c.trim()).toList();
    }).toList();

    final valid = parsed.map((r) {
      if (r.length < 5) return false;
      return r[0].isNotEmpty &&
          r[1].isNotEmpty &&
          r[2].isNotEmpty &&
          r[4].isNotEmpty;
    }).toList();

    setState(() {
      _pickedFileName = file.name;
      _parsedRows = parsed;
      _rowValid = valid;
    });
  }

  EngagementType _parseEngagementType(String s) {
    switch (s
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('_', '')) {
      case 'permanent':
        return EngagementType.permanent;
      case 'seasonal':
        return EngagementType.seasonal;
      case 'casual':
        return EngagementType.casual;
      case 'contractor':
      case 'fixedterm':
        return EngagementType.contractor;
      default:
        return EngagementType.permanent;
    }
  }

  Future<void> _confirmImport(BuildContext ctx) async {
    setState(() => _importing = true);
    final notifier = ref.read(employeeNotifierProvider.notifier);
    int success = 0;
    int failed = 0;
    for (int i = 0; i < _parsedRows.length; i++) {
      if (!_rowValid[i]) {
        failed++;
        continue;
      }
      final r = _parsedRows[i];
      final now = DateTime.now();
      final emp = PayrollEmployee(
        id: 'emp_import_${now.millisecondsSinceEpoch}_$i',
        firstName: r[0],
        lastName: r[1],
        idOrPassportNumber: r[2],
        phone: r.length > 3 && r[3].isNotEmpty ? r[3] : null,
        address: '',
        nextOfKinName: '',
        nextOfKinPhone: '',
        status: EmploymentStatus.active,
        engagementType: _parseEngagementType(r.length > 4 ? r[4] : ''),
        occupationTitle: 'General Worker',
        startDate: now,
        bankName: r.length > 5 && r[5].isNotEmpty ? r[5] : null,
        bankAccountNumber: r.length > 6 && r[6].isNotEmpty ? r[6] : null,
        disbursementMethod: DisbursementMethod.bank,
        preferredLanguage: 'en',
        hasHousingBenefit: false,
        hasFoodBenefit: false,
        createdAt: now,
        updatedAt: now,
      );
      final saved = await notifier.add(emp);
      if (saved != null) {
        success++;
      } else {
        failed++;
      }
    }
    setState(() => _importing = false);
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('Import complete: $success added, $failed skipped.'),
          backgroundColor: success > 0
              ? PayrollTokens.green
              : PayrollTokens.rose,
        ),
      );
      if (success > 0) Navigator.of(ctx).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeCount = ref.watch(activeEmployeesProvider).length;
    final validCount = _rowValid.where((v) => v).length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 244, 246, 249),
        appBar: AppBar(
          backgroundColor: PayrollTokens.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Import Employees',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Upload File'),
              Tab(text: 'Preview'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _UploadTab(fileName: _pickedFileName, onSelect: _pickFile),
            _PreviewTab(
              rows: _parsedRows,
              rowValid: _rowValid,
              validCount: validCount,
              employeeCount: employeeCount,
              importing: _importing,
              onImport: _confirmImport,
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadTab extends StatelessWidget {
  const _UploadTab({required this.fileName, required this.onSelect});
  final String? fileName;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final fileSelected = fileName != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onSelect,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: fileSelected ? PayrollTokens.green : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    fileSelected
                        ? Icons.check_circle_outline
                        : Icons.cloud_upload_outlined,
                    size: 52,
                    color: fileSelected
                        ? PayrollTokens.green
                        : Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fileSelected ? fileName! : 'Tap to select a CSV file',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: fileSelected
                          ? PayrollTokens.green
                          : Colors.grey[600],
                    ),
                  ),
                  if (!fileSelected) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Required format: .csv',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.download_outlined),
              label: const Text('Download CSV Template'),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Template download started')),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Required CSV Format',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: PayrollTokens.navy,
            ),
          ),
          const SizedBox(height: 12),
          const _FormatCard(),
        ],
      ),
    );
  }
}

class _FormatCard extends StatelessWidget {
  const _FormatCard();

  @override
  Widget build(BuildContext context) {
    const fields = [
      ('First Name *', 'Text, e.g. John'),
      ('Last Name *', 'Text, e.g. Doe'),
      ('ID / Passport *', '13-digit SA ID or passport number'),
      ('Phone', 'Mobile number'),
      ('Employment Type *', 'permanent / seasonal / casual / contractor'),
      ('Bank Name', 'FNB / ABSA / Standard Bank / Nedbank / Capitec'),
      ('Account Number', 'Numeric account number'),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        children: fields
            .map(
              (f) => ListTile(
                dense: true,
                title: Text(
                  f.$1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: PayrollTokens.navy,
                  ),
                ),
                subtitle: Text(
                  f.$2,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                leading: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: PayrollTokens.teal,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PreviewTab extends StatelessWidget {
  const _PreviewTab({
    required this.rows,
    required this.rowValid,
    required this.validCount,
    required this.employeeCount,
    required this.importing,
    required this.onImport,
  });
  final List<List<String>> rows;
  final List<bool> rowValid;
  final int validCount;
  final int employeeCount;
  final bool importing;
  final Future<void> Function(BuildContext) onImport;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(
        child: Text(
          'No file selected yet.\nGo to Upload File tab and select a CSV.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final invalidCount = rows.length - validCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PayrollTokens.teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: PayrollTokens.teal.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: PayrollTokens.teal,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$validCount valid · $invalidCount invalid (red rows will be skipped). Existing: $employeeCount.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: PayrollTokens.teal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  PayrollTokens.navy.withValues(alpha: 0.06),
                ),
                columns: const [
                  DataColumn(label: Text('First Name')),
                  DataColumn(label: Text('Last Name')),
                  DataColumn(label: Text('ID / Passport')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Bank')),
                ],
                rows: List.generate(rows.length, (i) {
                  final r = rows[i];
                  final isValid = i < rowValid.length ? rowValid[i] : false;
                  return DataRow(
                    color: WidgetStateProperty.all(
                      isValid
                          ? null
                          : PayrollTokens.rose.withValues(alpha: 0.08),
                    ),
                    cells: [
                      DataCell(
                        Text(
                          r.isNotEmpty ? r[0] : '',
                          style: isValid
                              ? null
                              : const TextStyle(color: PayrollTokens.rose),
                        ),
                      ),
                      DataCell(Text(r.length > 1 ? r[1] : '')),
                      DataCell(Text(r.length > 2 ? r[2] : '')),
                      DataCell(Text(r.length > 3 ? r[3] : '')),
                      DataCell(
                        Text(
                          r.length > 4 ? r[4] : '',
                          style: isValid
                              ? null
                              : const TextStyle(color: PayrollTokens.rose),
                        ),
                      ),
                      DataCell(Text(r.length > 5 ? r[5] : '')),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: PayrollTokens.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: importing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.group_add_outlined),
              label: Text(
                importing ? 'Importing...' : 'Import $validCount Employees',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: (validCount == 0 || importing)
                  ? null
                  : () => onImport(context),
            ),
          ),
        ],
      ),
    );
  }
}
