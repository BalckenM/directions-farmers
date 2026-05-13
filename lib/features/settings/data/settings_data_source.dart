import '../models/paddock.dart';

abstract class SettingsDataSource {
  Future<List<Paddock>> getPaddocks();
}
