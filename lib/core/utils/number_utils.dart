import 'package:intl/intl.dart';

/// Number and currency formatting utilities for FarmTrack.
abstract final class NumberUtils {
  static final NumberFormat _compactFormat = NumberFormat.compact();
  static final NumberFormat _decimalFormat = NumberFormat('#,##0.##');
  static final NumberFormat _intFormat = NumberFormat('#,##0');
  static final NumberFormat _percentFormat = NumberFormat('#,##0.#%');

  /// Formats a number with thousands separators (e.g. 1,234.56)
  static String format(num value, {int? decimals}) {
    if (decimals != null) {
      return NumberFormat('#,##0.${'0' * decimals}').format(value);
    }
    return _decimalFormat.format(value);
  }

  /// Formats an integer with thousands separators (e.g. 1,234)
  static String formatInt(num value) => _intFormat.format(value);

  /// Compact format (e.g. 1234 → "1.2K", 1000000 → "1M")
  static String compact(num value) => _compactFormat.format(value);

  /// Formats as a percentage (e.g. 0.845 → "84.5%")
  static String percent(num value) => _percentFormat.format(value);

  /// Formats weight with unit (e.g. "245.5 kg")
  static String weight(num value, String unit, {int decimals = 1}) {
    return '${format(value, decimals: decimals)} $unit';
  }

  /// Formats volume with unit (e.g. "18.5 L")
  static String volume(num value, String unit, {int decimals = 1}) {
    return '${format(value, decimals: decimals)} $unit';
  }

  /// Formats currency with symbol (e.g. "R 1,250.00")
  static String currency(
    num value, {
    String symbol = 'R',
    int decimals = 2,
  }) {
    return '$symbol ${format(value, decimals: decimals)}';
  }

  /// Returns a trend string with arrow (e.g. "↑ 12.5%", "↓ 3.2%")
  static String trend(num currentValue, num previousValue) {
    if (previousValue == 0) return '—';
    final change = (currentValue - previousValue) / previousValue;
    final arrow = change >= 0 ? '↑' : '↓';
    return '$arrow ${percent(change.abs())}';
  }

  /// Safely converts dynamic value to double, returns 0.0 on failure.
  static double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Safely converts dynamic value to int, returns 0 on failure.
  static int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Clamps a value between [min] and [max].
  static num clamp(num value, num min, num max) => value.clamp(min, max);
}
