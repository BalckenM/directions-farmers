import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/production_data_source.dart';
import '../data/production_remote_data_source.dart';
import '../data/production_repository.dart';

final productionDataSourceProvider = Provider<ProductionDataSource>(
  (ref) => ProductionRemoteDataSource(ref.read(apiDioProvider)),
);

final productionRepositoryProvider = Provider<ProductionRepository>(
  (ref) => ProductionRepository(ref.watch(productionDataSourceProvider)),
);
