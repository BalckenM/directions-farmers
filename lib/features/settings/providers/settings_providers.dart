import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/settings_data_source.dart';
import '../data/settings_remote_data_source.dart';
import '../data/settings_repository.dart';

final settingsDataSourceProvider = Provider<SettingsDataSource>(
  (ref) => SettingsRemoteDataSource(ref.read(apiDioProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(settingsDataSourceProvider)),
);
