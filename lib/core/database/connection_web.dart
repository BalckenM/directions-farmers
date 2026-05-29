import 'package:drift/drift.dart';
import 'package:drift/web.dart';

/// Opens a web-based in-memory database connection using sql.js (WASM).
///
/// Uses volatile (non-persistent) storage because the offline-sync queue is
/// not applicable on the web platform — all data access goes through the
/// mock/remote data sources.
DatabaseConnection openDatabaseConnection() {
  return DatabaseConnection(
    WebDatabase.withStorage(DriftWebStorage.volatile()),
  );
}
