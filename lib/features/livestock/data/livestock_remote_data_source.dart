import 'package:dio/dio.dart';

import '../models/animal.dart';
import '../models/group.dart';
import 'livestock_data_source.dart';

/// Production remote data source — calls the FarmTrack REST API via Dio.
class LivestockRemoteDataSource implements LivestockDataSource {
  LivestockRemoteDataSource(this._dio);

  final Dio _dio;

  dynamic _unwrap(dynamic body) =>
      (body is Map<String, dynamic> && body.containsKey('data'))
          ? body['data']
          : body;

  @override
  Future<List<Animal>> getAnimals(String species) async {
    final res = await _dio.get('/livestock/animals', queryParameters: {'species': species});
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => Animal.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Group>> getGroups() async {
    final res = await _dio.get('/livestock/groups');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => Group.fromJson(j as Map<String, dynamic>)).toList();
  }
}
