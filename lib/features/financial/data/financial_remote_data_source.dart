import '../models/financial_transaction.dart';
import 'financial_data_source.dart';

class FinancialRemoteDataSource implements FinancialDataSource {
  @override
  Future<List<FinancialTransaction>> getFinancialTransactions() =>
      throw UnimplementedError('FinancialRemoteDataSource.getFinancialTransactions not implemented');
}
