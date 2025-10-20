import 'package:flutter/material.dart';
import 'package:daypilot/models/task.dart';

/// Search delegate for finding tasks quickly
class TaskSearchDelegate extends SearchDelegate<Task?> {
  final List<Task> tasks;

  TaskSearchDelegate(this.tasks);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final theme = Theme.of(context);
    
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: theme.colorScheme.primary.withAlpha((0.5 * 255).round()),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for tasks',
              style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                ),
            ),
          ],
        ),
      );
    }

    final results = tasks.where((task) {
      final titleLower = task.title.toLowerCase();
      final queryLower = query.toLowerCase();
      return titleLower.contains(queryLower);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.error.withAlpha((0.5 * 255).round()),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks found',
                style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
                style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha((0.5 * 255).round()),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final task = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getCategoryColor(task.category, theme),
            child: Icon(
              _getCategoryIcon(task.category),
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.status == TaskStatus.completed
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          subtitle: Text(
            task.category.name.toUpperCase(),
            style: theme.textTheme.bodySmall,
          ),
          trailing: Icon(
            task.status == TaskStatus.completed
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: task.status == TaskStatus.completed
                ? Colors.green
                : theme.colorScheme.outline,
          ),
          onTap: () {
            close(context, task);
          },
        );
      },
    );
  }

  Color _getCategoryColor(TaskCategory category, ThemeData theme) {
    switch (category) {
      case TaskCategory.work:
        return Colors.blue;
      case TaskCategory.personal:
        return Colors.purple;
      case TaskCategory.health:
        return Colors.green;
      case TaskCategory.study:
        return Colors.orange;
      case TaskCategory.others:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.health:
        return Icons.favorite;
      case TaskCategory.study:
        return Icons.school;
      case TaskCategory.others:
        return Icons.more_horiz;
    }
  }
}
