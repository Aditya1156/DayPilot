import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daypilot/widgets/app_drawer.dart';
import 'package:daypilot/services/haptic_service.dart';
import 'package:table_calendar/table_calendar.dart';

/// Reminder Model
class Reminder {
  final String id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final ReminderCategory category;
  final bool isCompleted;

  Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    required this.category,
    this.isCompleted = false,
  });
}

enum ReminderCategory {
  work(Icons.work, Colors.blue),
  personal(Icons.person, Colors.purple),
  health(Icons.favorite, Colors.red),
  shopping(Icons.shopping_cart, Colors.green),
  other(Icons.notification_important, Colors.orange);

  final IconData icon;
  final Color color;
  const ReminderCategory(this.icon, this.color);
}

/// Enhanced Reminders Screen with calendar
class RemindersScreenEnhanced extends ConsumerStatefulWidget {
  const RemindersScreenEnhanced({super.key});

  @override
  ConsumerState<RemindersScreenEnhanced> createState() => _RemindersScreenEnhancedState();
}

class _RemindersScreenEnhancedState extends ConsumerState<RemindersScreenEnhanced> {
  final HapticService _haptic = HapticService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  // Sample reminders
  final List<Reminder> _reminders = [
    Reminder(
      id: '1',
      title: 'Team Meeting',
      description: 'Discuss Q1 goals and project updates',
      dateTime: DateTime.now().add(const Duration(hours: 2)),
      category: ReminderCategory.work,
    ),
    Reminder(
      id: '2',
      title: 'Gym Session',
      description: 'Leg day workout',
      dateTime: DateTime.now().add(const Duration(hours: 5)),
      category: ReminderCategory.health,
    ),
    Reminder(
      id: '3',
      title: 'Buy Groceries',
      description: 'Milk, eggs, bread, vegetables',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      category: ReminderCategory.shopping,
    ),
    Reminder(
      id: '4',
      title: 'Call Mom',
      description: 'Weekly catch-up call',
      dateTime: DateTime.now().add(const Duration(days: 2)),
      category: ReminderCategory.personal,
    ),
  ];

  List<Reminder> _getRemindersForDay(DateTime day) {
    return _reminders.where((reminder) {
      return isSameDay(reminder.dateTime, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDayReminders = _selectedDay != null
        ? _getRemindersForDay(_selectedDay!)
        : _getRemindersForDay(_focusedDay);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar.large(
            floating: true,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _haptic.lightImpact();
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            title: const Text('Reminders'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  _haptic.lightImpact();
                  _showAddReminderSheet(context, theme);
                },
              ),
            ],
          ),

          // Calendar
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  _haptic.lightImpact();
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                eventLoader: _getRemindersForDay,
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonDecoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  titleCentered: true,
                ),
              ),
            ),
          ),

          // Category Filter Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ReminderCategory.values.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(category.icon, size: 16),
                            const SizedBox(width: 4),
                            Text(category.name.toUpperCase()),
                          ],
                        ),
                        selected: false,
                        onSelected: (_) => _haptic.lightImpact(),
                        selectedColor: category.color.withOpacity(0.2),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Upcoming Reminders Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                selectedDayReminders.isEmpty
                    ? 'No reminders for this day'
                    : 'Reminders for ${_selectedDay != null ? _formatDate(_selectedDay!) : "Today"}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Reminders List
          if (selectedDayReminders.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildReminderCard(
                      selectedDayReminders[index],
                      theme,
                    );
                  },
                  childCount: selectedDayReminders.length,
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'All clear for this day!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // All Upcoming Reminders
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'All Upcoming Reminders',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildReminderCard(_reminders[index], theme);
                },
                childCount: _reminders.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _haptic.mediumImpact();
          _showAddReminderSheet(context, theme);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Reminder'),
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder, ThemeData theme) {
    final category = reminder.category;
    final isOverdue = reminder.dateTime.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            category.color.withOpacity(0.1),
            category.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: category.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _haptic.lightImpact();
            _showReminderDetails(reminder, theme);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(category.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (reminder.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          reminder.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: isOverdue ? Colors.red : category.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(reminder.dateTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue ? Colors.red : category.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isOverdue) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'OVERDUE',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) return 'Today';
    if (isSameDay(date, now.add(const Duration(days: 1)))) return 'Tomorrow';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inMinutes < 60) {
      return 'In ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'In ${difference.inHours}h';
    } else {
      return '${dateTime.day}/${dateTime.month} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showReminderDetails(Reminder reminder, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: reminder.category.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      reminder.category.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      reminder.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (reminder.description != null) ...[
                const SizedBox(height: 16),
                Text(
                  reminder.description!,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.access_time, color: reminder.category.color),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateTime(reminder.dateTime),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: reminder.category.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _haptic.lightImpact();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        _haptic.success();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddReminderSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Reminder',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      _haptic.success();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Reminder'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
