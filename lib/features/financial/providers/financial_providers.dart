import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/financial_data_source.dart';
import '../data/financial_remote_data_source.dart';
import '../data/financial_repository.dart';

final financialDataSourceProvider = Provider<FinancialDataSource>(
  (ref) => FinancialRemoteDataSource(ref.read(apiDioProvider)),
);

final financialRepositoryProvider = Provider<FinancialRepository>(
  (ref) => FinancialRepository(ref.watch(financialDataSourceProvider)),
);
