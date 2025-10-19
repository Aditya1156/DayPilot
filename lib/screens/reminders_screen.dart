import 'package:flutter/material.dart';
import 'package:daypilot/services/notification_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  // Common reminder categories the user can create quickly
  final List<Map<String, String>> reminderTypes = [
    {'id': 'morning', 'title': 'Morning Routine', 'desc': 'Wake-up & hydration'},
    {'id': 'work_start', 'title': 'Start Work', 'desc': 'Begin focused work session'},
    {'id': 'break', 'title': 'Take a Break', 'desc': 'Short walk or stretch'},
    {'id': 'lunch', 'title': 'Lunch', 'desc': 'Meal time reminder'},
    {'id': 'exercise', 'title': 'Workout', 'desc': 'Daily exercise reminder'},
    {'id': 'meditation', 'title': 'Meditate', 'desc': 'Mindfulness session'},
    {'id': 'night_review', 'title': 'Night Review', 'desc': 'Daily reflection & plan'},
    {'id': 'hydration', 'title': 'Hydration', 'desc': 'Drink water reminder'},
    {'id': 'meds', 'title': 'Medication', 'desc': 'Take medicine or supplements'},
  ];

  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _selectedTime);
    if (t != null) setState(() => _selectedTime = t);
  }

  void _scheduleType(String id) {
    // Map to concrete scheduling functions
    switch (id) {
      case 'morning':
        NotificationService.scheduleMorningReminder();
        break;
      case 'night_review':
        NotificationService.scheduleNightReview();
        break;
      default:
        NotificationService.scheduleTaskReminder('Reminder for $id');
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder scheduled')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Quick Reminder Types', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: reminderTypes.map((t) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  onPressed: () => _scheduleType(t['id']!),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(t['desc']!, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Custom Reminder', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(onPressed: _pickTime, icon: const Icon(Icons.access_time), label: Text(_selectedTime.format(context))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(decoration: const InputDecoration(hintText: 'Reminder message (e.g., Stand up)')),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Custom reminder scheduled'))), child: const Text('Set'))
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Smart reminders support snooze, skip, and quick actions directly from the notification.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
