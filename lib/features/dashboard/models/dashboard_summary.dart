/// Aggregated data for the dashboard overview.
class DashboardSummary {
  const DashboardSummary({
    required this.farmName,
    required this.farmLocation,
    required this.speciesSummaries,
    required this.totalAnimals,
    required this.recentHealthAlerts,
    required this.recentBreedingEvents,
  });

  final String farmName;
  final String farmLocation;
  final List<SpeciesSummary> speciesSummaries;
  final int totalAnimals;
  final int recentHealthAlerts;
  final int recentBreedingEvents;

  int get speciesCount => speciesSummaries.length;
}

class SpeciesSummary {
  const SpeciesSummary({
    required this.species,
    required this.headCount,
    required this.activeCount,
    required this.alertCount,
  });

  final String species;
  final int headCount;
  final int activeCount;
  final int alertCount;
}
