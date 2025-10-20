import 'package:hive/hive.dart';
import 'package:daypilot/models/task.dart';
import 'package:daypilot/services/recurrence_service.dart';
import 'package:daypilot/services/notification_service.dart';

class SchedulerService {
  /// Scan all tasks and ensure the next notification is scheduled.
  /// This is safe to run on app start.
  static Future<void> schedulePendingTasks() async {
    try {
      final box = Hive.box<Task>('tasks');
      for (final task in box.values) {
        try {
          final int nid = task.id.hashCode & 0x7fffffff;
          // Cancel any dangling scheduled notification and re-schedule deterministically
          await NotificationService.cancelNotification(nid);

          if (task.rrule != null && task.rrule!.trim().isNotEmpty) {
            final from = task.lastScheduledOccurrenceMillis != null
                ? DateTime.fromMillisecondsSinceEpoch(task.lastScheduledOccurrenceMillis!).add(const Duration(seconds: 1))
                : DateTime.now();
            final next = RecurrenceService.expandNext(
              rrule: task.rrule,
              start: task.startTime,
              from: from,
              count: 1,
            );
            if (next.isNotEmpty) {
              final occurrence = next.first;
              final scheduled = occurrence.subtract(Duration(minutes: task.reminderOffsetMinutes));
              final scheduledDate = scheduled.isAfter(DateTime.now()) ? scheduled : occurrence;
              await NotificationService.scheduleZonedNotification(
                id: nid,
                title: 'Upcoming: ${task.title}',
                body: 'Starts at ${occurrence.hour.toString().padLeft(2, '0')}:${occurrence.minute.toString().padLeft(2, '0')}',
                scheduledDate: scheduledDate,
              );
              final updated = task.copyWith(lastScheduledOccurrenceMillis: occurrence.millisecondsSinceEpoch);
              await box.put(updated.id, updated);
            }
          } else {
            // Non-recurring task: if start is in future, schedule it
            if (task.startTime.isAfter(DateTime.now())) {
              final scheduled = task.startTime.subtract(Duration(minutes: task.reminderOffsetMinutes));
              final scheduledDate = scheduled.isAfter(DateTime.now()) ? scheduled : task.startTime;
              await NotificationService.scheduleZonedNotification(
                id: nid,
                title: 'Upcoming: ${task.title}',
                body: 'Starts at ${task.startTime.hour.toString().padLeft(2, '0')}:${task.startTime.minute.toString().padLeft(2, '0')}',
                scheduledDate: scheduledDate,
              );
            }
          }
        } catch (_) {
          // ignore per-task errors to allow scanning to continue
        }
      }
    } catch (e) {
      // top-level failure should not crash the app
    }
  }
}
