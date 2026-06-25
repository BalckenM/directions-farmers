import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/dashboard/data/dashboard_data_source.dart';
import 'package:mobile_app/features/dashboard/data/dashboard_remote_data_source.dart';
import 'package:mobile_app/features/dashboard/data/dashboard_repository.dart';
import 'package:mobile_app/features/dashboard/models/dashboard_summary.dart';

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
