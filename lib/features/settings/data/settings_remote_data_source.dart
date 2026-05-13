import '../models/paddock.dart';
import 'settings_data_source.dart';

class SettingsRemoteDataSource implements SettingsDataSource {
  @override
  Future<List<Paddock>> getPaddocks() =>
      throw UnimplementedError('SettingsRemoteDataSource.getPaddocks not implemented');
}
