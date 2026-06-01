import 'package:dio/dio.dart';

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

/// Production remote data source — calls the FarmTrack REST API via Dio.
class CropRemoteDataSource implements CropDataSource {
  CropRemoteDataSource(this._dio);

  final Dio _dio;

  dynamic _unwrap(dynamic body) =>
      (body is Map<String, dynamic> && body.containsKey('data'))
          ? body['data']
          : body;

  // ── Read ────────────────────────────────────────────────────────────────────

  @override
  Future<List<CropCategory>> getCropCategories() async {
    final res = await _dio.get('/crop/categories');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => CropCategory.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Crop>> getCrops() async {
    final res = await _dio.get('/crop/crops');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => Crop.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CropField>> getCropFields() async {
    final res = await _dio.get('/crop/fields');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => CropField.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CropSeason>> getSeasons() async {
    final res = await _dio.get('/crop/seasons');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => CropSeason.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<PlantingPlan>> getPlantingPlans() async {
    final res = await _dio.get('/crop/planting-plans');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => PlantingPlan.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CalendarEvent>> getCalendarEvents() async {
    final res = await _dio.get('/crop/calendar-events');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => CalendarEvent.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CropTask>> getCropTasks() async {
    final res = await _dio.get('/crop/tasks');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => CropTask.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<WeatherAlert>> getWeatherAlerts() async {
    final res = await _dio.get('/weather/alerts');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => WeatherAlert.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<PestObservation>> getPestObservations() async {
    final res = await _dio.get('/crop/pest-observations');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => PestObservation.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<SprayRecord>> getSprayRecords() async {
    final res = await _dio.get('/crop/spray-records');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => SprayRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CropExpense>> getCropExpenses() async {
    final res = await _dio.get('/crop/expenses');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => CropExpense.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<HarvestRecord>> getCropHarvestRecords() async {
    final res = await _dio.get('/crop/harvest-records');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => HarvestRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CropSale>> getCropSales() async {
    final res = await _dio.get('/crop/sales');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => CropSale.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<AdvisoryContent>> getAdvisoryContent() async {
    final res = await _dio.get('/crop/advisory-content');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => AdvisoryContent.fromJson(j as Map<String, dynamic>)).toList();
  }

  // ── Fields ──────────────────────────────────────────────────────────────────

  @override
  Future<CropField> addField(CropField field) async {
    final res = await _dio.post('/crop/fields', data: field.toJson());
    return CropField.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<CropField> updateField(CropField updated) async {
    final res = await _dio.put('/crop/fields/${updated.id}', data: updated.toJson());
    return CropField.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteField(String id) async {
    await _dio.delete('/crop/fields/$id');
  }

  // ── Seasons ─────────────────────────────────────────────────────────────────

  @override
  Future<CropSeason> addSeason(CropSeason season) async {
    final res = await _dio.post('/crop/seasons', data: season.toJson());
    return CropSeason.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<CropSeason> updateSeason(CropSeason updated) async {
    final res = await _dio.put('/crop/seasons/${updated.id}', data: updated.toJson());
    return CropSeason.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSeason(String id) async {
    await _dio.delete('/crop/seasons/$id');
  }

  // ── Planting Plans ───────────────────────────────────────────────────────────

  @override
  Future<PlantingPlan> addPlantingPlan(PlantingPlan plan) async {
    final res = await _dio.post('/crop/planting-plans', data: plan.toJson());
    return PlantingPlan.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<PlantingPlan> updatePlantingPlan(PlantingPlan updated) async {
    final res = await _dio.put('/crop/planting-plans/${updated.id}', data: updated.toJson());
    return PlantingPlan.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deletePlantingPlan(String id) async {
    await _dio.delete('/crop/planting-plans/$id');
  }

  // ── Tasks ────────────────────────────────────────────────────────────────────

  @override
  Future<CropTask> addTask(CropTask task) async {
    final res = await _dio.post('/crop/tasks', data: task.toJson());
    return CropTask.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<CropTask> updateTask(CropTask updated) async {
    final res = await _dio.put('/crop/tasks/${updated.id}', data: updated.toJson());
    return CropTask.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _dio.delete('/crop/tasks/$id');
  }

  // ── Pest Observations ────────────────────────────────────────────────────────

  @override
  Future<PestObservation> addPestObservation(PestObservation obs) async {
    final res = await _dio.post('/crop/pest-observations', data: obs.toJson());
    return PestObservation.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<PestObservation> updatePestObservation(PestObservation updated) async {
    final res = await _dio.put('/crop/pest-observations/${updated.id}', data: updated.toJson());
    return PestObservation.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deletePestObservation(String id) async {
    await _dio.delete('/crop/pest-observations/$id');
  }

  // ── Spray Records ────────────────────────────────────────────────────────────

  @override
  Future<SprayRecord> addSprayRecord(SprayRecord record) async {
    final res = await _dio.post('/crop/spray-records', data: record.toJson());
    return SprayRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<SprayRecord> updateSprayRecord(SprayRecord updated) async {
    final res = await _dio.put('/crop/spray-records/${updated.id}', data: updated.toJson());
    return SprayRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSprayRecord(String id) async {
    await _dio.delete('/crop/spray-records/$id');
  }

  // ── Expenses ─────────────────────────────────────────────────────────────────

  @override
  Future<CropExpense> addExpense(CropExpense expense) async {
    final res = await _dio.post('/crop/expenses', data: expense.toJson());
    return CropExpense.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<CropExpense> updateExpense(CropExpense updated) async {
    final res = await _dio.put('/crop/expenses/${updated.id}', data: updated.toJson());
    return CropExpense.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _dio.delete('/crop/expenses/$id');
  }

  // ── Harvest ──────────────────────────────────────────────────────────────────

  @override
  Future<HarvestRecord> addHarvestRecord(HarvestRecord record) async {
    final res = await _dio.post('/crop/harvest-records', data: record.toJson());
    return HarvestRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<HarvestRecord> updateHarvestRecord(HarvestRecord updated) async {
    final res = await _dio.put('/crop/harvest-records/${updated.id}', data: updated.toJson());
    return HarvestRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteHarvestRecord(String id) async {
    await _dio.delete('/crop/harvest-records/$id');
  }

  // ── Sales ─────────────────────────────────────────────────────────────────────

  @override
  Future<CropSale> addSale(CropSale sale) async {
    final res = await _dio.post('/crop/sales', data: sale.toJson());
    return CropSale.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<CropSale> updateSale(CropSale updated) async {
    final res = await _dio.put('/crop/sales/${updated.id}', data: updated.toJson());
    return CropSale.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSale(String id) async {
    await _dio.delete('/crop/sales/$id');
  }

  // ── Calendar Events ──────────────────────────────────────────────────────────

  @override
  Future<CalendarEvent> addCalendarEvent(CalendarEvent event) async {
    final res = await _dio.post('/crop/calendar-events', data: event.toJson());
    return CalendarEvent.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<CalendarEvent> updateCalendarEvent(CalendarEvent updated) async {
    final res = await _dio.put('/crop/calendar-events/${updated.id}', data: updated.toJson());
    return CalendarEvent.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteCalendarEvent(String id) async {
    await _dio.delete('/crop/calendar-events/$id');
  }
}
