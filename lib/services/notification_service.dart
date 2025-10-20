import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize timezone database
    // Initialize timezone database. If native timezone lookup isn't available
    // (some plugin/platform combinations), fall back to UTC.
    tz.initializeTimeZones();
    try {
      // Try to use the device local timezone if available via platform
      // Note: flutter_native_timezone may not be available on some configs; keep fallback.
      final String local = tz.local.name;
      tz.setLocalLocation(tz.getLocation(local));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Etc/UTC'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings,
        onDidReceiveNotificationResponse: (payload) {
      // handle notification tapped (payload may be null)
    });
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daypilot_channel',
        'DayPilot Notifications',
        channelDescription: 'Notifications for DayPilot app',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(id, title, body, details);
  }

  static Future<void> scheduleMorningReminder() async {
    await showNotification(
      id: 1,
      title: 'Good Morning! 🌅',
      body: 'Here\'s your plan for today. Let\'s make it productive!',
    );
  }

  static Future<void> scheduleNightReview() async {
    await showNotification(
      id: 2,
      title: 'Evening Review 📝',
      body: 'How was your day? Review and plan for tomorrow.',
    );
  }

  static Future<void> scheduleTaskReminder(String taskTitle) async {
    // simple immediate fallback
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Task Reminder ⏰',
      body: 'Don\'t forget: $taskTitle',
    );
  }

  /// Schedule a notification at [scheduledDate] in the local timezone.
  static Future<void> scheduleZonedNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    final NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daypilot_channel',
        'DayPilot Notifications',
        channelDescription: 'Notifications for DayPilot app',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel a scheduled notification by id
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}