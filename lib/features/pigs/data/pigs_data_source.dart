import '../models/sow.dart';

/// Contract that all pigs data sources must fulfil.
abstract class PigsDataSource {
  Future<List<Sow>> getSows();
  Future<List<FarrowingRecord>> getFarrowingRecords();
  Future<List<SowServiceRecord>> getSowServiceRecords();
}
