import '../models/animal.dart';
import '../models/group.dart';
import 'livestock_data_source.dart';

/// Stub remote data source — replace with real Dio calls when backend is ready.
class LivestockRemoteDataSource implements LivestockDataSource {
  @override
  Future<List<Animal>> getAnimals(String species) =>
      throw UnimplementedError('LivestockRemoteDataSource.getAnimals not implemented');

  @override
  Future<List<Group>> getGroups() =>
      throw UnimplementedError('LivestockRemoteDataSource.getGroups not implemented');
}
