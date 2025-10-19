import 'package:flutter/material.dart';
import 'package:daypilot/services/notification_service.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => NotificationService.scheduleMorningReminder(),
              child: const Text('Send Morning Reminder'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => NotificationService.scheduleNightReview(),
              child: const Text('Send Night Review'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => NotificationService.scheduleTaskReminder('Sample Task'),
              child: const Text('Send Task Reminder'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Smart reminders and notification actions (snooze/skip/done).',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
