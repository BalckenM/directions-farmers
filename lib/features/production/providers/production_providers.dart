import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/production_data_source.dart';
import '../data/production_mock_data_source.dart';
import '../data/production_repository.dart';

final productionDataSourceProvider = Provider<ProductionDataSource>(
  (ref) => ProductionMockDataSource(),
);

final productionRepositoryProvider = Provider<ProductionRepository>(
  (ref) => ProductionRepository(ref.watch(productionDataSourceProvider)),
);
