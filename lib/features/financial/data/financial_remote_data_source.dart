import '../models/financial_transaction.dart';
import 'financial_data_source.dart';

// Stub — financial module not yet active. No HTTP calls are made.
class FinancialRemoteDataSource implements FinancialDataSource {
  FinancialRemoteDataSource(dynamic _);

  @override Future<List<FinancialTransaction>> getFinancialTransactions() async => const [];
  @override Future<void> addFinancialTransaction(FinancialTransaction transaction) async {}
}
