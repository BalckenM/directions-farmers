import 'package:dio/dio.dart';

import '../models/feed_log.dart';
import 'record_data_source.dart';

/// Production remote data source — calls the FarmTrack REST API via Dio.
class RecordRemoteDataSource implements RecordDataSource {
  RecordRemoteDataSource(this._dio);

  final Dio _dio;

  dynamic _unwrap(dynamic body) =>
      (body is Map<String, dynamic> && body.containsKey('data'))
          ? body['data']
          : body;

  @override
  Future<List<FeedLog>> getFeedLogs() async {
    final res = await _dio.get('/record/feed-logs');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => FeedLog.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> addFeedLog(FeedLog log) async {
    await _dio.post('/record/feed-logs', data: log.toJson());
  }
}
