import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/database/app_database.dart';

/// Provides the single shared [AppDatabase] instance.
///
/// The database connection is opened lazily on first access and closed
/// automatically when the [ProviderContainer] is disposed (i.e. when the app
/// terminates).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
