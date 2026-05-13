import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pre-loaded [SharedPreferences] instance.
/// Override this in [ProviderScope] via [main.dart] after calling
/// [SharedPreferences.getInstance()] before [runApp].
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope.',
  ),
);
