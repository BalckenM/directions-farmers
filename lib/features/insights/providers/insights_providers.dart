import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/insights/data/insights_data_source.dart';
import 'package:mobile_app/features/insights/data/insights_remote_data_source.dart';
import 'package:mobile_app/features/insights/data/insights_repository.dart';

final insightsDataSourceProvider = Provider<InsightsDataSource>(
  (ref) => InsightsRemoteDataSource(ref.read(apiDioProvider)),
);

final insightsRepositoryProvider = Provider<InsightsRepository>(
  (ref) => InsightsRepository(ref.watch(insightsDataSourceProvider)),
);
