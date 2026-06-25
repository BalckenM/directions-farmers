import '../models/animal.dart';
import '../models/group.dart';
import 'livestock_data_source.dart';

// Stub — livestock module not yet active. No HTTP calls are made.
class LivestockRemoteDataSource implements LivestockDataSource {
  LivestockRemoteDataSource(dynamic _);

  @override Future<List<Animal>> getAnimals(String species) async => const [];
  @override Future<List<Group>> getGroups() async => const [];
}
