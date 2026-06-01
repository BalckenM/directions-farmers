/// Compile-time environment configuration driven by `--dart-define`.
///
/// Usage (local development — Flutter web on port 8080):
///   flutter run -d chrome --web-port=8080 --dart-define=APP_ENV=dev
///
/// Usage (production):
///   flutter run --dart-define=APP_ENV=production \
///               --dart-define=API_BASE_URL=https://api.4dfarmer.app/v1 \
///               --dart-define=FIREBASE_ENABLED=true
class AppEnvironment {
  AppEnvironment._();

  static const env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  /// Base URL for the REST API (includes /v1 prefix).
  /// Local dev defaults to the backend running on port 3000.
  /// Override at build time with `--dart-define=API_BASE_URL=<url>`.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/v1',
  );

  static const firebaseEnabled = bool.fromEnvironment(
    'FIREBASE_ENABLED',
    defaultValue: false,
  );

  static bool get isProduction => env == 'production';
  static bool get isDevelopment => env == 'dev';
}
