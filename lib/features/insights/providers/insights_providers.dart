import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/insights_data_source.dart';
import '../data/insights_remote_data_source.dart';
import '../data/insights_repository.dart';

final insightsDataSourceProvider = Provider<InsightsDataSource>(
  (ref) => InsightsRemoteDataSource(ref.read(apiDioProvider)),
);

final insightsRepositoryProvider = Provider<InsightsRepository>(
  (ref) => InsightsRepository(ref.watch(insightsDataSourceProvider)),
);
