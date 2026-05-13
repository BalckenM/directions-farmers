/// Form validators for FarmTrack input fields.
///
/// All methods return null on success or an error message string on failure.
abstract final class Validators {
  static const int _tagIdMaxLength = 30;
  static const int _nameMaxLength = 100;

  // ── Generic ───────────────────────────────────────────────────────────────────

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String fieldName = 'Field'}) {
    if (value != null && value.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String fieldName = 'Field'}) {
    if (value != null && value.trim().length > max) {
      return '$fieldName must not exceed $max characters';
    }
    return null;
  }

  // ── Numeric ───────────────────────────────────────────────────────────────────

  static String? positiveNumber(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    final n = double.tryParse(value);
    if (n == null) return '$fieldName must be a number';
    if (n <= 0) return '$fieldName must be greater than 0';
    return null;
  }

  static String? numberInRange(
    String? value,
    double min,
    double max, {
    String fieldName = 'Value',
  }) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    final n = double.tryParse(value);
    if (n == null) return '$fieldName must be a number';
    if (n < min || n > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }

  // ── Weight ────────────────────────────────────────────────────────────────────

  static String? weight(String? value, {double maxKg = 2000}) {
    if (value == null || value.trim().isEmpty) return 'Weight is required';
    final n = double.tryParse(value);
    if (n == null) return 'Enter a valid weight';
    if (n <= 0) return 'Weight must be greater than 0';
    if (n > maxKg) return 'Weight seems too high (max $maxKg kg)';
    return null;
  }

  // ── Animal identification ─────────────────────────────────────────────────────

  static String? tagId(String? value) {
    if (value == null || value.trim().isEmpty) return 'Tag ID is required';
    if (value.trim().length > _tagIdMaxLength) {
      return 'Tag ID must not exceed $_tagIdMaxLength characters';
    }
    // Allows alphanumeric and common separators
    if (!RegExp(r'^[a-zA-Z0-9\-_.]+$').hasMatch(value.trim())) {
      return 'Tag ID may only contain letters, numbers, hyphens, dots, underscores';
    }
    return null;
  }

  static String? animalName(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    if (value.trim().length > _nameMaxLength) {
      return 'Name must not exceed $_nameMaxLength characters';
    }
    return null;
  }

  // ── Date ──────────────────────────────────────────────────────────────────────

  static String? pastDate(DateTime? value, {String fieldName = 'Date'}) {
    if (value == null) return '$fieldName is required';
    if (value.isAfter(DateTime.now())) return '$fieldName cannot be in the future';
    return null;
  }

  static String? dateRange(DateTime? from, DateTime? to) {
    if (from == null || to == null) return 'Both dates are required';
    if (from.isAfter(to)) return '"From" date must be before "To" date';
    return null;
  }

  static String? birthDate(DateTime? value) {
    if (value == null) return 'Birth date is required';
    if (value.isAfter(DateTime.now())) {
      return 'Birth date cannot be in the future';
    }
    final maxAge = DateTime.now().subtract(const Duration(days: 365 * 30));
    if (value.isBefore(maxAge)) {
      return 'Birth date seems too far in the past';
    }
    return null;
  }

  // ── Contact / general text ────────────────────────────────────────────────────

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    if (!RegExp(r'^\+?[0-9\s\-()]{7,20}$').hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  // ── Body Condition Score ──────────────────────────────────────────────────────

  static String? bcs5(String? value) =>
      numberInRange(value, 1, 5, fieldName: 'BCS');

  static String? bcs9(String? value) =>
      numberInRange(value, 1, 9, fieldName: 'BCS');
}
