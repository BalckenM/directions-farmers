import 'package:intl/intl.dart';

/// Date formatting utilities for the FarmTrack app.
abstract final class FarmDateUtils {
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy · HH:mm');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy');
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _dayMonthFormat = DateFormat('d MMM');

  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);
  static String formatApiDate(DateTime date) => _apiDateFormat.format(date);
  static String formatDayMonth(DateTime date) => _dayMonthFormat.format(date);

  /// Parses an ISO-8601 string to DateTime, returns null on parse failure.
  static DateTime? parseApiDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  /// Returns relative label: "Today", "Yesterday", "X days ago", etc.
  static String relative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 0) {
      final ahead = -diff;
      if (ahead == 1) return 'Tomorrow';
      if (ahead < 7) return 'In $ahead days';
    }
    if (diff < 7) return '$diff days ago';
    if (diff < 30) return '${(diff / 7).floor()} weeks ago';
    if (diff < 365) return '${(diff / 30).floor()} months ago';
    return '${(diff / 365).floor()} years ago';
  }

  /// Returns age as human-readable string from birthdate.
  static String age(DateTime birthDate) {
    final now = DateTime.now();
    final totalDays = now.difference(birthDate).inDays;
    if (totalDays < 1) return 'Newborn';
    if (totalDays < 30) return '$totalDays day${totalDays > 1 ? 's' : ''}';
    if (totalDays < 365) {
      final months = (totalDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    }
    final years = (totalDays / 365).floor();
    final remainingMonths = ((totalDays % 365) / 30).floor();
    if (remainingMonths == 0) return '$years year${years > 1 ? 's' : ''}';
    return '$years yr${years > 1 ? 's' : ''} $remainingMonths mo';
  }

  /// Returns the start of today (midnight).
  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Returns the start of the current week (Monday).
  static DateTime get startOfWeek {
    final t = today;
    return t.subtract(Duration(days: t.weekday - 1));
  }

  /// Returns the start of the current month.
  static DateTime get startOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  /// Calculates days until an expected event (e.g. due date).
  static int daysUntil(DateTime target) {
    return target.difference(today).inDays;
  }

  /// Returns a list of the last [count] months as (DateTime start, String label) pairs.
  static List<({DateTime start, String label})> lastMonths(int count) {
    final now = DateTime.now();
    return List.generate(count, (i) {
      final month = DateTime(now.year, now.month - (count - 1 - i));
      return (start: month, label: _monthYearFormat.format(month));
    });
  }
}
