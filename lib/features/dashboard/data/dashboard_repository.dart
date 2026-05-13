import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../models/dashboard_summary.dart';
import 'dashboard_data_source.dart';
import 'dashboard_mock_data_source.dart';
import 'dashboard_remote_data_source.dart';

/// Aggregates data into a [DashboardSummary].
class DashboardRepository {
  DashboardRepository(this._source);

  final DashboardDataSource _source;

  Future<DashboardSummary> getSummary() => _source.getSummary();
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final source = AppConstants.useMockData
      ? DashboardMockDataSource()
      : DashboardRemoteDataSource();
  return DashboardRepository(source);
});
