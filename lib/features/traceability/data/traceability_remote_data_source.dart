import 'package:dio/dio.dart';

import '../models/movement_record.dart';
import 'traceability_data_source.dart';

/// Production remote data source — calls the FarmTrack REST API via Dio.
class TraceabilityRemoteDataSource implements TraceabilityDataSource {
  TraceabilityRemoteDataSource(this._dio);

  final Dio _dio;

  dynamic _unwrap(dynamic body) =>
      (body is Map<String, dynamic> && body.containsKey('data'))
          ? body['data']
          : body;

  @override
  Future<List<MovementRecord>> getMovementRecords() async {
    final res = await _dio.get('/traceability/movements');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => MovementRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> addMovementRecord(MovementRecord record) async {
    await _dio.post('/traceability/movements', data: record.toJson());
  }
}
