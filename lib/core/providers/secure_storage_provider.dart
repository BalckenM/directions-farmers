import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app/core/services/secure_storage_service.dart';

/// Provides a [SecureStorageService] backed by [FlutterSecureStorage].
/// Ready to use anywhere via `ref.read(secureStorageProvider)`.
final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(const FlutterSecureStorage()),
);
