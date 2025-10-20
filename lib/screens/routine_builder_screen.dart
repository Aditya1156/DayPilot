import 'package:flutter/material.dart';
import '../widgets/surface_card.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RoutineBuilderScreen extends StatefulWidget {
  const RoutineBuilderScreen({super.key});

  @override
  State<RoutineBuilderScreen> createState() => _RoutineBuilderScreenState();
}

class _RoutineBuilderScreenState extends State<RoutineBuilderScreen> {
  // UI-first categories for building routines with icons
  final Map<String, IconData> categoryIcons = {
    'Work': Icons.work_outline,
    'Study': Icons.school_outlined,
    'Exercise': Icons.fitness_center_outlined,
    'Personal Care': Icons.self_improvement_outlined,
    'Errands': Icons.shopping_bag_outlined,
    'Focus': Icons.psychology_outlined,
    'Break': Icons.free_breakfast_outlined,
    'Social': Icons.people_outline,
  };

  // Current routine being edited
  List<Map<String, dynamic>> routine = [];
  
  String templateName = 'My Routine';
  bool showTemplateManager = false;
  
  // Calculate total time
  int get totalMinutes => routine.fold(0, (sum, item) => sum + (item['mins'] as int));
  
  String get formattedTotalTime {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

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

  // Persist/load routines using Hive
  Future<void> _saveRoutineTemplate() async {
    final box = await Hive.openBox('routines');
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(id, {'name': 'Template $id', 'items': routine, 'created': DateTime.now().toIso8601String()});
    if (!mounted) return;
    // Use mounted guard before interacting with ScaffoldMessenger
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template saved')));
  }

  Future<void> _loadRoutineTemplate(String id) async {
    final box = await Hive.openBox('routines');
    final saved = box.get(id);
    if (saved != null && saved['items'] is List) {
      final items = List<Map<String, dynamic>>.from(saved['items']);
      if (!mounted) return;
      setState(() {
        routine = items;
      });
    }
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
            // Category palette (draggable chips with icons)
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categoryIcons.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final cat = categoryIcons.keys.toList()[idx];
                  final icon = categoryIcons[cat]!;
                  return Draggable<String>(
                    data: cat,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: Colors.white, size: 20),
                            const SizedBox(width: 6),
                            Text(cat, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: ActionChip(
                        avatar: Icon(icon, size: 18),
                        label: Text(cat),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    child: ActionChip(
                      avatar: Icon(icon, size: 18, color: theme.colorScheme.primary),
                      label: Text(cat, style: const TextStyle(fontWeight: FontWeight.w600)),
                      onPressed: () => _addFromCategory(cat),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(color: theme.colorScheme.primary.withAlpha(60)),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Routine canvas - reorderable list as a simple drag/drop UX
            Expanded(
              child: SurfaceCard(
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(templateName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule, size: 14, color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                formattedTotalTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () async {
                            final result = await showDialog<String>(
                              context: context,
                              builder: (context) {
                                final controller = TextEditingController(text: templateName);
                                return AlertDialog(
                                  title: const Text('Template Name'),
                                  content: TextField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter template name',
                                    ),
                                    autofocus: true,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, controller.text),
                                      child: const Text('Save'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (result != null && result.isNotEmpty) {
                              setState(() => templateName = result);
                            }
                          },
                          tooltip: 'Rename template',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: DragTarget<String>(
                        onAcceptWithDetails: (details) {
                          _addFromCategory(details.data);
                        },
                        builder: (context, candidateData, rejectedData) {
                          final isActive = candidateData.isNotEmpty;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              color: isActive ? theme.colorScheme.primary.withAlpha((0.03 * 255).round()) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isActive ? Border.all(color: theme.colorScheme.primary, width: 2) : Border.all(color: Colors.transparent),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: ReorderableListView.builder(
                              physics: const BouncingScrollPhysics(),
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
                                final key = ValueKey('${item['title']}_$index');
                                return Container(
                                  key: key,
                                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                                  child: Material(
                                    color: Theme.of(context).colorScheme.surface,
                                    elevation: 1,
                                    borderRadius: BorderRadius.circular(10),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      leading: Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              theme.colorScheme.primary.withAlpha(25),
                                              theme.colorScheme.primary.withAlpha(15),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              categoryIcons[item['category']] ?? Icons.task_alt,
                                              size: 18,
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${item['mins']}m',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                                color: theme.colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                      subtitle: Text(item['category'], style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(180))),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 18),
                                            onPressed: () {
                                              setState(() => routine.removeAt(index));
                                            },
                                            tooltip: 'Remove',
                                          ),
                                          ReorderableDragStartListener(
                                            index: index,
                                            child: Icon(Icons.drag_handle, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Action row: AI + Save. Use Wrap so buttons don't overflow and respect SafeArea
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: _generateFromAI,
                              icon: const Icon(Icons.auto_fix_high_outlined),
                              label: const Text('Apply AI Suggestions'),
                              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _saveRoutineTemplate,
                            icon: const Icon(Icons.save),
                            label: const Text('Save Template'),
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.folder_open),
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'load_latest', child: Text('Load latest template')),
                            ],
                            onSelected: (v) async {
                              if (v == 'load_latest') {
                                // load latest template
                                final box = await Hive.openBox('routines');
                                if (box.isNotEmpty) {
                                  final key = box.keys.last as String;
                                  await _loadRoutineTemplate(key);
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No templates saved yet')));
                                }
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            // AI suggestions quick list
            SizedBox(
              height: 110,
              child: SurfaceCard(
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.all(12),
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
                        itemBuilder: (context, i) => SurfaceCard(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          borderRadius: BorderRadius.circular(12),
                          child: Row(children: [
                            const Icon(Icons.lightbulb, color: Colors.amber),
                            const SizedBox(width: 8),
                            SizedBox(width: 220, child: Text(aiSuggestions[i], maxLines: 2, overflow: TextOverflow.ellipsis)),
                          ]),
                        ),
                      ),
                    ),
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
