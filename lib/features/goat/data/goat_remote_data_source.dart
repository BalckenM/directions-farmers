import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../models/goat_animal.dart';
import '../models/goat_records.dart';
import 'goat_data_source.dart';

/// Production remote data source — calls the FarmTrack REST API via Dio.
/// All responses follow the shape: { "data": [...] } or { "data": {...} }.
class GoatRemoteDataSource implements GoatDataSource {
  GoatRemoteDataSource() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false),
    );
  }

  late final Dio _dio;

  // ── Helper ─────────────────────────────────────────────────────────────────

  /// Unwraps `{ "data": value }` envelope, falls back to raw value.
  dynamic _unwrap(dynamic body) =>
      (body is Map<String, dynamic> && body.containsKey('data'))
          ? body['data']
          : body;

  // ── Animals ───────────────────────────────────────────────────────────────

  @override
  Future<List<GoatAnimal>> getAnimals() async {
    final res = await _dio.get('/goats');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => GoatAnimal.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<GoatAnimal> createAnimal(GoatAnimal animal) async {
    final res = await _dio.post('/goats', data: animal.toJson());
    return GoatAnimal.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<GoatAnimal> updateAnimal(GoatAnimal animal) async {
    final res = await _dio.put('/goats/${animal.id}', data: animal.toJson());
    return GoatAnimal.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAnimal(String id) async {
    await _dio.delete('/goats/$id');
  }

  // ── Weight records ────────────────────────────────────────────────────────

  @override
  Future<List<WeightRecord>> getWeightRecords() async {
    final res = await _dio.get('/goats/weights');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => WeightRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<WeightRecord> createWeightRecord(WeightRecord record) async {
    final res = await _dio.post('/goats/weights', data: record.toJson());
    return WeightRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteWeightRecord(String id) async {
    await _dio.delete('/goats/weights/$id');
  }

  // ── Mating records ────────────────────────────────────────────────────────

  @override
  Future<List<MatingRecord>> getMatingRecords() async {
    final res = await _dio.get('/goats/matings');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => MatingRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<MatingRecord> createMatingRecord(MatingRecord record) async {
    final res = await _dio.post('/goats/matings', data: record.toJson());
    return MatingRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<MatingRecord> updateMatingRecord(MatingRecord record) async {
    final res = await _dio.put('/goats/matings/${record.id}', data: record.toJson());
    return MatingRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── Pregnancy checks ──────────────────────────────────────────────────────

  @override
  Future<List<PregnancyCheck>> getPregnancyChecks() async {
    final res = await _dio.get('/goats/pregnancy-checks');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => PregnancyCheck.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<PregnancyCheck> createPregnancyCheck(PregnancyCheck check) async {
    final res = await _dio.post('/goats/pregnancy-checks', data: check.toJson());
    return PregnancyCheck.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── Kidding events ────────────────────────────────────────────────────────

  @override
  Future<List<KiddingEvent>> getKiddingEvents() async {
    final res = await _dio.get('/goats/kidding');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => KiddingEvent.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<KiddingEvent> createKiddingEvent(KiddingEvent event) async {
    final res = await _dio.post('/goats/kidding', data: event.toJson());
    return KiddingEvent.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── Milk records ──────────────────────────────────────────────────────────

  @override
  Future<List<DailyMilkRecord>> getMilkRecords() async {
    final res = await _dio.get('/goats/milk');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => DailyMilkRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<DailyMilkRecord> createMilkRecord(DailyMilkRecord record) async {
    final res = await _dio.post('/goats/milk', data: record.toJson());
    return DailyMilkRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteMilkRecord(String id) async {
    await _dio.delete('/goats/milk/$id');
  }

  // ── Shearing records ──────────────────────────────────────────────────────

  @override
  Future<List<ShearingRecord>> getShearingRecords() async {
    final res = await _dio.get('/goats/shearing');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => ShearingRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<ShearingRecord> createShearingRecord(ShearingRecord record) async {
    final res = await _dio.post('/goats/shearing', data: record.toJson());
    return ShearingRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── Health events ─────────────────────────────────────────────────────────

  @override
  Future<List<GoatHealthEvent>> getHealthEvents() async {
    final res = await _dio.get('/goats/health');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => GoatHealthEvent.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<GoatHealthEvent> createHealthEvent(GoatHealthEvent event) async {
    final res = await _dio.post('/goats/health', data: event.toJson());
    return GoatHealthEvent.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<GoatHealthEvent> updateHealthEvent(GoatHealthEvent event) async {
    final res = await _dio.put('/goats/health/${event.id}', data: event.toJson());
    return GoatHealthEvent.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── Medication logs ───────────────────────────────────────────────────────

  @override
  Future<List<GoatMedicationLog>> getMedicationLogs() async {
    final res = await _dio.get('/goats/medications');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => GoatMedicationLog.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<GoatMedicationLog> createMedicationLog(GoatMedicationLog log) async {
    final res = await _dio.post('/goats/medications', data: log.toJson());
    return GoatMedicationLog.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── Vaccinations ──────────────────────────────────────────────────────────

  @override
  Future<List<GoatVaccination>> getVaccinations() async {
    final res = await _dio.get('/goats/vaccinations');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => GoatVaccination.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<GoatVaccination> createVaccination(GoatVaccination vaccination) async {
    final res = await _dio.post('/goats/vaccinations', data: vaccination.toJson());
    return GoatVaccination.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<GoatVaccination> markVaccinationGiven(
    String id,
    String givenDate, {
    String? batchNumber,
  }) async {
    final res = await _dio.patch(
      '/goats/vaccinations/$id/given',
      data: {
        'givenDate': givenDate,
        if (batchNumber != null) 'batchNumber': batchNumber,
      },
    );
    return GoatVaccination.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── Sale records ──────────────────────────────────────────────────────────

  @override
  Future<List<GoatSaleRecord>> getSaleRecords() async {
    final res = await _dio.get('/goats/sales');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => GoatSaleRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<GoatSaleRecord> createSaleRecord(GoatSaleRecord record) async {
    final res = await _dio.post('/goats/sales', data: record.toJson());
    return GoatSaleRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<GoatSaleRecord> updateSaleRecord(GoatSaleRecord record) async {
    final res = await _dio.put('/goats/sales/${record.id}', data: record.toJson());
    return GoatSaleRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSaleRecord(String id) async {
    await _dio.delete('/goats/sales/$id');
  }

  // ── Feed records ──────────────────────────────────────────────────────────

  @override
  Future<List<GoatFeedRecord>> getFeedRecords() async {
    final res = await _dio.get('/goats/feed');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => GoatFeedRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<GoatFeedRecord> createFeedRecord(GoatFeedRecord record) async {
    final res = await _dio.post('/goats/feed', data: record.toJson());
    return GoatFeedRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteFeedRecord(String id) async {
    await _dio.delete('/goats/feed/$id');
  }

  // ── Pasture records ───────────────────────────────────────────────────────

  @override
  Future<List<PastureRecord>> getPastureRecords() async {
    final res = await _dio.get('/goats/pasture');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => PastureRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<PastureRecord> createPastureRecord(PastureRecord record) async {
    final res = await _dio.post('/goats/pasture', data: record.toJson());
    return PastureRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<PastureRecord> exitPasture(String id, String exitDate) async {
    final res = await _dio.patch(
      '/goats/pasture/$id/exit',
      data: {'exitDate': exitDate},
    );
    return PastureRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── FAMACHA records ───────────────────────────────────────────────────────

  @override
  Future<List<FamachaRecord>> getFamachaRecords() async {
    final res = await _dio.get('/goats/famacha');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => FamachaRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<FamachaRecord> createFamachaRecord(FamachaRecord record) async {
    final res = await _dio.post('/goats/famacha', data: record.toJson());
    return FamachaRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  // ── Body condition records ────────────────────────────────────────────────

  @override
  Future<List<BodyConditionRecord>> getBodyConditionRecords() async {
    final res = await _dio.get('/goats/bcs');
    final list = _unwrap(res.data) as List<dynamic>;
    return list
        .map((j) => BodyConditionRecord.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BodyConditionRecord> createBodyConditionRecord(
      BodyConditionRecord record) async {
    final res = await _dio.post('/goats/bcs', data: record.toJson());
    return BodyConditionRecord.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }
}
