import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/insights_data_source.dart';
import '../data/insights_mock_data_source.dart';
import '../data/insights_repository.dart';

final insightsDataSourceProvider = Provider<InsightsDataSource>(
  (ref) => InsightsMockDataSource(),
);

final insightsRepositoryProvider = Provider<InsightsRepository>(
  (ref) => InsightsRepository(ref.watch(insightsDataSourceProvider)),
);
