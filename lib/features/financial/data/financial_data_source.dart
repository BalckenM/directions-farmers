import '../models/financial_transaction.dart';

abstract class FinancialDataSource {
  Future<List<FinancialTransaction>> getFinancialTransactions();
}
