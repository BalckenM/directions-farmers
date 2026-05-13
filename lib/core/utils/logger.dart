import 'dart:async';
import 'package:flutter/foundation.dart';

// Conditional import: web gets a no-op stub; native gets real dart:io file I/O.
import 'logger_file_stub.dart'
    if (dart.library.io) 'logger_file_io.dart';

/// Log severity levels.
enum LogLevel { debug, info, warning, error }

/// A single captured log entry.
class LogEntry {
  final DateTime time;
  final LogLevel level;
  final String message;
  final String? tag;
  final Object? error;
  final StackTrace? stackTrace;

  const LogEntry({
    required this.time,
    required this.level,
    required this.message,
    this.tag,
    this.error,
    this.stackTrace,
  });

  String get levelEmoji => switch (level) {
        LogLevel.debug => '🔍',
        LogLevel.info => 'ℹ️',
        LogLevel.warning => '⚠️',
        LogLevel.error => '🔴',
      };

  String get timeStr => time.toIso8601String().substring(11, 23);

  /// Full ISO timestamp for file output.
  String get fullTime => time.toIso8601String();

  /// Serialise to a single log-file line.
  String toLogLine() {
    final levelStr = level.name.toUpperCase().padRight(7);
    final tagStr = tag != null ? '[${tag!}] ' : '';
    final errStr = error != null ? ' | ERROR: $error' : '';
    return '$fullTime $levelStr $tagStr$message$errStr';
  }
}

/// Structured logger:
///   • In-memory circular buffer (500 entries) streamed to the debug overlay
///   • Terminal output via debugPrint on every platform
///   • File output to `<documents>`/logs/app_YYYY-MM-DD.log on Android/iOS/desktop
///   • Web: terminal + in-app overlay only (no writable filesystem in browser)
///
/// Call `await AppLogger.initFileLogging()` in main() after ensureInitialized.
abstract final class AppLogger {
  static const int _maxEntries = 500;

  static final List<LogEntry> _buffer = [];
  static final StreamController<LogEntry> _controller =
      StreamController<LogEntry>.broadcast();

  /// Directory where log files live (null on web or before [initFileLogging]).
  static String? get logDirectory => platformLogDirectory;

  /// Current log file path (null on web or before [initFileLogging]).
  static String? get logFilePath => platformLogFilePath;

  /// Live stream of log entries (broadcast).
  static Stream<LogEntry> get stream => _controller.stream;

  /// Snapshot of all buffered log entries (newest last).
  static List<LogEntry> get entries => List.unmodifiable(_buffer);

  /// Number of error-level entries in the buffer.
  static int get errorCount =>
      _buffer.where((e) => e.level == LogLevel.error).length;

  // ── Init ──────────────────────────────────────────────────────────────────

  /// Initialise file logging. Call once after ensureInitialized().
  /// On Android/iOS/desktop: opens `<documents>`/logs/app_YYYY-MM-DD.log.
  /// On web: no-op (logs still appear in terminal and in-app console).
  static Future<void> initFileLogging() async {
    if (kIsWeb) {
      debugPrint('ℹ️ [Logger] Web — file logging disabled; '
          'all logs visible in terminal and in-app console.');
      return;
    }
    await initPlatformFileLogging(
      List<LogEntry>.from(_buffer),
      (e) => (e as LogEntry).toLogLine(),
    );
  }

  /// Flush and close the log file (call on app termination if needed).
  static Future<void> flushAndClose() => flushPlatformLog();

  // ── Public API ────────────────────────────────────────────────────────────

  static void debug(String message, {String? tag, Object? data}) =>
      _log(LogLevel.debug, message, tag: tag, error: data);

  static void info(String message, {String? tag, Object? data}) =>
      _log(LogLevel.info, message, tag: tag, error: data);

  static void warning(String message, {String? tag, Object? error}) =>
      _log(LogLevel.warning, message, tag: tag, error: error);

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);

  /// Hook into [FlutterError.onError].
  static void captureFlutterError(FlutterErrorDetails details) {
    _log(
      LogLevel.error,
      details.exceptionAsString(),
      tag: details.library ?? 'Flutter',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.dumpErrorToConsole(details, forceReport: true);
  }

  /// Hook into [PlatformDispatcher.instance.onError] / runZonedGuarded.
  static bool captureZoneError(Object error, StackTrace stack) {
    _log(LogLevel.error, error.toString(), tag: 'Zone', error: error, stackTrace: stack);
    return true;
  }

  /// Clear the in-memory buffer (does NOT delete the log file).
  static void clear() => _buffer.clear();

  // ── Internal ──────────────────────────────────────────────────────────────

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final entry = LogEntry(
      time: DateTime.now(),
      level: level,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );

    // Circular buffer → in-app debug console
    if (_buffer.length >= _maxEntries) _buffer.removeAt(0);
    _buffer.add(entry);
    if (!_controller.isClosed) _controller.add(entry);

    // Terminal — always printed on all platforms
    final tagStr = tag != null ? ' [$tag]' : '';
    final errStr = error != null ? '\n  → $error' : '';
    debugPrint('${entry.levelEmoji} ${entry.timeStr}$tagStr $message$errStr');
    if (stackTrace != null) debugPrint('  ↳ $stackTrace');

    // File — Android/iOS/desktop only (web stub is a no-op)
    writePlatformLogLine(entry.toLogLine());
  }
}
