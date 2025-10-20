import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daypilot/models/task.dart';
import 'package:daypilot/providers/app_providers.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Text(
                'No tasks yet. Tap + to add one.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final t = tasks[idx];
                return Dismissible(
                  key: Key(t.id),
                  background: Container(color: Colors.green, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 16), child: const Icon(Icons.check, color: Colors.white)),
                  secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // mark complete
                      t.status = TaskStatus.completed;
                      ref.read(tasksProvider.notifier).updateTask(t);
                      return false;
                    } else {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete task'),
                          content: Text('Delete "${t.title}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        ref.read(tasksProvider.notifier).deleteTask(t.id);
                      }
                      return ok ?? false;
                    }
                  },
                  child: ListTile(
                    tileColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    title: Text(t.title),
                    subtitle: t.description != null ? Text(t.description!) : null,
                    leading: CircleAvatar(
                      backgroundColor: t.categoryColor.withOpacity(0.12),
                      child: Icon(t.categoryIcon, color: t.categoryColor),
                    ),
                    trailing: Text(t.status.toString().split('.').last),
                    onTap: () async {
                      // open editor
                      Navigator.pushNamed(context, '/task-editor', arguments: t.id);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/task-editor'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
