/// Application-wide constants for FarmTrack.
abstract final class AppConstants {
  // ── App identity ─────────────────────────────────────────────────────────────
  static const String appName = '4Directions';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // ── API config ────────────────────────────────────────────────────────────────
  /// Timeout for HTTP requests. Base URL lives ONLY in AppEnvironment.
  /// Split into connect (TCP handshake) and receive (waiting for response body)
  /// so a slow server fails fast instead of blocking the UI for a full minute.
  static const Duration apiConnectTimeout = Duration(seconds: 30);
  static const Duration apiReceiveTimeout = Duration(seconds: 15);

  /// Legacy alias — kept for any code still referencing apiTimeout.
  static const Duration apiTimeout = apiReceiveTimeout;

  /// Timeout for heavy server-side operations (payroll calculation, report generation).
  static const Duration apiLongTimeout = Duration(minutes: 5);
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

  // ── Feature slug constants ────────────────────────────────────────────────────
  static const String featureAgriculture = 'agriculture';
  static const String featureLeave = 'leave';
}
