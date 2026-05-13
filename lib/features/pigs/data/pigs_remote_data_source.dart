import '../models/sow.dart';
import 'pigs_data_source.dart';

/// Stub remote data source — replace with real Dio calls when backend is ready.
class PigsRemoteDataSource implements PigsDataSource {
  @override
  Future<List<Sow>> getSows() =>
      throw UnimplementedError('PigsRemoteDataSource.getSows not implemented');

  @override
  Future<List<FarrowingRecord>> getFarrowingRecords() =>
      throw UnimplementedError('PigsRemoteDataSource.getFarrowingRecords not implemented');

  @override
  Future<List<SowServiceRecord>> getSowServiceRecords() =>
      throw UnimplementedError('PigsRemoteDataSource.getSowServiceRecords not implemented');
}
