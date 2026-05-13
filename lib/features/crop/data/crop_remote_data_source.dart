import 'crop_data_source.dart';
import '../models/advisory_content.dart';
import '../models/calendar_event.dart';
import '../models/crop.dart';
import '../models/crop_category.dart';
import '../models/crop_expense.dart';
import '../models/crop_field.dart';
import '../models/crop_sale.dart';
import '../models/crop_season.dart';
import '../models/crop_task.dart';
import '../models/harvest_record.dart';
import '../models/pest_observation.dart';
import '../models/planting_plan.dart';
import '../models/spray_record.dart';
import '../models/weather_alert.dart';

class CropRemoteDataSource implements CropDataSource {
  @override
  Future<List<CropCategory>> getCropCategories() =>
      throw UnimplementedError('getCropCategories not implemented');

  @override
  Future<List<Crop>> getCrops() =>
      throw UnimplementedError('getCrops not implemented');

  @override
  Future<List<CropField>> getCropFields() =>
      throw UnimplementedError('getCropFields not implemented');

  @override
  Future<List<CropSeason>> getSeasons() =>
      throw UnimplementedError('getSeasons not implemented');

  @override
  Future<List<PlantingPlan>> getPlantingPlans() =>
      throw UnimplementedError('getPlantingPlans not implemented');

  @override
  Future<List<CalendarEvent>> getCalendarEvents() =>
      throw UnimplementedError('getCalendarEvents not implemented');

  @override
  Future<List<CropTask>> getCropTasks() =>
      throw UnimplementedError('getCropTasks not implemented');

  @override
  Future<List<WeatherAlert>> getWeatherAlerts() =>
      throw UnimplementedError('getWeatherAlerts not implemented');

  @override
  Future<List<PestObservation>> getPestObservations() =>
      throw UnimplementedError('getPestObservations not implemented');

  @override
  Future<List<SprayRecord>> getSprayRecords() =>
      throw UnimplementedError('getSprayRecords not implemented');

  @override
  Future<List<CropExpense>> getCropExpenses() =>
      throw UnimplementedError('getCropExpenses not implemented');

  @override
  Future<List<HarvestRecord>> getCropHarvestRecords() =>
      throw UnimplementedError('getCropHarvestRecords not implemented');

  @override
  Future<List<CropSale>> getCropSales() =>
      throw UnimplementedError('getCropSales not implemented');

  @override
  Future<List<AdvisoryContent>> getAdvisoryContent() =>
      throw UnimplementedError('getAdvisoryContent not implemented');

  // ── Fields ──────────────────────────────────────────────────────────────────
  @override Future<CropField> addField(CropField f) => throw UnimplementedError();
  @override Future<CropField> updateField(CropField f) => throw UnimplementedError();
  @override Future<void> deleteField(String id) => throw UnimplementedError();

  // ── Seasons ─────────────────────────────────────────────────────────────────
  @override Future<CropSeason> addSeason(CropSeason s) => throw UnimplementedError();
  @override Future<CropSeason> updateSeason(CropSeason s) => throw UnimplementedError();
  @override Future<void> deleteSeason(String id) => throw UnimplementedError();

  // ── Planting Plans ───────────────────────────────────────────────────────────
  @override Future<PlantingPlan> addPlantingPlan(PlantingPlan p) => throw UnimplementedError();
  @override Future<PlantingPlan> updatePlantingPlan(PlantingPlan p) => throw UnimplementedError();
  @override Future<void> deletePlantingPlan(String id) => throw UnimplementedError();

  // ── Tasks ────────────────────────────────────────────────────────────────────
  @override Future<CropTask> addTask(CropTask t) => throw UnimplementedError();
  @override Future<CropTask> updateTask(CropTask t) => throw UnimplementedError();
  @override Future<void> deleteTask(String id) => throw UnimplementedError();

  // ── Pest Observations ────────────────────────────────────────────────────────
  @override Future<PestObservation> addPestObservation(PestObservation o) => throw UnimplementedError();
  @override Future<PestObservation> updatePestObservation(PestObservation o) => throw UnimplementedError();
  @override Future<void> deletePestObservation(String id) => throw UnimplementedError();

  // ── Spray Records ────────────────────────────────────────────────────────────
  @override Future<SprayRecord> addSprayRecord(SprayRecord r) => throw UnimplementedError();
  @override Future<SprayRecord> updateSprayRecord(SprayRecord r) => throw UnimplementedError();
  @override Future<void> deleteSprayRecord(String id) => throw UnimplementedError();

  // ── Expenses ─────────────────────────────────────────────────────────────────
  @override Future<CropExpense> addExpense(CropExpense e) => throw UnimplementedError();
  @override Future<CropExpense> updateExpense(CropExpense e) => throw UnimplementedError();
  @override Future<void> deleteExpense(String id) => throw UnimplementedError();

  // ── Harvest ──────────────────────────────────────────────────────────────────
  @override Future<HarvestRecord> addHarvestRecord(HarvestRecord r) => throw UnimplementedError();
  @override Future<HarvestRecord> updateHarvestRecord(HarvestRecord r) => throw UnimplementedError();
  @override Future<void> deleteHarvestRecord(String id) => throw UnimplementedError();

  // ── Sales ─────────────────────────────────────────────────────────────────────
  @override Future<CropSale> addSale(CropSale s) => throw UnimplementedError();
  @override Future<CropSale> updateSale(CropSale s) => throw UnimplementedError();
  @override Future<void> deleteSale(String id) => throw UnimplementedError();
}
