import 'poultry_data_source.dart';
import '../models/poultry_flock.dart';
import '../models/flock.dart';
import '../models/inventory_item.dart';

class PoultryRemoteDataSource implements PoultryDataSource {
  @override
  Future<List<PoultryFlock>> getFlocks() =>
      throw UnimplementedError('getFlocks not implemented');

  @override
  Future<List<DailyRecord>> getDailyRecords() =>
      throw UnimplementedError('getDailyRecords not implemented');

  @override
  Future<List<VaccinationSchedule>> getVaccinationSchedules() =>
      throw UnimplementedError('getVaccinationSchedules not implemented');

  @override
  Future<List<FeedPhase>> getFeedPhases() =>
      throw UnimplementedError('getFeedPhases not implemented');

  @override
  Future<List<HarvestRecord>> getHarvestRecords() =>
      throw UnimplementedError('getHarvestRecords not implemented');

  @override
  Future<List<MedicationLog>> getMedicationLogs() =>
      throw UnimplementedError('getMedicationLogs not implemented');

  @override
  Future<List<DiseaseEvent>> getDiseaseEvents() =>
      throw UnimplementedError('getDiseaseEvents not implemented');

  @override
  Future<List<EnvironmentReading>> getEnvironmentReadings() =>
      throw UnimplementedError('getEnvironmentReadings not implemented');

  @override
  Future<List<InventoryItem>> getInventoryItems() =>
      throw UnimplementedError('getInventoryItems not implemented');

  @override
  Future<List<EggSale>> getEggSales() =>
      throw UnimplementedError('getEggSales not implemented');

  @override
  Future<List<ChickSale>> getChickSales() =>
      throw UnimplementedError('getChickSales not implemented');
}
