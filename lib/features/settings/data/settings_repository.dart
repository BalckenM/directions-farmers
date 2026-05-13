import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../models/paddock.dart';
import 'settings_data_source.dart';
import 'settings_mock_data_source.dart';
import 'settings_remote_data_source.dart';

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

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final SettingsDataSource source = AppConstants.useMockData
      ? SettingsMockDataSource()
      : SettingsRemoteDataSource();
  return SettingsRepository(source);
});
