import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
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
import 'crop_data_source.dart';
import 'crop_mock_data_source.dart';
import 'crop_remote_data_source.dart';

class CropRepository {
  CropRepository(this._source);

  final CropDataSource _source;

  // ── In-memory mutable caches ─────────────────────────────────────────────────
  // Loaded lazily on first read. Write operations mutate these lists directly.

  List<CropCategory>? _categories;
  List<Crop>? _crops;
  List<CropField>? _fields;
  List<CropSeason>? _seasons;
  List<PlantingPlan>? _plans;
  List<CalendarEvent>? _events;
  List<CropTask>? _tasks;
  List<WeatherAlert>? _alerts;
  List<PestObservation>? _pests;
  List<SprayRecord>? _sprays;
  List<CropExpense>? _expenses;
  List<HarvestRecord>? _harvests;
  List<CropSale>? _sales;
  List<AdvisoryContent>? _advisory;

  // ── Crop Catalog ─────────────────────────────────────────────────────────────

  Future<List<CropCategory>> getCropCategories() async {
    if (_categories != null) return List.unmodifiable(_categories!);
    _categories = List<CropCategory>.from(await _source.getCropCategories());
    return List.unmodifiable(_categories!);
  }

  Future<List<Crop>> getCrops({String? categoryId}) async {
    _crops ??= List<Crop>.from(await _source.getCrops());
    final all = List<Crop>.unmodifiable(_crops!);
    if (categoryId == null) return all;
    return all.where((c) => c.categoryId == categoryId).toList();
  }

