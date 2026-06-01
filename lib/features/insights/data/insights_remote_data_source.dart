import 'package:dio/dio.dart';

import 'insights_data_source.dart';

/// Production remote data source — calls the FarmTrack REST API via Dio.
class InsightsRemoteDataSource implements InsightsDataSource {
  InsightsRemoteDataSource(this._dio);

  final Dio _dio;

  dynamic _unwrap(dynamic body) =>
      (body is Map<String, dynamic> && body.containsKey('data'))
          ? body['data']
          : body;

  @override
  Future<Map<String, dynamic>> getMarketPrices() async {
    final res = await _dio.get('/insights/market-prices');
    return _unwrap(res.data) as Map<String, dynamic>;
  }
}
