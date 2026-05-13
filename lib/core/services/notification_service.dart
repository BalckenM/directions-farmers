// Resolves to the web stub (no-ops) on web/unsupported platforms,
// and to the full mobile implementation on Android/iOS/macOS/Windows/Linux.
export 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_mobile.dart';
