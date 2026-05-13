import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/debug_console.dart';
import 'features/poultry/providers/poultry_providers.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  bool _notificationsScheduled = false;

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Schedule vaccination reminders once per app launch when data is ready
    if (!_notificationsScheduled) {
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

    return MaterialApp.router(
      title: '4Directions Farm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: kDebugMode
          ? (context, child) => DebugConsoleOverlay(child: child!)
          : null,
    );
  }
}

