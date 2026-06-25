import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/financial/data/financial_data_source.dart';
import 'package:mobile_app/features/financial/data/financial_remote_data_source.dart';
import 'package:mobile_app/features/financial/data/financial_repository.dart';

final financialDataSourceProvider = Provider<FinancialDataSource>(
  (ref) => FinancialRemoteDataSource(ref.read(apiDioProvider)),
);

final financialRepositoryProvider = Provider<FinancialRepository>(
  (ref) => FinancialRepository(ref.watch(financialDataSourceProvider)),
);
