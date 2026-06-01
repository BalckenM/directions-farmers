import 'package:dio/dio.dart';

import '../models/activity_entry.dart';
import '../models/paddock.dart';
import 'settings_data_source.dart';

/// Production remote data source — calls the FarmTrack REST API via Dio.
class SettingsRemoteDataSource implements SettingsDataSource {
  SettingsRemoteDataSource(this._dio);

  final Dio _dio;

  dynamic _unwrap(dynamic body) =>
      (body is Map<String, dynamic> && body.containsKey('data'))
          ? body['data']
          : body;

  @override
  Future<List<Paddock>> getPaddocks() async {
    final res = await _dio.get('/settings/paddocks');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => Paddock.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ActivityEntry>> getActivityLog({int page = 1, int limit = 20}) async {
    final res = await _dio.get('/farm/activity', queryParameters: {
      'page': page,
      'limit': limit,
    });
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => ActivityEntry.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.put('/auth/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final res = await _dio.put('/auth/profile', data: data);
    return _unwrap(res.data) as Map<String, dynamic>;
  }
}
