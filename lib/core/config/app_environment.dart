/// Compile-time environment configuration driven by `--dart-define`.
///
/// Usage (development):
///   flutter run --dart-define=APP_ENV=dev
///
/// Usage (production):
///   flutter run --dart-define=APP_ENV=production \
///               --dart-define=API_BASE_URL=https://api.4dfarmer.com \
///               --dart-define=FIREBASE_ENABLED=true
class AppEnvironment {
  AppEnvironment._();

  static const env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.dev.4dfarmer.com',
  );

  static const firebaseEnabled = bool.fromEnvironment(
    'FIREBASE_ENABLED',
    defaultValue: false,
  );

  static bool get isProduction => env == 'production';
  static bool get isDevelopment => env == 'dev';
}
