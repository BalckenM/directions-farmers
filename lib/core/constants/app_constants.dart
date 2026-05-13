/// Application-wide constants for FarmTrack.
abstract final class AppConstants {
  // ── App identity ─────────────────────────────────────────────────────────────
  static const String appName = 'FarmTrack';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // ── Environment switch ────────────────────────────────────────────────────────
  /// Set to [false] to point every feature repository at its RemoteDataSource.
  static const bool useMockData = true;

  // ── API endpoints (placeholder — replace with real base URL) ─────────────────
  static const String apiBaseUrl = 'https://api.farmtrack.app/v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int apiMaxRetries = 3;

  // ── Pagination ────────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ── Cache ─────────────────────────────────────────────────────────────────────
  static const Duration cacheMaxAge = Duration(hours: 6);
  static const Duration imageCacheMaxAge = Duration(days: 7);
  static const int imageCacheMaxCount = 500;

  // ── Date formats ──────────────────────────────────────────────────────────────
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy · HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String monthYearFormat = 'MMM yyyy';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'";

  // ── SharedPreferences keys ────────────────────────────────────────────────────
  static const String prefThemeMode = 'theme_mode';
  static const String prefSelectedFarmId = 'selected_farm_id';
  static const String prefAuthToken = 'auth_token';
  static const String prefLastSyncAt = 'last_sync_at';
  static const String prefOnboardingDone = 'onboarding_done';

  // ── Notification channels ─────────────────────────────────────────────────────
  static const String notifChannelHealth = 'health_alerts';
  static const String notifChannelBreeding = 'breeding_reminders';
  static const String notifChannelTask = 'task_reminders';
  static const String notifChannelProduction = 'production_alerts';

  // ── Animation durations ───────────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animShimmer = Duration(milliseconds: 1200);
  static const Duration animCounter = Duration(milliseconds: 800);
}
