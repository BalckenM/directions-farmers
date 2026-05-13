import '../models/dashboard_summary.dart';

abstract class DashboardDataSource {
  Future<DashboardSummary> getSummary();
}
