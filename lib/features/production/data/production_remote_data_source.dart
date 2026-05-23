import '../models/egg_record.dart';
import '../models/milk_record.dart';
import '../models/wool_record.dart';
import 'production_data_source.dart';

/// Stub remote data source — replace with real Dio calls when backend is ready.
class ProductionRemoteDataSource implements ProductionDataSource {
  @override
  Future<List<MilkRecord>> getMilkRecords() =>
      throw UnimplementedError('ProductionRemoteDataSource.getMilkRecords not implemented');

  @override
  Future<List<EggRecord>> getEggRecords() =>
      throw UnimplementedError('ProductionRemoteDataSource.getEggRecords not implemented');

  @override
  Future<List<WoolRecord>> getWoolRecords() =>
      throw UnimplementedError('ProductionRemoteDataSource.getWoolRecords not implemented');

  @override
  Future<void> addMilkRecord(MilkRecord record) =>
      throw UnimplementedError('ProductionRemoteDataSource.addMilkRecord not implemented');

  @override
  Future<void> addEggRecord(EggRecord record) =>
      throw UnimplementedError('ProductionRemoteDataSource.addEggRecord not implemented');

  @override
  Future<void> addWoolRecord(WoolRecord record) =>
      throw UnimplementedError('ProductionRemoteDataSource.addWoolRecord not implemented');
}
