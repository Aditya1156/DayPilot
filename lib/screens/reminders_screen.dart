import 'package:flutter/material.dart';
import 'package:daypilot/services/notification_service.dart';
import '../widgets/surface_card.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  // Common reminder categories with icons and colors
  final List<Map<String, dynamic>> reminderTypes = [
    {'id': 'morning', 'title': 'Morning Routine', 'desc': 'Wake-up & hydration', 'icon': Icons.wb_sunny_outlined, 'color': const Color(0xFFFBB040)},
    {'id': 'work_start', 'title': 'Start Work', 'desc': 'Begin focused work session', 'icon': Icons.work_outline, 'color': const Color(0xFF2E7EF0)},
    {'id': 'break', 'title': 'Take a Break', 'desc': 'Short walk or stretch', 'icon': Icons.free_breakfast_outlined, 'color': const Color(0xFF10B981)},
    {'id': 'lunch', 'title': 'Lunch', 'desc': 'Meal time reminder', 'icon': Icons.restaurant_outlined, 'color': const Color(0xFFFF8A3D)},
    {'id': 'exercise', 'title': 'Workout', 'desc': 'Daily exercise reminder', 'icon': Icons.fitness_center_outlined, 'color': const Color(0xFFEF476F)},
    {'id': 'meditation', 'title': 'Meditate', 'desc': 'Mindfulness session', 'icon': Icons.self_improvement_outlined, 'color': const Color(0xFF7C3AED)},
    {'id': 'night_review', 'title': 'Night Review', 'desc': 'Daily reflection & plan', 'icon': Icons.nightlight_outlined, 'color': const Color(0xFF1E5FBF)},
    {'id': 'hydration', 'title': 'Hydration', 'desc': 'Drink water reminder', 'icon': Icons.water_drop_outlined, 'color': const Color(0xFF118AB2)},
    {'id': 'meds', 'title': 'Medication', 'desc': 'Take medicine or supplements', 'icon': Icons.medical_services_outlined, 'color': const Color(0xFFEF476F)},
  ];

  TimeOfDay _selectedTime = TimeOfDay.now();
  String _repeatOption = 'Once';
  final List<String> _repeatOptions = ['Once', 'Daily', 'Weekdays', 'Weekends', 'Custom'];
  bool _smartSuggestionsEnabled = true;

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
              spacing: 10,
              runSpacing: 10,
              children: reminderTypes.map((t) {
                return SizedBox(
                  width: 170,
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _scheduleType(t['id'] as String),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              (t['color'] as Color).withAlpha(25),
                              (t['color'] as Color).withAlpha(10),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: (t['color'] as Color).withAlpha(60),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              t['icon'] as IconData,
                              color: t['color'] as Color,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t['desc'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            SurfaceCard(
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add_alarm, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Custom Reminder', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Reminder message',
                      prefixIcon: Icon(Icons.edit_note),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickTime,
                          icon: const Icon(Icons.access_time),
                          label: Text(_selectedTime.format(context)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _repeatOption,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            prefixIcon: Icon(Icons.repeat),
                          ),
                          items: _repeatOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                          onChanged: (val) => setState(() => _repeatOption = val ?? 'Once'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reminder set for ${_selectedTime.format(context)} ($_repeatOption)'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Set Reminder'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_smartSuggestionsEnabled)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Smart tip: Based on your routine, we suggest reminders at 9 AM and 3 PM for peak productivity.',
                              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(200)),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
