import '../models/egg_record.dart';
import '../models/milk_record.dart';
import '../models/wool_record.dart';
import 'production_data_source.dart';

// Stub — production module not yet active. No HTTP calls are made.
class ProductionRemoteDataSource implements ProductionDataSource {
  ProductionRemoteDataSource(dynamic _);

  @override Future<List<MilkRecord>> getMilkRecords() async => const [];
  @override Future<List<EggRecord>> getEggRecords() async => const [];
  @override Future<List<WoolRecord>> getWoolRecords() async => const [];
  @override Future<void> addMilkRecord(MilkRecord record) async {}
  @override Future<void> addEggRecord(EggRecord record) async {}
  @override Future<void> addWoolRecord(WoolRecord record) async {}
}
