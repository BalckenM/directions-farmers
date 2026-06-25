import 'package:mobile_app/core/errors/app_exception.dart';
import 'package:mobile_app/core/errors/failure.dart';
import 'package:mobile_app/features/settings/models/activity_entry.dart';
import 'package:mobile_app/features/settings/models/paddock.dart';
import 'package:mobile_app/features/settings/data/settings_data_source.dart';

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

  Future<List<ActivityEntry>> getActivityLog({int page = 1, int limit = 20}) async {
    try {
      return await _source.getActivityLog(page: page, limit: limit);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _source.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      return await _source.updateProfile(data);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }
}
