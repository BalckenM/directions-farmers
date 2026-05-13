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
}
