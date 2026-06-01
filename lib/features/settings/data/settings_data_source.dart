import '../models/activity_entry.dart';
import '../models/paddock.dart';

abstract class SettingsDataSource {
  Future<List<Paddock>> getPaddocks();
  Future<List<ActivityEntry>> getActivityLog({int page, int limit});
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data);
}
