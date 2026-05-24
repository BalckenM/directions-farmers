// South African statutory public holidays (Public Holidays Act 36 of 1994).
// When a public holiday falls on a Sunday, the following Monday is observed.
// Easter dates are calculated using the Anonymous Gregorian algorithm.

/// Provides SA public holiday dates for any given calendar year.
class SaPublicHolidays {
  SaPublicHolidays._();

  // ─── Fixed holidays (month, day) ─────────────────────────────────────────

  static const List<(int month, int day, String name)> _fixed = [
    (1, 1, 'New Year\'s Day'),
    (3, 21, 'Human Rights Day'),
    (4, 27, 'Freedom Day'),
    (5, 1, 'Workers\' Day'),
    (6, 16, 'Youth Day'),
    (8, 9, 'National Women\'s Day'),
    (9, 24, 'Heritage Day'),
    (12, 16, 'Day of Reconciliation'),
    (12, 25, 'Christmas Day'),
    (12, 26, 'Day of Goodwill'),
  ];

  // ─── Easter (variable) ───────────────────────────────────────────────────

  /// Computes Easter Sunday for [year] using the Anonymous Gregorian algorithm.
  static DateTime easterSunday(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }

  // ─── Main API ─────────────────────────────────────────────────────────────

  /// Returns all observed public holiday dates for [year].
  ///
  /// Applies the Sunday → Monday shift rule for fixed holidays.
  static List<DateTime> holidaysForYear(int year) {
    final holidays = <DateTime>[];

    // Fixed holidays
    for (final (month, day, _) in _fixed) {
      var date = DateTime(year, month, day);
      if (date.weekday == DateTime.sunday) {
        date = date.add(const Duration(days: 1)); // observed Monday
      }
      holidays.add(date);
    }

    // Easter-relative
    final easter = easterSunday(year);
    holidays.add(easter.subtract(const Duration(days: 2))); // Good Friday
    holidays.add(easter.add(const Duration(days: 1))); // Family Day

    holidays.sort();
    return holidays;
  }

  /// Returns the holiday name for [date], or null if it is not a public holiday.
  ///
  /// Checks observed dates (Sunday→Monday shifted) and Easter-relative dates.
  static String? nameFor(DateTime date, {int? year}) {
    final y = year ?? date.year;
    final normalized = DateTime(date.year, date.month, date.day);

    // Fixed holidays
    for (final (month, day, name) in _fixed) {
      var d = DateTime(y, month, day);
      if (d.weekday == DateTime.sunday) d = d.add(const Duration(days: 1));
      if (d == normalized) return name;
    }

    // Easter
    final easter = easterSunday(y);
    final goodFriday = easter.subtract(const Duration(days: 2));
    final familyDay = easter.add(const Duration(days: 1));
    if (goodFriday == normalized) return 'Good Friday';
    if (familyDay == normalized) return 'Family Day';

    return null;
  }

  /// Returns true if [date] is a SA public holiday (observed).
  static bool isPublicHoliday(DateTime date) => nameFor(date) != null;

  /// Returns the number of public holidays within [start]..[end] (inclusive).
  static int countHolidaysInRange(DateTime start, DateTime end) {
    int count = 0;
    // Gather holidays for all years spanning the range
    final years = {start.year, end.year};
    final allHolidays = <DateTime>{};
    for (final y in years) {
      allHolidays.addAll(holidaysForYear(y));
    }
    for (final h in allHolidays) {
      if (!h.isBefore(start) && !h.isAfter(end)) count++;
    }
    return count;
  }

  /// Returns all holiday dates that fall within [start]..[end] (inclusive).
  static List<DateTime> holidaysInRange(DateTime start, DateTime end) {
    final years = {start.year, end.year};
    final allHolidays = <DateTime>{};
    for (final y in years) {
      allHolidays.addAll(holidaysForYear(y));
    }
    return allHolidays
        .where((h) => !h.isBefore(start) && !h.isAfter(end))
        .toList()
      ..sort();
  }
}
