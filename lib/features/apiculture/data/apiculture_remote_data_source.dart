import '../models/apiculture.dart';
import 'apiculture_data_source.dart';

/// Stub remote data source — replace with real Dio calls when backend is ready.
class ApicultureRemoteDataSource implements ApicultureDataSource {
  @override
  Future<List<Apiary>> getApiaries() =>
      throw UnimplementedError('ApicultureRemoteDataSource.getApiaries not implemented');

  @override
  Future<List<Hive>> getHives() =>
      throw UnimplementedError('ApicultureRemoteDataSource.getHives not implemented');

  @override
  Future<List<HiveInspection>> getHiveInspections() =>
      throw UnimplementedError('ApicultureRemoteDataSource.getHiveInspections not implemented');
}
