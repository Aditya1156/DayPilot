import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daypilot/models/task.dart';
import 'package:daypilot/providers/app_providers.dart';
import 'package:daypilot/providers/user_profile_provider.dart';
import 'package:daypilot/utils/theme.dart';
import 'package:daypilot/widgets/circular_timeline.dart';
import 'package:daypilot/widgets/task_card.dart';
import 'package:daypilot/widgets/ai_suggestion_card.dart';
import 'package:daypilot/widgets/app_drawer.dart';
import 'package:daypilot/widgets/motivational_quote_card.dart';
import 'package:daypilot/widgets/task_search_delegate.dart';
import 'package:daypilot/services/haptic_service.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final HapticService _hapticService = HapticService();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
    _hapticService.initialize();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = ref.watch(tasksProvider);
    final tasksNotifier = ref.read(tasksProvider.notifier);
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final greeting = ref.watch(greetingProvider);
    final username = ref.watch(usernameProvider);

    // Calculate task progress
    final completedTasks = tasks.where((task) => task.status == TaskStatus.completed).length;
    final progress = tasks.isEmpty ? 0.0 : completedTasks / tasks.length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: () async {
                  await _hapticService.lightImpact();
                  await Future.delayed(const Duration(milliseconds: 500));
                  setState(() {});
                },
                child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: theme.colorScheme.surface,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, $username',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    today,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    await _hapticService.lightImpact();
                    showSearch(
                      context: context,
                      delegate: TaskSearchDelegate(tasks),
                    );
                  },
                ),
                // Profile moved into the left sidebar drawer for cleaner header
              ],
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Motivational Quote Card - Now smaller and dismissible
                    const MotivationalQuoteCard(),

                    // Circular Timeline
                    Center(
                      child: CircularTimeline(
                        tasks: tasks,
                        progress: progress,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Morning Section
                    _buildTimeSection(
                      context: context,
                      title: '🌅 Morning',
                      subtitle: 'Start your day right',
                      tasks: _getTasksForTimeRange(tasks, 6, 12),
                      color: AppTheme.primaryBlue,
                    ),
                    
                    // Afternoon Section
                    _buildTimeSection(
                      context: context,
                      title: '☀️ Afternoon',
                      subtitle: 'Stay productive',
                      tasks: _getTasksForTimeRange(tasks, 12, 18),
                      color: AppTheme.accentYellow,
                    ),
                    
                    // Evening Section
                    _buildTimeSection(
                      context: context,
                      title: '🌙 Evening',
                      subtitle: 'Wind down and reflect',
                      tasks: _getTasksForTimeRange(tasks, 18, 24),
                      color: AppTheme.secondaryPurple,
                    ),
                    
                    // All Tasks Summary
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "All Tasks Today",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$completedTasks/${tasks.length} completed',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Task Cards Grid
                    _buildTaskGrid(tasks, tasksNotifier),                    // AI Suggestions Section
                    const SizedBox(height: 24),
                    Text(
                      "AI Suggestions",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // AI Suggestion Cards
                    const AISuggestionCard(
                      suggestion: "Shift your lunch earlier by 15 mins for better energy levels this afternoon.",
                      icon: Icons.lightbulb,
                      color: AppTheme.accentYellow,
                    ),
                    const SizedBox(height: 12),
                    const AISuggestionCard(
                      suggestion: "Based on your sleep data, consider moving your workout to 7:30 AM tomorrow.",
                      icon: Icons.fitness_center,
                      color: AppTheme.tertiaryGreen,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
              ),
            ),
          ),

          // Confetti overlay
          // Align(
          //   alignment: Alignment.topCenter,
          //   child: ConfettiWidget(
          //     confettiController: _confettiController,
          //   ),
          // ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/routines');
              break;
            case 2:
              Navigator.pushNamed(context, '/reminders');
              break;
            case 3:
              Navigator.pushNamed(context, '/ai');
              break;
            case 4:
              Navigator.pushNamed(context, '/analytics');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Routines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewTask(context, tasksNotifier),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTaskActions(BuildContext context, Task task, TasksNotifier notifier) {
    _hapticService.lightImpact();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(
                task.status == TaskStatus.completed ? Icons.replay : Icons.check,
                color: Colors.green,
              ),
              title: Text(
                task.status == TaskStatus.completed ? 'Mark Incomplete' : 'Mark Complete',
              ),
              onTap: () async {
                await _hapticService.success();
                task.status = task.status == TaskStatus.completed 
                    ? TaskStatus.pending 
                    : TaskStatus.completed;
                notifier.updateTask(task);
                if (task.status == TaskStatus.completed) {
                  _confettiController.play();
                }
                Navigator.pop(context);
                
                // Show snackbar
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        task.status == TaskStatus.completed 
                            ? 'Task completed! 🎉' 
                            : 'Task marked incomplete'
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Task'),
              onTap: () async {
                await _hapticService.lightImpact();
                Navigator.pop(context);
                _editTask(context, task, notifier);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.orange),
              title: const Text('Change Time'),
              onTap: () async {
                await _hapticService.lightImpact();
                Navigator.pop(context);
                _changeTaskTime(context, task, notifier);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.purple),
              title: const Text('Duplicate Task'),
              onTap: () async {
                await _hapticService.lightImpact();
                final duplicatedTask = Task(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: '${task.title} (Copy)',
                  description: task.description,
                  category: task.category,
                  startTime: task.startTime.add(const Duration(hours: 1)),
                  endTime: task.endTime.add(const Duration(hours: 1)),
                  status: TaskStatus.pending,
                );
                notifier.addTask(duplicatedTask);
                Navigator.pop(context);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task duplicated'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Task', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await _hapticService.warning();
                Navigator.pop(context);
                _deleteTask(context, task, notifier);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addNewTask(BuildContext context, TasksNotifier notifier) {
    _hapticService.lightImpact();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TaskCategory selectedCategory = TaskCategory.personal;
    TimeOfDay selectedStartTime = TimeOfDay.now();
    TimeOfDay selectedEndTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title *',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: TaskCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(category),
                            size: 20,
                            color: _getCategoryColor(category),
                          ),
                          const SizedBox(width: 8),
                          Text(category.name.toUpperCase()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedCategory = value!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          '${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}',
                        ),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedStartTime,
                          );
                          if (time != null) {
                            setDialogState(() => selectedStartTime = time);
                          }
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('to'),
                    ),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          '${selectedEndTime.hour.toString().padLeft(2, '0')}:${selectedEndTime.minute.toString().padLeft(2, '0')}',
                        ),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedEndTime,
                          );
                          if (time != null) {
                            setDialogState(() => selectedEndTime = time);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  final now = DateTime.now();
                  final newTask = Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim().isEmpty 
                        ? null 
                        : descriptionController.text.trim(),
                    category: selectedCategory,
                    startTime: DateTime(
                      now.year,
                      now.month,
                      now.day,
                      selectedStartTime.hour,
                      selectedStartTime.minute,
                    ),
                    endTime: DateTime(
                      now.year,
                      now.month,
                      now.day,
                      selectedEndTime.hour,
                      selectedEndTime.minute,
                    ),
                  );
                  notifier.addTask(newTask);
                  _hapticService.success();
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task added successfully!'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  void _editTask(BuildContext context, Task task, TasksNotifier notifier) {
    _hapticService.lightImpact();
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description ?? '');
    TaskCategory selectedCategory = task.category;
    TimeOfDay selectedStartTime = TimeOfDay.fromDateTime(task.startTime);
    TimeOfDay selectedEndTime = TimeOfDay.fromDateTime(task.endTime);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title *',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: TaskCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(category),
                            size: 20,
                            color: _getCategoryColor(category),
                          ),
                          const SizedBox(width: 8),
                          Text(category.name.toUpperCase()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedCategory = value!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          '${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}',
                        ),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedStartTime,
                          );
                          if (time != null) {
                            setDialogState(() => selectedStartTime = time);
                          }
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('to'),
                    ),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          '${selectedEndTime.hour.toString().padLeft(2, '0')}:${selectedEndTime.minute.toString().padLeft(2, '0')}',
                        ),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedEndTime,
                          );
                          if (time != null) {
                            setDialogState(() => selectedEndTime = time);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  final updatedTask = Task(
                    id: task.id,
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim().isEmpty 
                        ? null 
                        : descriptionController.text.trim(),
                    category: selectedCategory,
                    startTime: DateTime(
                      task.startTime.year,
                      task.startTime.month,
                      task.startTime.day,
                      selectedStartTime.hour,
                      selectedStartTime.minute,
                    ),
                    endTime: DateTime(
                      task.endTime.year,
                      task.endTime.month,
                      task.endTime.day,
                      selectedEndTime.hour,
                      selectedEndTime.minute,
                    ),
                    status: task.status,
                  );
                  notifier.updateTask(updatedTask);
                  _hapticService.success();
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task updated successfully!'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _changeTaskTime(BuildContext context, Task task, TasksNotifier notifier) {
    TimeOfDay selectedStartTime = TimeOfDay.fromDateTime(task.startTime);
    TimeOfDay selectedEndTime = TimeOfDay.fromDateTime(task.endTime);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Task Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.start),
                title: const Text('Start Time'),
                trailing: Text(
                  '${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedStartTime,
                  );
                  if (time != null) {
                    setDialogState(() => selectedStartTime = time);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.stop),
                title: const Text('End Time'),
                trailing: Text(
                  '${selectedEndTime.hour.toString().padLeft(2, '0')}:${selectedEndTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedEndTime,
                  );
                  if (time != null) {
                    setDialogState(() => selectedEndTime = time);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final updatedTask = Task(
                  id: task.id,
                  title: task.title,
                  description: task.description,
                  category: task.category,
                  startTime: DateTime(
                    task.startTime.year,
                    task.startTime.month,
                    task.startTime.day,
                    selectedStartTime.hour,
                    selectedStartTime.minute,
                  ),
                  endTime: DateTime(
                    task.endTime.year,
                    task.endTime.month,
                    task.endTime.day,
                    selectedEndTime.hour,
                    selectedEndTime.minute,
                  ),
                  status: task.status,
                );
                notifier.updateTask(updatedTask);
                _hapticService.success();
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task time updated!'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTask(BuildContext context, Task task, TasksNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              final deletedTask = task;
              notifier.deleteTask(task.id);
              _hapticService.warning();
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Task deleted'),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      _hapticService.lightImpact();
                      notifier.addTask(deletedTask);
                    },
                  ),
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.health:
        return Icons.fitness_center;
      case TaskCategory.study:
        return Icons.school;
    }
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Colors.blue;
      case TaskCategory.personal:
        return Colors.amber;
      case TaskCategory.health:
        return Colors.green;
      case TaskCategory.study:
        return Colors.purple;
    }
  }

  Widget _buildTimeSection({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<Task> tasks,
    required Color color,
  }) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final completedCount = tasks.where((task) => task.status == TaskStatus.completed).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$completedCount/${tasks.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => _showTaskActions(context, task, ref.read(tasksProvider.notifier)),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                task.categoryIcon,
                                size: 20,
                                color: task.categoryColor,
                              ),
                              const Spacer(),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: task.status == TaskStatus.completed
                                      ? Colors.green
                                      : task.status == TaskStatus.inProgress
                                          ? Colors.blue
                                          : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            '${task.startTime.hour}:${task.startTime.minute.toString().padLeft(2, '0')}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Task> _getTasksForTimeRange(List<Task> allTasks, int startHour, int endHour) {
    return allTasks.where((task) {
      final hour = task.startTime.hour;
      return hour >= startHour && hour < endHour;
    }).toList();
  }

  Widget _buildTaskGrid(List<Task> tasks, TasksNotifier tasksNotifier) {
    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.task_alt,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No tasks yet!\nTap + to add your first task',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Dismissible(
          key: Key(task.id),
          direction: DismissDirection.horizontal,
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Swipe left to delete
              _hapticService.warning();
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Task'),
                  content: Text('Delete "${task.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            } else {
              // Swipe right to complete/uncomplete
              _hapticService.success();
              task.status = task.status == TaskStatus.completed 
                  ? TaskStatus.pending 
                  : TaskStatus.completed;
              tasksNotifier.updateTask(task);
              if (task.status == TaskStatus.completed) {
                _confettiController.play();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task completed! 🎉'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
              return false; // Don't dismiss, just update
            }
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              // Task was deleted
              final deletedTask = task;
              tasksNotifier.deleteTask(task.id);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Task deleted'),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      _hapticService.lightImpact();
                      tasksNotifier.addTask(deletedTask);
                    },
                  ),
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade400,
                  Colors.green.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  task.status == TaskStatus.completed ? Icons.replay : Icons.check_circle,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  task.status == TaskStatus.completed ? 'Undo' : 'Complete',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          secondaryBackground: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade600,
                  Colors.red.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(height: 4),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          child: TaskCard(
            task: task,
            onTap: () => _showTaskActions(context, task, tasksNotifier),
          ),
        );
      },
    );
  }
}