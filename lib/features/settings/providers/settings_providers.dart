import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/settings/data/settings_data_source.dart';
import 'package:mobile_app/features/settings/data/settings_remote_data_source.dart';
import 'package:mobile_app/features/settings/data/settings_repository.dart';

final settingsDataSourceProvider = Provider<SettingsDataSource>(
  (ref) => SettingsRemoteDataSource(ref.read(apiDioProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(settingsDataSourceProvider)),
);
