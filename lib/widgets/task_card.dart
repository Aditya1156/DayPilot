import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:daypilot/models/task.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

    @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            task.categoryColor.withAlpha((0.12 * 255).round()),
            task.categoryColor.withAlpha((0.05 * 255).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: task.categoryColor.withAlpha((0.06 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withAlpha((0.12 * 255).round()),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withAlpha((0.8 * 255).round()),
              borderRadius: BorderRadius.circular(20),
            ),
            
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                        // Header with category and status (constrained to prevent overflow)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: task.categoryColor.withAlpha((0.18 * 255).round()),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: task.categoryColor.withAlpha((0.25 * 255).round()),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      task.categoryIcon,
                                      size: 14,
                                      color: task.categoryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        task.category.name.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: task.categoryColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _buildStatusIndicator(context),
                            ),
                          ],
                        ),
                    const SizedBox(height: 12),

                    // Task title with animation
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: Colors.grey,
                      ) ?? const TextStyle(),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),

                    // Task description if available
                    if (task.description != null) ...[
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 40),
                        child: Text(
                          task.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Time and duration
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${timeFormat.format(task.startTime)} - ${timeFormat.format(task.endTime)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    switch (task.status) {
      case TaskStatus.completed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
            color: Colors.green.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                'Done',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      case TaskStatus.inProgress:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
            color: Colors.blue.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timelapse,
                color: Colors.blue,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                'Now',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      case TaskStatus.missed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
            color: Colors.red.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cancel,
                color: Colors.red,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                'Missed',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      case TaskStatus.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                color: Colors.grey[600],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Todo',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
    }
  }
}