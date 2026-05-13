import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/livestock_constants.dart';

/// Extension methods to reduce boilerplate throughout the codebase.
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  bool get isTablet => screenWidth >= 600;
  bool get isDesktop => screenWidth >= 900;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AppColors.error
            : Theme.of(this).colorScheme.inverseSurface,
      ),
    );
  }
}

extension StringX on String {
  /// Capitalises only the first character.
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Title-cases each word.
  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  /// Returns true if non-empty after trimming.
  bool get isNotBlank => trim().isNotEmpty;

  /// Returns true if null-equivalent (empty or whitespace-only).
  bool get isBlank => trim().isEmpty;

  /// Attempts to parse as an int, returns null on failure.
  int? get toIntOrNull => int.tryParse(this);

  /// Attempts to parse as a double, returns null on failure.
  double? get toDoubleOrNull => double.tryParse(this);

  /// Truncates string with ellipsis if longer than [maxLength].
  String truncate(int maxLength) =>
      length > maxLength ? '${substring(0, maxLength)}…' : this;

  /// Converts snake_case to Title Case.
  String get fromSnakeCase =>
      split('_').map((w) => w.capitalised).join(' ');

  /// Returns display name for a species code.
  String get speciesDisplayName => LivestockConstants.displayName(this);

  /// Returns the species colour token.
  Color get speciesColor => AppColors.forSpecies(this);
}

extension NullableStringX on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
  String get orEmpty => this ?? '';
}

extension IntX on int {
  /// Formats as a compact number (e.g. 1234 → "1.2k")
  String get compact {
    if (this >= 1000000) return '${(this / 1000000).toStringAsFixed(1)}M';
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}k';
    return toString();
  }

  /// Returns ordinal suffix string (e.g. 1 → "1st", 2 → "2nd")
  String get ordinal {
    if (this >= 11 && this <= 13) return '${this}th';
    return switch (this % 10) {
      1 => '${this}st',
      2 => '${this}nd',
      3 => '${this}rd',
      _ => '${this}th',
    };
  }
}

extension DoubleX on double {
  /// Rounds to [decimals] decimal places.
  double roundTo(int decimals) {
    final factor = 10.0 * decimals;
    return (this * factor).round() / factor;
  }

  /// Converts kg to lb.
  double get kgToLb => this * 2.20462;

  /// Converts lb to kg.
  double get lbToKg => this / 2.20462;
}

extension DateTimeX on DateTime {
  /// Formats using the app standard date format (dd MMM yyyy).
  String get formatted {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '$day ${months[month - 1]} $year';
  }

  /// Returns "X days ago", "Today", "Yesterday", etc.
  String get relative {
    final now = DateTime.now();
    final diff = now.difference(this).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    if (diff < 30) return '${(diff / 7).floor()} weeks ago';
    if (diff < 365) return '${(diff / 30).floor()} months ago';
    return '${(diff / 365).floor()} years ago';
  }

  /// Returns true if this date is today.
  bool get isToday {
    final now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }

  /// Returns age in years from today.
  int get ageInYears {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Returns age as human-readable string (e.g. "2 years 3 months")
  String get ageString {
    final now = DateTime.now();
    final totalDays = now.difference(this).inDays;
    if (totalDays < 30) return '$totalDays days';
    if (totalDays < 365) {
      final months = (totalDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    }
    final years = (totalDays / 365).floor();
    final remainingMonths = ((totalDays % 365) / 30).floor();
    if (remainingMonths == 0) return '$years year${years > 1 ? 's' : ''}';
    return '$years year${years > 1 ? 's' : ''} $remainingMonths month${remainingMonths > 1 ? 's' : ''}';
  }

  /// Returns ISO-8601 date string (yyyy-MM-dd) for API calls.
  String get toApiDate =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

extension ListX<T> on List<T> {
  /// Returns null if list is empty, otherwise first element.
  T? get firstOrNull => isEmpty ? null : first;

  /// Returns null if list is empty, otherwise last element.
  T? get lastOrNull => isEmpty ? null : last;

  /// Splits list into sublists of [size].
  List<List<T>> chunked(int size) {
    final List<List<T>> chunks = [];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}

extension ColorX on Color {
  /// Returns a lightened version by mixing with white.
  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Returns a darkened version by mixing with black.
  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Returns white or black depending on luminance for maximum contrast.
  Color get contrastColor =>
      computeLuminance() > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
}
