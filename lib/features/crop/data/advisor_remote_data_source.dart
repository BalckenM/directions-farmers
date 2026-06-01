import 'package:dio/dio.dart';

import '../models/advisor_models.dart';
import 'advisor_data_source.dart';

/// Production remote data source — calls the FarmTrack REST API via Dio.
class AdvisorRemoteDataSource implements AdvisorDataSource {
  AdvisorRemoteDataSource(this._dio);

  final Dio _dio;

  dynamic _unwrap(dynamic body) =>
      (body is Map<String, dynamic> && body.containsKey('data'))
          ? body['data']
          : body;

  @override
  Future<AdvisorResponse> getAdvice(AdvisorQuery query) async {
    final res = await _dio.post('/advisor/advice', data: {
      'topic': query.topic.name,
      'farmId': query.context.farmId,
      if (query.freeTextHint != null) 'hint': query.freeTextHint,
    });
    return AdvisorResponse.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<List<AdvisorResponse>> getDailyBriefing(String farmId) async {
    final res = await _dio.get('/advisor/briefing', queryParameters: {'farmId': farmId});
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => AdvisorResponse.fromJson(j as Map<String, dynamic>)).toList();
  }
}
