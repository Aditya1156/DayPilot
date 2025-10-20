import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';
import 'dart:typed_data';
import '../models/task.dart';
import '../models/gamification.dart';

/// Smart alarm and reminder system with habit-sensitive features
class SmartAlarmService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== INITIALIZATION ====================

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
  }

  void _handleNotificationTap(NotificationResponse response) {
    // Handle notification tap - navigate to appropriate screen
    print('Notification tapped: ${response.payload}');
  }

  // ==================== HABIT-SENSITIVE ALARMS ====================

  /// Schedules an alarm with dynamic tone based on streak
  Future<void> scheduleHabitSensitiveAlarm({
    required String userId,
    required DateTime scheduledTime,
    required String title,
    required String body,
    required int alarmId,
  }) async {
    try {
      // Get user's current streak
      final progressDoc = await _firestore
          .collection('user_progress')
          .doc(userId)
          .get();

      int streak = 0;
      if (progressDoc.exists) {
        final progress = UserProgress.fromMap(progressDoc.data()!);
        streak = progress.currentStreak;
      }

      // Choose sound based on streak
      final sound = _getSoundForStreak(streak);
      
      // Customize message based on streak
      final customBody = _getMotivationalMessage(body, streak);

      await _scheduleNotification(
        id: alarmId,
        title: title,
        body: customBody,
        scheduledTime: scheduledTime,
        sound: sound,
        payload: 'habit_alarm_$userId',
      );

      // Save alarm info
      await _saveAlarmInfo(
        userId: userId,
        alarmId: alarmId,
        type: 'habit_sensitive',
        scheduledTime: scheduledTime,
        metadata: {'streak': streak, 'sound': sound},
      );
    } catch (e) {
      print('Error scheduling habit-sensitive alarm: $e');
    }
  }

  String _getSoundForStreak(int streak) {
    if (streak >= 30) return 'champion_sound.mp3';
    if (streak >= 14) return 'warrior_sound.mp3';
    if (streak >= 7) return 'motivated_sound.mp3';
    if (streak >= 3) return 'encouraging_sound.mp3';
    return 'gentle_wake.mp3';
  }

  String _getMotivationalMessage(String baseMessage, int streak) {
    if (streak >= 30) {
      return '🏆 30-day streak! You\'re unstoppable! $baseMessage';
    } else if (streak >= 14) {
      return '🔥 ${streak}-day streak! Keep the momentum! $baseMessage';
    } else if (streak >= 7) {
      return '💪 ${streak} days strong! $baseMessage';
    } else if (streak >= 3) {
      return '⭐ ${streak}-day streak going! $baseMessage';
    }
    return baseMessage;
  }

  // ==================== TASK-LINKED ALARMS ====================

  /// Schedules alarm that checks for pending linked tasks
  Future<void> scheduleTaskLinkedAlarm({
    required String userId,
    required DateTime scheduledTime,
    required List<String> linkedTaskIds,
    required String title,
    int alarmId = 0,
  }) async {
    try {
      // Check if linked tasks are pending
      final hasPendingTasks = await _checkPendingTasks(userId, linkedTaskIds);

      if (!hasPendingTasks) {
        print('No pending linked tasks, skipping alarm');
        return;
      }

      // Get task details for personalized message
      final taskTitles = await _getTaskTitles(linkedTaskIds);
      final body = 'You have ${taskTitles.length} pending tasks: ${taskTitles.join(", ")}';

      await _scheduleNotification(
        id: alarmId,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        sound: 'task_reminder.mp3',
        payload: 'task_linked_$userId',
      );

      await _saveAlarmInfo(
        userId: userId,
        alarmId: alarmId,
        type: 'task_linked',
        scheduledTime: scheduledTime,
        metadata: {'linkedTaskIds': linkedTaskIds},
      );
    } catch (e) {
      print('Error scheduling task-linked alarm: $e');
    }
  }

  Future<bool> _checkPendingTasks(String userId, List<String> taskIds) async {
    for (var taskId in taskIds) {
      final taskDoc = await _firestore
          .collection('tasks')
          .doc(taskId)
          .get();

      if (taskDoc.exists) {
        final task = Task.fromMap(taskDoc.data()!);
        if (task.status == TaskStatus.pending) {
          return true;
        }
      }
    }
    return false;
  }

  Future<List<String>> _getTaskTitles(List<String> taskIds) async {
    final titles = <String>[];
    
    for (var taskId in taskIds) {
      final taskDoc = await _firestore
          .collection('tasks')
          .doc(taskId)
          .get();

      if (taskDoc.exists) {
        final task = Task.fromMap(taskDoc.data()!);
        titles.add(task.title);
      }
    }

    return titles;
  }

  // ==================== VOICE-BASED WAKE PROMPTS ====================

  /// Schedules voice-based motivational alarm
  Future<void> scheduleVoiceWakePrompt({
    required String userId,
    required String userName,
    required DateTime scheduledTime,
    required String upcomingActivity,
    int alarmId = 0,
  }) async {
    try {
      // Generate personalized voice prompt
      final voicePrompts = [
        'Hey $userName, you\'ve got $upcomingActivity in 15 minutes! Time to rise and shine! 🌟',
        'Good morning $userName! $upcomingActivity is waiting. Let\'s make today amazing! 💪',
        'Rise and grind, $userName! Your $upcomingActivity starts soon. You\'ve got this! 🚀',
        '$userName, wake up champion! $upcomingActivity is calling. Time to dominate the day! 🏆',
      ];

      final random = Random();
      final selectedPrompt = voicePrompts[random.nextInt(voicePrompts.length)];

      await _scheduleNotification(
        id: alarmId,
        title: '⏰ Time to Wake Up!',
        body: selectedPrompt,
        scheduledTime: scheduledTime,
        sound: 'voice_motivational.mp3',
        payload: 'voice_wake_$userId',
        priority: Priority.high,
        importance: Importance.max,
      );

      await _saveAlarmInfo(
        userId: userId,
        alarmId: alarmId,
        type: 'voice_wake',
        scheduledTime: scheduledTime,
        metadata: {
          'userName': userName,
          'upcomingActivity': upcomingActivity,
        },
      );
    } catch (e) {
      print('Error scheduling voice wake prompt: $e');
    }
  }

  // ==================== SMART REMINDERS ====================

  /// Schedules smart reminder that adapts to user's productivity patterns
  Future<void> scheduleSmartReminder({
    required String userId,
    required Task task,
    required DateTime reminderTime,
  }) async {
    try {
      // Get user's productivity data for the reminder time
      final timeSlot = _getTimeSlot(reminderTime);
      final isHighProductivityTime = await _isHighProductivitySlot(userId, timeSlot);

      // Adjust reminder tone based on productivity time
      String title;
      String sound;

      if (isHighProductivityTime) {
        title = '⚡ Peak Time Alert';
        sound = 'energetic_reminder.mp3';
      } else {
        title = '📋 Gentle Reminder';
        sound = 'gentle_reminder.mp3';
      }

      final body = '${task.title} starts in ${task.reminderOffsetMinutes} minutes';

      await _scheduleNotification(
        id: task.id.hashCode,
        title: title,
        body: body,
        scheduledTime: reminderTime,
        sound: sound,
        payload: 'smart_reminder_${task.id}',
      );
    } catch (e) {
      print('Error scheduling smart reminder: $e');
    }
  }

  Future<bool> _isHighProductivitySlot(String userId, String timeSlot) async {
    try {
      final snapshot = await _firestore
          .collection('user_analytics')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(7)
          .get();

      if (snapshot.docs.isEmpty) return false;

      double avgScore = 0;
      int count = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final productivityData = data['productivityData'] as Map<String, dynamic>?;
        
        if (productivityData != null && productivityData.containsKey(timeSlot)) {
          avgScore += (productivityData[timeSlot]['score'] ?? 0.0) as double;
          count++;
        }
      }

      if (count == 0) return false;

      return (avgScore / count) > 70.0; // High productivity threshold
    } catch (e) {
      print('Error checking productivity slot: $e');
      return false;
    }
  }

  String _getTimeSlot(DateTime time) {
    final hour = time.hour;
    if (hour >= 6 && hour < 9) return '06:00-09:00';
    if (hour >= 9 && hour < 12) return '09:00-12:00';
    if (hour >= 12 && hour < 15) return '12:00-15:00';
    if (hour >= 15 && hour < 18) return '15:00-18:00';
    if (hour >= 18 && hour < 21) return '18:00-21:00';
    return '21:00-00:00';
  }

  // ==================== CORE NOTIFICATION SCHEDULING ====================

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String sound,
    String? payload,
    Priority priority = Priority.high,
    Importance importance = Importance.high,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarms',
      channelDescription: 'Smart alarm notifications',
      importance: importance,
      priority: priority,
      sound: RawResourceAndroidNotificationSound(sound.replaceAll('.mp3', '')),
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      fullScreenIntent: true,
    );

    final iosDetails = DarwinNotificationDetails(
      sound: sound,
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // ==================== ALARM MANAGEMENT ====================

  Future<void> _saveAlarmInfo({
    required String userId,
    required int alarmId,
    required String type,
    required DateTime scheduledTime,
    Map<String, dynamic>? metadata,
  }) async {
    await _firestore.collection('alarms').doc('${userId}_$alarmId').set({
      'userId': userId,
      'alarmId': alarmId,
      'type': type,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'metadata': metadata ?? {},
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  /// Cancels a specific alarm
  Future<void> cancelAlarm(int alarmId) async {
    await _notifications.cancel(alarmId);
  }

  /// Cancels all alarms for a user
  Future<void> cancelAllAlarmsForUser(String userId) async {
    final snapshot = await _firestore
        .collection('alarms')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .get();

    for (var doc in snapshot.docs) {
      final alarmId = doc.data()['alarmId'] as int;
      await cancelAlarm(alarmId);
      await doc.reference.update({'isActive': false});
    }
  }

  /// Gets all active alarms for a user
  Future<List<Map<String, dynamic>>> getActiveAlarms(String userId) async {
    final snapshot = await _firestore
        .collection('alarms')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('scheduledTime')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
