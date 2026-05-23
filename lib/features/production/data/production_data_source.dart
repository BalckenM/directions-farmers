import '../models/egg_record.dart';
import '../models/milk_record.dart';
import '../models/wool_record.dart';

/// Contract that all production data sources must fulfil.
abstract class ProductionDataSource {
  Future<List<MilkRecord>> getMilkRecords();
  Future<List<EggRecord>> getEggRecords();
  Future<List<WoolRecord>> getWoolRecords();

  Future<void> addMilkRecord(MilkRecord record);
  Future<void> addEggRecord(EggRecord record);
  Future<void> addWoolRecord(WoolRecord record);
}
