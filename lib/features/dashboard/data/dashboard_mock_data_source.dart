import 'dashboard_data_source.dart';
import '../models/dashboard_summary.dart';

class DashboardMockDataSource implements DashboardDataSource {
  @override
  Future<DashboardSummary> getSummary() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const DashboardSummary(
      farmName: '4Directions Farm',
      farmLocation: 'Limpopo, South Africa',
      pendingTaskCount: 3,
      weatherTemp: '22°C',
      weatherCondition: 'Clear Sky',
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
      recentActivity: [
        ActivityItem(
          type: ActivityType.weight,
          title: 'Weight recorded',
          subtitle: 'Goat #G-007 · 23.4 kg',
          timestamp: '2h ago',
        ),
        ActivityItem(
          type: ActivityType.health,
          title: 'Vaccination complete',
          subtitle: '12 cattle · FMD booster',
          timestamp: '5h ago',
        ),
        ActivityItem(
          type: ActivityType.milk,
          title: 'Milk collected',
          subtitle: '3 cows · 42.3 L total',
          timestamp: '6h ago',
        ),
        ActivityItem(
          type: ActivityType.registration,
          title: 'New animal registered',
          subtitle: 'Bull #B-012 · Holstein · Paddock A',
          timestamp: 'Yesterday',
        ),
        ActivityItem(
          type: ActivityType.breeding,
          title: 'Breeding event logged',
          subtitle: 'Cow #C-014 · Mating recorded',
          timestamp: 'Yesterday',
        ),
      ],
    );
  }
}
