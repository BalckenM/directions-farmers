import '../models/apiculture.dart';

/// Contract that all apiculture data sources must fulfil.
abstract class ApicultureDataSource {
  Future<List<Apiary>> getApiaries();
  Future<List<Hive>> getHives();
  Future<List<HiveInspection>> getHiveInspections();
}
