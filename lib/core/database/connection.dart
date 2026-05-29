import 'package:drift/drift.dart';

/// Default stub — never actually called at runtime.
/// The conditional imports in [app_database.dart] select the correct
/// platform implementation ([connection_native.dart] or [connection_web.dart]).
DatabaseConnection openDatabaseConnection() =>
    throw UnsupportedError('openDatabaseConnection: unsupported platform');
