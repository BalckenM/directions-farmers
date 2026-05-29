import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps [FlutterSecureStorage] with a simple key-value API.
///
/// Use this for tokens and session data.
/// Non-sensitive prefs (theme, onboarding flags) stay in SharedPreferences.
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  Future<void> write(String key, String value) => _storage.write(
    key: key,
    value: value,
    aOptions: _androidOptions,
    iOptions: _iosOptions,
  );

  Future<String?> read(String key) =>
      _storage.read(key: key, aOptions: _androidOptions, iOptions: _iosOptions);

  Future<void> delete(String key) => _storage.delete(
    key: key,
    aOptions: _androidOptions,
    iOptions: _iosOptions,
  );

  Future<void> deleteAll() =>
      _storage.deleteAll(aOptions: _androidOptions, iOptions: _iosOptions);
}
