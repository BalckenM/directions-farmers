import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../models/financial_transaction.dart';
import 'financial_data_source.dart';

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

  Future<void> addFinancialTransaction(FinancialTransaction transaction) async {
    try {
      await _source.addFinancialTransaction(transaction);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }
}

