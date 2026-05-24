import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settings_data_source.dart';
import '../data/settings_mock_data_source.dart';
import '../data/settings_repository.dart';

final settingsDataSourceProvider = Provider<SettingsDataSource>(
  (ref) => SettingsMockDataSource(),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(settingsDataSourceProvider)),
);
