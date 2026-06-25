import 'dashboard_data_source.dart';
import '../models/dashboard_summary.dart';

// Stub — dashboard module not yet active. No HTTP calls are made.
class DashboardRemoteDataSource implements DashboardDataSource {
  DashboardRemoteDataSource(dynamic _);

  @override Future<DashboardSummary> getSummary() async => const DashboardSummary(
    farmName: '',
    farmLocation: '',
    speciesSummaries: [],
    totalAnimals: 0,
    recentHealthAlerts: 0,
    recentBreedingEvents: 0,
  );
}
