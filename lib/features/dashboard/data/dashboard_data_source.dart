import 'package:mobile_app/features/dashboard/models/dashboard_summary.dart';

abstract class DashboardDataSource {
  Future<DashboardSummary> getSummary();
}
