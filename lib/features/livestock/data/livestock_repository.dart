import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../models/animal.dart';
import '../models/group.dart';
import 'livestock_data_source.dart';
import 'livestock_mock_data_source.dart';
import 'livestock_remote_data_source.dart';

class LivestockRepository {
  LivestockRepository(this._source);

  final LivestockDataSource _source;

  Future<List<Animal>> getAnimals(String species) async {
    try {
      return await _source.getAnimals(species);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<Animal?> getAnimalById(String species, String id) async {
    final animals = await getAnimals(species);
    try {
      return animals.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Group>> getGroups() async {
    try {
      return await _source.getGroups();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }
}

final livestockRepositoryProvider = Provider<LivestockRepository>((ref) {
  final LivestockDataSource source = AppConstants.useMockData
      ? LivestockMockDataSource()
      : LivestockRemoteDataSource();
  return LivestockRepository(source);
});
