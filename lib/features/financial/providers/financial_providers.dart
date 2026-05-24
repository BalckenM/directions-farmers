import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/financial_data_source.dart';
import '../data/financial_mock_data_source.dart';
import '../data/financial_repository.dart';

final financialDataSourceProvider = Provider<FinancialDataSource>(
  (ref) => FinancialMockDataSource(),
);

final financialRepositoryProvider = Provider<FinancialRepository>(
  (ref) => FinancialRepository(ref.watch(financialDataSourceProvider)),
);
