// Resolves to the web stub (UnsupportedError) on web/unsupported platforms,
// and to the full native implementation on Android/iOS/macOS/Windows/Linux.
export 'social_auth_service_stub.dart'
    if (dart.library.io) 'social_auth_service_mobile.dart';
