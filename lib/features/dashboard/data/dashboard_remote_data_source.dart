import 'dashboard_data_source.dart';
import '../models/dashboard_summary.dart';

class DashboardRemoteDataSource implements DashboardDataSource {
  @override
  Future<DashboardSummary> getSummary() =>
      throw UnimplementedError('getSummary not implemented');
}
