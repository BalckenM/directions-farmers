import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

/// Riverpod [ProviderObserver] that routes provider errors into [AppLogger].
///
/// Register in [ProviderScope] → `observers: [ProviderLoggerObserver()]`.
base class ProviderLoggerObserver extends ProviderObserver {
  const ProviderLoggerObserver();

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    AppLogger.error(
      'Provider failed: ${context.provider.name ?? context.provider.runtimeType}',
      tag: 'Riverpod',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (newValue is AsyncError) {
      AppLogger.error(
        'Provider async error: ${context.provider.name ?? context.provider.runtimeType}',
        tag: 'Riverpod',
        error: newValue.error,
        stackTrace: newValue.stackTrace,
      );
    }
  }
}
