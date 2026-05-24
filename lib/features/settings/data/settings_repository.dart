import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../models/paddock.dart';
import 'settings_data_source.dart';

class SettingsRepository {
  SettingsRepository(this._source);

  final SettingsDataSource _source;

  Future<List<Paddock>> getPaddocks() async {
    try {
      return await _source.getPaddocks();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }
}

