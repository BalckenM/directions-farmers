import 'package:mobile_app/features/dashboard/models/dashboard_summary.dart';
import 'package:mobile_app/features/dashboard/data/dashboard_data_source.dart';

/// Aggregates data into a [DashboardSummary].
class DashboardRepository {
  DashboardRepository(this._source);

  final DashboardDataSource _source;

  Future<DashboardSummary> getSummary() => _source.getSummary();
}
