import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../models/financial_transaction.dart';
import 'financial_data_source.dart';
import 'financial_mock_data_source.dart';
import 'financial_remote_data_source.dart';

class FinancialRepository {
  FinancialRepository(this._source);

  final FinancialDataSource _source;

  Future<List<FinancialTransaction>> getFinancialTransactions() async {
    try {
      return await _source.getFinancialTransactions();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }
}

final financialRepositoryProvider = Provider<FinancialRepository>((ref) {
  final FinancialDataSource source = AppConstants.useMockData
      ? FinancialMockDataSource()
      : FinancialRemoteDataSource();
  return FinancialRepository(source);
});
