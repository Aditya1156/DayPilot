import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:daypilot/models/task.dart';

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
  }

  void updateTask(Task task) {
    _box.put(task.id, task);
  }

  void deleteTask(String id) {
    _box.delete(id);
  }
}
