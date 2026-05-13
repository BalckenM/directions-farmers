/// Web / unsupported platform stub — all calls are silent no-ops.
class NotificationService {
  NotificationService._();

  static Future<void> initialize() async {}

  static Future<void> scheduleVaccinationReminder({
    required int id,
    required String flockName,
    required String vaccineName,
    required DateTime dueDate,
  }) async {}

  static Future<void> showHealthAlert({
    required int id,
    required String title,
    required String body,
  }) async {}

  static Future<void> cancel(int id) async {}
  static Future<void> cancelAll() async {}
}
