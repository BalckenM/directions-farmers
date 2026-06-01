import 'package:dio/dio.dart';

import '../models/egg_record.dart';
import '../models/milk_record.dart';
import '../models/wool_record.dart';
import 'production_data_source.dart';

/// Production remote data source — calls the FarmTrack REST API via Dio.
class ProductionRemoteDataSource implements ProductionDataSource {
  ProductionRemoteDataSource(this._dio);

  final Dio _dio;

  dynamic _unwrap(dynamic body) =>
      (body is Map<String, dynamic> && body.containsKey('data'))
          ? body['data']
          : body;

  @override
  Future<List<MilkRecord>> getMilkRecords() async {
    final res = await _dio.get('/production/milk');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => MilkRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<EggRecord>> getEggRecords() async {
    final res = await _dio.get('/production/eggs');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => EggRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<WoolRecord>> getWoolRecords() async {
    final res = await _dio.get('/production/wool');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => WoolRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> addMilkRecord(MilkRecord record) async {
    await _dio.post('/production/milk', data: record.toJson());
  }

  @override
  Future<void> addEggRecord(EggRecord record) async {
    await _dio.post('/production/eggs', data: record.toJson());
  }

  @override
  Future<void> addWoolRecord(WoolRecord record) async {
    await _dio.post('/production/wool', data: record.toJson());
  }
}
