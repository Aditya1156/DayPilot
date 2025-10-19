import 'package:flutter/material.dart';

class RoutineBuilderScreen extends StatefulWidget {
  const RoutineBuilderScreen({super.key});

  @override
  State<RoutineBuilderScreen> createState() => _RoutineBuilderScreenState();
}

class _RoutineBuilderScreenState extends State<RoutineBuilderScreen> {
  // UI-first categories for building routines. These are intentionally broader
  // than the internal TaskCategory enum so the UX can present meaningful options.
  final List<String> availableCategories = [
    'Work',
    'Study',
    'Exercise',
    'Meditation',
    'Sleep',
    'Meals',
    'Personal Care',
    'Errands',
    'Family',
    'Hobby',
    'Commute',
  ];

  // Example routine items (title, minutes, category)
  List<Map<String, dynamic>> routine = [
    {'title': 'Morning Stretch', 'mins': 10, 'category': 'Exercise'},
    {'title': 'Focus Work Block', 'mins': 90, 'category': 'Work'},
    {'title': 'Lunch', 'mins': 45, 'category': 'Meals'},
  ];

  // Simple AI suggestions placeholder
  final List<String> aiSuggestions = [
    'Move lunch 30 mins earlier to avoid meeting conflicts',
    'Split 90-min focus block into 50 + 40 to reduce fatigue',
    'Add a 10-min walk between sessions to boost energy',
  ];

  void _addFromCategory(String category) {
    setState(() {
      routine.add({
        'title': '$category - Task',
        'mins': 30,
        'category': category,
      });
    });
  }

  void _generateFromAI() {
    // Placeholder - integrate real AI service during backend work
    setState(() {
      routine.insert(1, {'title': 'AI Suggested Break', 'mins': 15, 'category': 'Personal Care'});
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generated suggestions applied')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Routine Builder')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category palette
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: availableCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final cat = availableCategories[idx];
                  return ActionChip(
                    label: Text(cat),
                    onPressed: () => _addFromCategory(cat),
                    backgroundColor: Colors.grey.shade50,
                    elevation: 2,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Routine canvas - reorderable list as a simple drag/drop UX
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Routine', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ReorderableListView.builder(
                          itemCount: routine.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final item = routine.removeAt(oldIndex);
                              routine.insert(newIndex, item);
                            });
                          },
                          itemBuilder: (context, index) {
                            final item = routine[index];
                            return ListTile(
                              key: ValueKey(item['title'] + index.toString()),
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                child: Center(child: Text('${item['mins']}m', style: const TextStyle(fontWeight: FontWeight.bold))),
                              ),
                              title: Text(item['title']),
                              subtitle: Text(item['category']),
                              trailing: const Icon(Icons.drag_handle),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: _generateFromAI,
                            icon: const Icon(Icons.auto_fix_high_outlined),
                            label: const Text('Apply AI Suggestions'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Save routine flow - implement persistence
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Routine saved')));
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Save Routine'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            // AI suggestions quick list
            SizedBox(
              height: 90,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Suggestions', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: aiSuggestions.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) => ActionChip(
                            label: Text(aiSuggestions[i]),
                            onPressed: () {
                              setState(() {
                                routine.insert(1, {'title': aiSuggestions[i], 'mins': 15, 'category': 'Personal Care'});
                              });
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Suggestion added')));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
