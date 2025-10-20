import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:daypilot/models/task.dart';
import 'package:daypilot/services/notification_service.dart';
import 'package:daypilot/services/recurrence_service.dart';

/// Example providers to get started. Expand these with real implementations.

final greetingProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
});

// Hive box for tasks
final tasksBoxProvider = Provider<Box<Task>>((ref) {
  return Hive.box<Task>('tasks');
});

// Tasks list from Hive
final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  final box = ref.watch(tasksBoxProvider);
  return TasksNotifier(box);
});

class TasksNotifier extends StateNotifier<List<Task>> {
  final Box<Task> _box;

  TasksNotifier(this._box) : super(_box.values.toList()) {
    _box.watch().listen((event) {
      state = _box.values.toList();
    });
  }

  void addTask(Task task) {
    _box.put(task.id, task);

    // Schedule notification. If the task has a recurrence rule, compute the next
    // occurrence and schedule that one, persisting the lastScheduledOccurrenceMillis
    // so future runs can continue scheduling the following occurrences.
    try {
      final int nid = task.id.hashCode & 0x7fffffff; // positive id

      if (task.rrule != null && task.rrule!.trim().isNotEmpty) {
        // Compute next occurrence after either the last scheduled occurrence or now
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
          // Schedule using the task's reminder offset (minutes before occurrence)
          final scheduled = occurrence.subtract(Duration(minutes: task.reminderOffsetMinutes));
          final scheduledDate = scheduled.isAfter(DateTime.now()) ? scheduled : occurrence;
          NotificationService.scheduleZonedNotification(
            id: nid,
            title: 'Upcoming: ${task.title}',
            body:
                'Starts at ${occurrence.hour.toString().padLeft(2, '0')}:${occurrence.minute.toString().padLeft(2, '0')}',
            scheduledDate: scheduledDate,
          );

          // Persist last scheduled occurrence
          final updated = task.copyWith(lastScheduledOccurrenceMillis: occurrence.millisecondsSinceEpoch);
          _box.put(updated.id, updated);
        }
      } else {
        // Non-recurring task: schedule single reminder 10 minutes before start
        if (task.startTime.isAfter(DateTime.now())) {
          final scheduled = task.startTime.subtract(Duration(minutes: task.reminderOffsetMinutes));
          final scheduledDate = scheduled.isAfter(DateTime.now()) ? scheduled : task.startTime;
          NotificationService.scheduleZonedNotification(
            id: nid,
            title: 'Upcoming: ${task.title}',
            body:
                'Starts at ${task.startTime.hour.toString().padLeft(2, '0')}:${task.startTime.minute.toString().padLeft(2, '0')}',
            scheduledDate: scheduledDate,
          );
        }
      }
    } catch (e) {
      // ignore scheduling errors to keep app resilient
    }
  }

  void updateTask(Task task) {
    _box.put(task.id, task);

    // Cancel existing and reschedule (recurrence-aware)
    try {
      final int nid = task.id.hashCode & 0x7fffffff;
      NotificationService.cancelNotification(nid);

      if (task.rrule != null && task.rrule!.trim().isNotEmpty) {
        // For recurring tasks, compute the next occurrence after the last scheduled occurrence or now
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
          NotificationService.scheduleZonedNotification(
            id: nid,
            title: 'Upcoming: ${task.title}',
            body:
                'Starts at ${occurrence.hour.toString().padLeft(2, '0')}:${occurrence.minute.toString().padLeft(2, '0')}',
            scheduledDate: scheduledDate,
          );

          // Persist last scheduled occurrence
          final updated = task.copyWith(lastScheduledOccurrenceMillis: occurrence.millisecondsSinceEpoch);
          _box.put(updated.id, updated);
        }
      } else {
        // Non-recurring: schedule single reminder
        if (task.startTime.isAfter(DateTime.now())) {
          final scheduled = task.startTime.subtract(Duration(minutes: task.reminderOffsetMinutes));
          final scheduledDate = scheduled.isAfter(DateTime.now()) ? scheduled : task.startTime;
          NotificationService.scheduleZonedNotification(
            id: nid,
            title: 'Upcoming: ${task.title}',
            body:
                'Starts at ${task.startTime.hour.toString().padLeft(2, '0')}:${task.startTime.minute.toString().padLeft(2, '0')}',
            scheduledDate: scheduledDate,
          );
        }
      }
    } catch (e) {
      // ignore
    }
  }

  void deleteTask(String id) {
    // Cancel scheduled notification
    try {
      final int nid = id.hashCode & 0x7fffffff;
      NotificationService.cancelNotification(nid);
    } catch (e) {
      // ignore
    }
    _box.delete(id);
  }
}
