import 'dashboard_data_source.dart';
import '../models/dashboard_summary.dart';

class DashboardMockDataSource implements DashboardDataSource {
  @override
  Future<DashboardSummary> getSummary() async => const DashboardSummary(
        farmName: 'Green Acres Farm',
        farmLocation: 'Limpopo, South Africa',
        speciesSummaries: [
          SpeciesSummary(
            species: 'cattle',
            headCount: 142,
            activeCount: 138,
            alertCount: 2,
          ),
          SpeciesSummary(
            species: 'goats',
            headCount: 87,
            activeCount: 85,
            alertCount: 1,
          ),
          SpeciesSummary(
            species: 'sheep',
            headCount: 210,
            activeCount: 207,
            alertCount: 0,
          ),
          SpeciesSummary(
            species: 'pigs',
            headCount: 34,
            activeCount: 32,
            alertCount: 1,
          ),
          SpeciesSummary(
            species: 'poultry',
            headCount: 4920,
            activeCount: 4920,
            alertCount: 0,
          ),
          SpeciesSummary(
            species: 'horses',
            headCount: 6,
            activeCount: 6,
            alertCount: 0,
          ),
        ],
        totalAnimals: 5399,
        recentHealthAlerts: 4,
        recentBreedingEvents: 8,
      );
}
