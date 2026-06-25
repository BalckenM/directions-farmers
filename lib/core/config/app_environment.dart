/// Compile-time environment configuration driven by `--dart-define`.
///
/// Port layout (local dev):
///   Backend  →  http://127.0.0.1:3001  (Node.js / Express, path /api/v1)
///   Flutter web dev server  →  http://localhost:8080
///
/// Run commands:
///   flutter run -d chrome          (uses .vscode/launch.json — port 8080)
///   flutter run -d <android-id>    (uses 10.0.2.2:3001 emulator loopback)
///
/// Production build (apphosting.yaml):
///   flutter build web --release \
///               --dart-define=APP_ENV=production \
///               --dart-define=API_BASE_URL=https://backendfarmers--directions-payroll.us-east4.hosted.app/api/v1 \
///               --dart-define=FIREBASE_ENABLED=true
class AppEnvironment {
  AppEnvironment._();

  static const env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  /// Base URL for the REST API (includes /api/v1 prefix).
  /// Backend: 127.0.0.1:3001, base path /api/v1.
  /// Android emulator override: --dart-define=API_BASE_URL=http://10.0.2.2:3001/api/v1
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3001/api/v1',
  );

  static const firebaseEnabled = bool.fromEnvironment(
    'FIREBASE_ENABLED',
    defaultValue: false,
  );

  static bool get isProduction => env == 'production';
  static bool get isDevelopment => env == 'dev';
}
