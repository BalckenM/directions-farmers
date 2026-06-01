import 'package:dio/dio.dart';

import '../models/cattle_animal.dart';
import '../models/cattle_records.dart';
import 'cattle_data_source.dart';

/// Production remote data source — calls the FarmTrack REST API via Dio.
/// All responses follow the shape: { "data": [...] } or { "data": {...} }.
class CattleRemoteDataSource implements CattleDataSource {
  CattleRemoteDataSource(this._dio);

  final Dio _dio;

  // ── Helper ─────────────────────────────────────────────────────────────────

  dynamic _unwrap(dynamic body) =>
      (body is Map<String, dynamic> && body.containsKey('data'))
          ? body['data']
          : body;

  // ── Animals ───────────────────────────────────────────────────────────────

  @override
  Future<List<CattleAnimal>> getAnimals() async {
    final res = await _dio.get('/cattle');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => CattleAnimal.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<CattleAnimal> createAnimal(CattleAnimal animal) async {
    final res = await _dio.post('/cattle', data: animal.toJson());
    return CattleAnimal.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<CattleAnimal> updateAnimal(CattleAnimal animal) async {
    final res = await _dio.put('/cattle/${animal.id}', data: animal.toJson());
    return CattleAnimal.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAnimal(String id) async {
    await _dio.delete('/cattle/$id');
  }

  // ── Weight records ────────────────────────────────────────────────────────

  @override
  Future<List<WeightRecord>> getWeightRecords() async {
    final res = await _dio.get('/cattle/weights');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => WeightRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<WeightRecord> createWeightRecord(WeightRecord record) async {
    final res = await _dio.post('/cattle/weights', data: record.toJson());
    return WeightRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteWeightRecord(String id) async {
    await _dio.delete('/cattle/weights/$id');
  }

  // ── Breeding records ──────────────────────────────────────────────────────

  @override
  Future<List<BreedingRecord>> getBreedingRecords() async {
    final res = await _dio.get('/cattle/breeding-records');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => BreedingRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<BreedingRecord> createBreedingRecord(BreedingRecord record) async {
    final res = await _dio.post('/cattle/breeding-records', data: record.toJson());
    return BreedingRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<BreedingRecord> updateBreedingRecord(BreedingRecord record) async {
    final res = await _dio.put('/cattle/breeding-records/${record.id}', data: record.toJson());
    return BreedingRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── Pregnancy checks ──────────────────────────────────────────────────────

  @override
  Future<List<PregnancyCheck>> getPregnancyChecks() async {
    final res = await _dio.get('/cattle/pregnancy-checks');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => PregnancyCheck.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<PregnancyCheck> createPregnancyCheck(PregnancyCheck check) async {
    final res = await _dio.post('/cattle/pregnancy-checks', data: check.toJson());
    return PregnancyCheck.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── Calving events ────────────────────────────────────────────────────────

  @override
  Future<List<CalvingEvent>> getCalvingEvents() async {
    final res = await _dio.get('/cattle/calving-events');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => CalvingEvent.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<CalvingEvent> createCalvingEvent(CalvingEvent event) async {
    final res = await _dio.post('/cattle/calving-events', data: event.toJson());
    return CalvingEvent.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── Milk records ──────────────────────────────────────────────────────────

  @override
  Future<List<DailyMilkRecord>> getMilkRecords() async {
    final res = await _dio.get('/cattle/milk');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => DailyMilkRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<DailyMilkRecord> createMilkRecord(DailyMilkRecord record) async {
    final res = await _dio.post('/cattle/milk', data: record.toJson());
    return DailyMilkRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteMilkRecord(String id) async {
    await _dio.delete('/cattle/milk/$id');
  }

  // ── Health events ─────────────────────────────────────────────────────────

  @override
  Future<List<CattleHealthEvent>> getHealthEvents() async {
    final res = await _dio.get('/cattle/health');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => CattleHealthEvent.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<CattleHealthEvent> createHealthEvent(CattleHealthEvent event) async {
    final res = await _dio.post('/cattle/health', data: event.toJson());
    return CattleHealthEvent.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<CattleHealthEvent> updateHealthEvent(CattleHealthEvent event) async {
    final res = await _dio.put('/cattle/health/${event.id}', data: event.toJson());
    return CattleHealthEvent.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── Medication logs ───────────────────────────────────────────────────────

  @override
  Future<List<CattleMedicationLog>> getMedicationLogs() async {
    final res = await _dio.get('/cattle/medications');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => CattleMedicationLog.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<CattleMedicationLog> createMedicationLog(CattleMedicationLog log) async {
    final res = await _dio.post('/cattle/medications', data: log.toJson());
    return CattleMedicationLog.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── Vaccinations ──────────────────────────────────────────────────────────

  @override
  Future<List<CattleVaccination>> getVaccinations() async {
    final res = await _dio.get('/cattle/vaccinations');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => CattleVaccination.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<CattleVaccination> createVaccination(CattleVaccination vaccination) async {
    final res = await _dio.post('/cattle/vaccinations', data: vaccination.toJson());
    return CattleVaccination.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<CattleVaccination> markVaccinationGiven(
    String id,
    String givenDate, {
    String? batchNumber,
  }) async {
    final res = await _dio.patch(
      '/cattle/vaccinations/$id/given',
      data: {
        'givenDate': givenDate,
        if (batchNumber != null) 'batchNumber': batchNumber,
      },
    );
    return CattleVaccination.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── Sale records ──────────────────────────────────────────────────────────

  @override
  Future<List<CattleSaleRecord>> getSaleRecords() async {
    final res = await _dio.get('/cattle/sales');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => CattleSaleRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<CattleSaleRecord> createSaleRecord(CattleSaleRecord record) async {
    final res = await _dio.post('/cattle/sales', data: record.toJson());
    return CattleSaleRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<CattleSaleRecord> updateSaleRecord(CattleSaleRecord record) async {
    final res = await _dio.put('/cattle/sales/${record.id}', data: record.toJson());
    return CattleSaleRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSaleRecord(String id) async {
    await _dio.delete('/cattle/sales/$id');
  }

  // ── Feed records ──────────────────────────────────────────────────────────

  @override
  Future<List<CattleFeedRecord>> getFeedRecords() async {
    final res = await _dio.get('/cattle/feed');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => CattleFeedRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<CattleFeedRecord> createFeedRecord(CattleFeedRecord record) async {
    final res = await _dio.post('/cattle/feed', data: record.toJson());
    return CattleFeedRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteFeedRecord(String id) async {
    await _dio.delete('/cattle/feed/$id');
  }

  // ── Pasture records ───────────────────────────────────────────────────────

  @override
  Future<List<PastureRecord>> getPastureRecords() async {
    final res = await _dio.get('/cattle/pasture');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => PastureRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<PastureRecord> createPastureRecord(PastureRecord record) async {
    final res = await _dio.post('/cattle/pasture', data: record.toJson());
    return PastureRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<PastureRecord> exitPasture(String id, String exitDate) async {
    final res = await _dio.patch(
      '/cattle/pasture/$id/exit',
      data: {'exitDate': exitDate},
    );
    return PastureRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── Body condition records ────────────────────────────────────────────────

  @override
  Future<List<BodyConditionRecord>> getBodyConditionRecords() async {
    final res = await _dio.get('/cattle/bcs');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => BodyConditionRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<BodyConditionRecord> createBodyConditionRecord(
      BodyConditionRecord record) async {
    final res = await _dio.post('/cattle/bcs', data: record.toJson());
    return BodyConditionRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── Dipping records ───────────────────────────────────────────────────────

  @override
  Future<List<DippingRecord>> getDippingRecords() async {
    final res = await _dio.get('/cattle/dipping');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => DippingRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<DippingRecord> createDippingRecord(DippingRecord record) async {
    final res = await _dio.post('/cattle/dipping', data: record.toJson());
    return DippingRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }
}
