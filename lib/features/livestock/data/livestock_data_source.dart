import '../models/animal.dart';
import '../models/group.dart';

/// Contract that all livestock data sources must fulfil.
abstract class LivestockDataSource {
  Future<List<Animal>> getAnimals(String species);
  Future<List<Group>> getGroups();
}
