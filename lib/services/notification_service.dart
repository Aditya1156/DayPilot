import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);
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
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Task Reminder ⏰',
      body: 'Don\'t forget: $taskTitle',
    );
  }
}