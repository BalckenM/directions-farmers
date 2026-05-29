import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

/// Opens a native SQLite database connection backed by a file on disk.
DatabaseConnection openDatabaseConnection() {
  return DatabaseConnection(
    LazyDatabase(() async {
      // On older Android versions, the bundled libsqlite3 needs a workaround.
      if (defaultTargetPlatform == TargetPlatform.android) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, '4directions_local.db'));
      return NativeDatabase.createInBackground(file);
    }),
  );
}
