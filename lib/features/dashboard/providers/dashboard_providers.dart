import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/dashboard_data_source.dart';
import '../data/dashboard_remote_data_source.dart';
import '../data/dashboard_repository.dart';
import '../models/dashboard_summary.dart';

final dashboardDataSourceProvider = Provider<DashboardDataSource>(
  (ref) => DashboardRemoteDataSource(ref.read(apiDioProvider)),
);

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(ref.watch(dashboardDataSourceProvider)),
);

/// Async provider that fetches and caches the dashboard summary.
final dashboardSummaryProvider =
    FutureProvider.autoDispose<DashboardSummary>((ref) {
  return ref.watch(dashboardRepositoryProvider).getSummary();
});