  Future<Crop?> getCropById(String id) async {
    final crops = await getCrops();
    try {
      return crops.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Fields ───────────────────────────────────────────────────────────────────

  Future<List<CropField>> getFields({String? farmId}) async {
    _fields ??= List<CropField>.from(await _source.getCropFields());
    final all = _fields!;
    if (farmId == null) return List.unmodifiable(all);
    return all.where((f) => f.farmId == farmId).toList();
  }

  Future<CropField?> getFieldById(String id) async {
    final fields = await getFields();
    try {
      return fields.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<CropField> addField(CropField field) async {
    await getFields(); // ensure loaded
    _fields!.add(field);
    return field;
  }

  Future<CropField> updateField(CropField updated) async {
    await getFields();
    final idx = _fields!.indexWhere((f) => f.id == updated.id);
    if (idx >= 0) _fields![idx] = updated;
    return updated;
  }

  Future<void> deleteField(String id) async {
    await getFields();
    _fields!.removeWhere((f) => f.id == id);
  }

  // ── Seasons ──────────────────────────────────────────────────────────────────

  Future<List<CropSeason>> getSeasons({String? farmId}) async {
    _seasons ??= List<CropSeason>.from(await _source.getSeasons());
    final all = _seasons!;
    if (farmId == null) return List.unmodifiable(all);
    return all.where((s) => s.farmId == farmId).toList();
  }

  Future<CropSeason> addSeason(CropSeason season) async {
    await getSeasons();
    _seasons!.add(season);
    return season;
  }

  Future<CropSeason> updateSeason(CropSeason updated) async {
    await getSeasons();
    final idx = _seasons!.indexWhere((s) => s.id == updated.id);
    if (idx >= 0) _seasons![idx] = updated;
    return updated;
  }

  Future<void> deleteSeason(String id) async {
    await getSeasons();
    _seasons!.removeWhere((s) => s.id == id);
  }

  // ── Planting Plans ────────────────────────────────────────────────────────────

  Future<List<PlantingPlan>> getPlantingPlans({
    String? fieldId,
    String? seasonId,
  }) async {
    _plans ??= List<PlantingPlan>.from(await _source.getPlantingPlans());
    var all = List<PlantingPlan>.from(_plans!);
    if (fieldId != null) all = all.where((p) => p.fieldId == fieldId).toList();
    if (seasonId != null) all = all.where((p) => p.seasonId == seasonId).toList();
    return all;
  }

  Future<PlantingPlan?> getPlanById(String id) async {
    final plans = await getPlantingPlans();
    try {
      return plans.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<PlantingPlan> addPlantingPlan(PlantingPlan plan) async {
    await getPlantingPlans();
    _plans!.add(plan);
    return plan;
  }

  Future<PlantingPlan> updatePlantingPlan(PlantingPlan updated) async {
    await getPlantingPlans();
    final idx = _plans!.indexWhere((p) => p.id == updated.id);
    if (idx >= 0) _plans![idx] = updated;
    return updated;
  }

  Future<void> deletePlantingPlan(String id) async {
    await getPlantingPlans();
    _plans!.removeWhere((p) => p.id == id);
  }

  // ── Calendar Events ───────────────────────────────────────────────────────────

  Future<List<CalendarEvent>> getCalendarEvents({
    String? planId,
    String? fieldId,
  }) async {
    _events ??= List<CalendarEvent>.from(await _source.getCalendarEvents());
    var all = List<CalendarEvent>.from(_events!);
    if (planId != null) all = all.where((e) => e.planId == planId).toList();
    if (fieldId != null) all = all.where((e) => e.fieldId == fieldId).toList();
    all.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return all;
  }

  Future<CalendarEvent> updateCalendarEvent(CalendarEvent updated) async {
    await getCalendarEvents();
    final idx = _events!.indexWhere((e) => e.id == updated.id);
    if (idx >= 0) _events![idx] = updated;
    return updated;
  }

  // ── Tasks ─────────────────────────────────────────────────────────────────────

  Future<List<CropTask>> getTasks({String? farmId, String? fieldId}) async {
    _tasks ??= List<CropTask>.from(await _source.getCropTasks());
    var all = List<CropTask>.from(_tasks!);
    if (farmId != null) all = all.where((t) => t.farmId == farmId).toList();
    if (fieldId != null) all = all.where((t) => t.fieldId == fieldId).toList();
    all.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return all;
  }

  Future<CropTask?> getTaskById(String id) async {
    final tasks = await getTasks();
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<CropTask> addTask(CropTask task) async {
    await getTasks();
    _tasks!.add(task);
    return task;
  }

  Future<CropTask> updateTask(CropTask updated) async {
    await getTasks();
    final idx = _tasks!.indexWhere((t) => t.id == updated.id);
    if (idx >= 0) _tasks![idx] = updated;
    return updated;
  }

  Future<void> deleteTask(String id) async {
    await getTasks();
    _tasks!.removeWhere((t) => t.id == id);
  }

  // ── Weather Alerts ────────────────────────────────────────────────────────────

  Future<List<WeatherAlert>> getWeatherAlerts({String? farmId}) async {
    _alerts ??= List<WeatherAlert>.from(await _source.getWeatherAlerts());
    var all = List<WeatherAlert>.from(_alerts!);
    if (farmId != null) all = all.where((a) => a.farmId == farmId).toList();
    return all;
  }

  // ── Pest Observations ─────────────────────────────────────────────────────────

  Future<List<PestObservation>> getPestObservations({String? fieldId}) async {
    _pests ??= List<PestObservation>.from(await _source.getPestObservations());
    var all = List<PestObservation>.from(_pests!);
    if (fieldId != null) all = all.where((p) => p.fieldId == fieldId).toList();
    all.sort((a, b) => b.observedDate.compareTo(a.observedDate));
    return all;
  }

  Future<PestObservation> addPestObservation(PestObservation obs) async {
    await getPestObservations();
    _pests!.add(obs);
    return obs;
  }

  Future<PestObservation> updatePestObservation(PestObservation updated) async {
    await getPestObservations();
    final idx = _pests!.indexWhere((p) => p.id == updated.id);
    if (idx >= 0) _pests![idx] = updated;
    return updated;
  }

  Future<void> deletePestObservation(String id) async {
    await getPestObservations();
    _pests!.removeWhere((p) => p.id == id);
  }

  // ── Spray Records ─────────────────────────────────────────────────────────────

  Future<List<SprayRecord>> getSprayRecords({String? fieldId}) async {
    _sprays ??= List<SprayRecord>.from(await _source.getSprayRecords());
    var all = List<SprayRecord>.from(_sprays!);
    if (fieldId != null) all = all.where((s) => s.fieldId == fieldId).toList();
    all.sort((a, b) => b.sprayDate.compareTo(a.sprayDate));
    return all;
  }

  Future<SprayRecord> addSprayRecord(SprayRecord record) async {
    await getSprayRecords();
    _sprays!.add(record);
    return record;
  }

  Future<SprayRecord> updateSprayRecord(SprayRecord updated) async {
    await getSprayRecords();
    final idx = _sprays!.indexWhere((s) => s.id == updated.id);
    if (idx >= 0) _sprays![idx] = updated;
    return updated;
  }

  Future<void> deleteSprayRecord(String id) async {
    await getSprayRecords();
    _sprays!.removeWhere((s) => s.id == id);
  }

  // ── Expenses ──────────────────────────────────────────────────────────────────

  Future<List<CropExpense>> getExpenses({
    String? farmId,
    String? fieldId,
    String? planId,
  }) async {
    _expenses ??= List<CropExpense>.from(await _source.getCropExpenses());
    var all = List<CropExpense>.from(_expenses!);
    if (farmId != null) all = all.where((e) => e.farmId == farmId).toList();
    if (fieldId != null) all = all.where((e) => e.fieldId == fieldId).toList();
    if (planId != null) all = all.where((e) => e.planId == planId).toList();
    all.sort((a, b) => b.date.compareTo(a.date));
    return all;
  }

  Future<CropExpense> addExpense(CropExpense expense) async {
    await getExpenses();
    _expenses!.add(expense);
    return expense;
  }

  Future<CropExpense> updateExpense(CropExpense updated) async {
    await getExpenses();
    final idx = _expenses!.indexWhere((e) => e.id == updated.id);
    if (idx >= 0) _expenses![idx] = updated;
    return updated;
  }

  Future<void> deleteExpense(String id) async {
    await getExpenses();
    _expenses!.removeWhere((e) => e.id == id);
  }

  // ── Harvest ───────────────────────────────────────────────────────────────────

  Future<List<HarvestRecord>> getHarvestRecords({String? fieldId}) async {
    _harvests ??= List<HarvestRecord>.from(await _source.getCropHarvestRecords());
    var all = List<HarvestRecord>.from(_harvests!);
    if (fieldId != null) all = all.where((h) => h.fieldId == fieldId).toList();
    all.sort((a, b) => b.harvestDate.compareTo(a.harvestDate));
    return all;
  }

  Future<HarvestRecord> addHarvestRecord(HarvestRecord record) async {
    await getHarvestRecords();
    _harvests!.add(record);
    return record;
  }

  Future<HarvestRecord> updateHarvestRecord(HarvestRecord updated) async {
    await getHarvestRecords();
    final idx = _harvests!.indexWhere((h) => h.id == updated.id);
    if (idx >= 0) _harvests![idx] = updated;
    return updated;
  }

  Future<void> deleteHarvestRecord(String id) async {
    await getHarvestRecords();
    _harvests!.removeWhere((h) => h.id == id);
  }

  // ── Sales ─────────────────────────────────────────────────────────────────────

  Future<List<CropSale>> getSales({String? farmId}) async {
    _sales ??= List<CropSale>.from(await _source.getCropSales());
    var all = List<CropSale>.from(_sales!);
    if (farmId != null) all = all.where((s) => s.farmId == farmId).toList();
    all.sort((a, b) => b.saleDate.compareTo(a.saleDate));
    return all;
  }

  Future<CropSale> addSale(CropSale sale) async {
    await getSales();
    _sales!.add(sale);
    return sale;
  }

  Future<CropSale> updateSale(CropSale updated) async {
    await getSales();
    final idx = _sales!.indexWhere((s) => s.id == updated.id);
    if (idx >= 0) _sales![idx] = updated;
    return updated;
  }

  Future<void> deleteSale(String id) async {
    await getSales();
    _sales!.removeWhere((s) => s.id == id);
  }

  // ── Advisory ─────────────────────────────────────────────────────────────────

  Future<List<AdvisoryContent>> getAdvisoryContent({
    String? cropId,
    String? category,
  }) async {
    _advisory ??= List<AdvisoryContent>.from(await _source.getAdvisoryContent());
    var all = List<AdvisoryContent>.from(_advisory!);
    if (cropId != null) all = all.where((a) => a.cropId == cropId).toList();
    if (category != null) all = all.where((a) => a.category == category).toList();
    all.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return all;
  }
}

final cropRepositoryProvider = Provider<CropRepository>((ref) {
  final source = AppConstants.useMockData
      ? CropMockDataSource()
      : CropRemoteDataSource();
  return CropRepository(source);
});
