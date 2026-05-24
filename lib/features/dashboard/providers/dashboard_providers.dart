import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_data_source.dart';
import '../data/dashboard_mock_data_source.dart';
import '../data/dashboard_repository.dart';
import '../models/dashboard_summary.dart';

final dashboardDataSourceProvider = Provider<DashboardDataSource>(
  (ref) => DashboardMockDataSource(),
);

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(ref.watch(dashboardDataSourceProvider)),
);

/// Async provider that fetches and caches the dashboard summary.
final dashboardSummaryProvider =
    FutureProvider.autoDispose<DashboardSummary>((ref) {
  return ref.watch(dashboardRepositoryProvider).getSummary();
});
