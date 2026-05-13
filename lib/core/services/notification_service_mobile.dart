import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Mobile / desktop implementation of [NotificationService].
/// Never imported on web — see notification_service.dart for the export trick.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialised = false;

  // ── Channels ───────────────────────────────────────────────────────────────
  static const _channelVaccination = AndroidNotificationChannel(
    'poultry_vaccination',
    'Vaccination Reminders',
    description: 'Scheduled vaccination and health procedure reminders.',
    importance: Importance.high,
  );

  static const _channelHealth = AndroidNotificationChannel(
    'poultry_health',
    'Health Alerts',
    description: 'Mortality spikes, disease alerts, and biosecurity warnings.',
    importance: Importance.max,
  );

  // ── Init ───────────────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    if (_initialised) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings: settings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_channelVaccination);
      await androidPlugin.createNotificationChannel(_channelHealth);
      await androidPlugin.requestNotificationsPermission();
    }

    _initialised = true;
  }

  // ── Vaccination reminder ───────────────────────────────────────────────────
  static Future<void> scheduleVaccinationReminder({
    required int id,
    required String flockName,
    required String vaccineName,
    required DateTime dueDate,
  }) async {
    if (!_initialised) return;

    final dueDateStr =
        '${dueDate.day.toString().padLeft(2, '0')}/'
        '${dueDate.month.toString().padLeft(2, '0')}/'
        '${dueDate.year}';

    await _plugin.show(
      id: id,
      title: 'Vaccination due — $flockName',
      body: '$vaccineName due on $dueDateStr',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelVaccination.id,
          _channelVaccination.name,
          channelDescription: _channelVaccination.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ── Health alert ───────────────────────────────────────────────────────────
  static Future<void> showHealthAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialised) return;

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelHealth.id,
          _channelHealth.name,
          channelDescription: _channelHealth.description,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ── Cancel ─────────────────────────────────────────────────────────────────
  static Future<void> cancel(int id) => _plugin.cancel(id: id);
  static Future<void> cancelAll() => _plugin.cancelAll();
}
