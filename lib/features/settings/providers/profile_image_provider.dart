import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/shared_preferences_provider.dart';

const _kProfileImageKey = 'profile_image_path';

class ProfileImageNotifier extends Notifier<String?> {
  @override
  String? build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString(_kProfileImageKey);
  }

  Future<void> setImage(String path) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_kProfileImageKey, path);
    state = path;
  }

  Future<void> clearImage() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_kProfileImageKey);
    state = null;
  }
}

final profileImageProvider =
    NotifierProvider<ProfileImageNotifier, String?>(ProfileImageNotifier.new);
