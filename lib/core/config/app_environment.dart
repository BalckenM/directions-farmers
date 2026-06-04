Invalid apphosting.yaml
Your apphosting.yaml file at path '/workspace/apphosting.yaml' is not formatted properly. Please see https://firebase.google.com/docs/app-hosting/configure#apphosting-yaml for guidance on how to format your apphosting.yaml file./// Compile-time environment configuration driven by `--dart-define`.
///
/// Usage (local development — Flutter web on port 8080):
///   flutter run -d chrome --web-port=8080 --dart-define=APP_ENV=dev \
///               --dart-define=API_BASE_URL=http://localhost:3000/v1
///
/// Usage (production build — done automatically by apphosting.yaml):
///   flutter build web --release \
///               --dart-define=APP_ENV=production \
///               --dart-define=API_BASE_URL=https://backendfarmers--directions-payroll.us-east4.hosted.app/v1 \
///               --dart-define=FIREBASE_ENABLED=true
class AppEnvironment {
  AppEnvironment._();

  static const env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  /// Base URL for the REST API (includes /v1 prefix).
  /// Defaults to the production backend. Override for local dev with
  /// `--dart-define=API_BASE_URL=http://localhost:3000/v1`.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://backendfarmers--directions-payroll.us-east4.hosted.app/v1',
  );

  static const firebaseEnabled = bool.fromEnvironment(
    'FIREBASE_ENABLED',
    defaultValue: false,
  );

  static bool get isProduction => env == 'production';
  static bool get isDevelopment => env == 'dev';
}
