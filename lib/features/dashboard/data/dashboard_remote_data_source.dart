import 'package:dio/dio.dart';

import 'dashboard_data_source.dart';
import '../models/dashboard_summary.dart';

/// Production remote data source — calls the FarmTrack REST API via Dio.
class DashboardRemoteDataSource implements DashboardDataSource {
  DashboardRemoteDataSource(this._dio);

  final Dio _dio;

  dynamic _unwrap(dynamic body) =>
      (body is Map<String, dynamic> && body.containsKey('data'))
          ? body['data']
          : body;

  @override
  Future<DashboardSummary> getSummary() async {
    final res = await _dio.get('/dashboard/summary');
    final json = _unwrap(res.data) as Map<String, dynamic>;
    return DashboardSummary.fromJson(json);
  }
}
