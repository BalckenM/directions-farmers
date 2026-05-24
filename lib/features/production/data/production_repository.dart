import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../models/egg_record.dart';
import '../models/milk_record.dart';
import '../models/wool_record.dart';
import 'production_data_source.dart';

class ProductionRepository {
  ProductionRepository(this._source);

  final ProductionDataSource _source;

  Future<List<MilkRecord>> getMilkRecords() async {
    try {
      return await _source.getMilkRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<EggRecord>> getEggRecords() async {
    try {
      return await _source.getEggRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<WoolRecord>> getWoolRecords() async {
    try {
      return await _source.getWoolRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<void> addMilkRecord(MilkRecord record) async {
    try {
      await _source.addMilkRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<void> addEggRecord(EggRecord record) async {
    try {
      await _source.addEggRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<void> addWoolRecord(WoolRecord record) async {
    try {
      await _source.addWoolRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }
}

