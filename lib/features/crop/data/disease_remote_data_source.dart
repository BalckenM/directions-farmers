import 'package:dio/dio.dart';

import '../models/disease_detection.dart';
import 'disease_data_source.dart';

/// Production remote data source — calls the FarmTrack REST API via Dio.
class DiseaseRemoteDataSource implements DiseaseDataSource {
  DiseaseRemoteDataSource(this._dio);

  final Dio _dio;

  dynamic _unwrap(dynamic body) =>
      (body is Map<String, dynamic> && body.containsKey('data'))
          ? body['data']
          : body;

  @override
  Future<List<DiseaseInfo>> getDiseaseLibrary() async {
    final res = await _dio.get('/disease/library');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => DiseaseInfo.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<DiseaseDetectionResult> detectDisease({
    required String imagePath,
    String? cropHint,
  }) async {
    final res = await _dio.post('/disease/detect', data: {
      'imagePath': imagePath,
      if (cropHint != null) 'cropHint': cropHint,
    });
    return DiseaseDetectionResult.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }
}
