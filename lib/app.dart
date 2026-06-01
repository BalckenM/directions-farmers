import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_app/core/providers/theme_provider.dart';
import 'package:mobile_app/core/router/app_router.dart';
import 'package:mobile_app/core/services/notification_service.dart';
import 'package:mobile_app/core/services/session_timeout_service.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/widgets/debug_console.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:mobile_app/features/poultry/providers/poultry_providers.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  bool _notificationsScheduled = false;
  late final SessionTimeoutService _sessionTimeout;

  @override
  void initState() {
    super.initState();
    _sessionTimeout = SessionTimeoutService(
      onSessionExpired: _handleSessionExpired,
    );
    _sessionTimeout.initialize();
  }

  @override
  void dispose() {
    _sessionTimeout.dispose();
    super.dispose();
  }

  void _handleSessionExpired() {
    if (ref.read(isAuthenticatedProvider)) {
      ref.read(authProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Schedule vaccination reminders once per app launch when data is ready
    if (!_notificationsScheduled && ref.watch(isAuthenticatedProvider)) {
      final dueSoonAsync = ref.watch(dueSoonVaccinationsProvider);
      dueSoonAsync.whenData((items) {
        if (items.isEmpty) return;
        _notificationsScheduled = true;
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          NotificationService.scheduleVaccinationReminder(
            id: item.flockId.hashCode ^ item.vaccine.hashCode ^ i,
            flockName: item.flockName,
            vaccineName: item.vaccine,
            dueDate: item.dueDate,
          );
        }
      });
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _sessionTimeout.recordActivity(),
      child: MaterialApp.router(
        title: '4Directions Farm',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('af')],
        builder: kDebugMode
            ? (context, child) => DebugConsoleOverlay(
                navigatorKey: router.routerDelegate.navigatorKey,
                child: child!,
              )
            : null,
      ),
    );
  }
}
