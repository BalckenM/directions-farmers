import 'package:mobile_app/core/errors/app_exception.dart';
import 'package:mobile_app/core/errors/failure.dart';
import 'package:mobile_app/features/events/models/breeding_event.dart';
import 'package:mobile_app/features/events/models/health_event.dart';
import 'package:mobile_app/features/events/models/weight_record.dart';
import 'package:mobile_app/features/events/data/events_data_source.dart';

class EventsRepository {
  EventsRepository(this._source);

  final EventsDataSource _source;

  Future<List<HealthEvent>> getHealthEvents() async {
    try {
      return await _source.getHealthEvents();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<WeightRecord>> getWeightRecords() async {
    try {
      return await _source.getWeightRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<BreedingEvent>> getBreedingEvents() async {
    try {
      return await _source.getBreedingEvents();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<void> addHealthEvent(HealthEvent event) async {
    try {
      await _source.addHealthEvent(event);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<void> addWeightRecord(WeightRecord record) async {
    try {
      await _source.addWeightRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<void> addBreedingEvent(BreedingEvent event) async {
    try {
      await _source.addBreedingEvent(event);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }
}
