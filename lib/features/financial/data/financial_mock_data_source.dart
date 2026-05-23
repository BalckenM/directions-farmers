import '../models/financial_transaction.dart';
import 'financial_data_source.dart';

class FinancialMockDataSource implements FinancialDataSource {
  @override
  Future<List<FinancialTransaction>> getFinancialTransactions() async =>
      _transactions;

  @override
  Future<void> addFinancialTransaction(FinancialTransaction transaction) async =>
      _transactions.insert(0, transaction);

  // Mutable in-memory seed data
  final _transactions = <FinancialTransaction>[
    FinancialTransaction(
      id: 'FT-001',
      date: '2024-04-02',
      type: 'income',
      category: 'Livestock sales',
      description: 'Sale of 3 A2 steers — Midlands Auction',
      amountZar: 28500.00,
      reference: 'MLA-2024-0402',
      animalIds: ['C-001', 'C-002', 'C-003'],
    ),
    FinancialTransaction(
      id: 'FT-002',
      date: '2024-04-03',
      type: 'expense',
      category: 'Feed & supplements',
      description: 'Lucerne hay bales (40 × 20 kg)',
      amountZar: 4800.00,
      reference: 'INV-FEED-2024-0403',
    ),
    FinancialTransaction(
      id: 'FT-003',
      date: '2024-04-05',
      type: 'expense',
      category: 'Veterinary',
      description: 'Annual vaccination programme — cattle herd',
      amountZar: 3250.00,
      reference: 'VET-DR-2024-0405',
      animalIds: ['C-001', 'C-002', 'C-004', 'C-005'],
    ),
    FinancialTransaction(
      id: 'FT-004',
      date: '2024-04-08',
      type: 'income',
      category: 'Milk sales',
      description: 'Weekly milk delivery — Meander Dairy',
      amountZar: 6720.00,
      reference: 'MD-WK14-2024',
    ),
    FinancialTransaction(
      id: 'FT-005',
      date: '2024-04-10',
      type: 'expense',
      category: 'Labour',
      description: 'Casual worker wages — shearing season',
      amountZar: 5400.00,
      reference: 'PAY-2024-0410',
    ),
    FinancialTransaction(
      id: 'FT-006',
      date: '2024-04-12',
      type: 'income',
      category: 'Wool sales',
      description: 'Wool clip delivery — BKB Port Elizabeth',
      amountZar: 14200.00,
      reference: 'BKB-2024-0471',
    ),
    FinancialTransaction(
      id: 'FT-007',
      date: '2024-04-15',
      type: 'expense',
      category: 'Infrastructure',
      description: 'Fence repair — Camp 3 perimeter',
      amountZar: 2100.00,
      notes: 'Materials + labour — contracted to D. Potgieter',
    ),
  ];
}
