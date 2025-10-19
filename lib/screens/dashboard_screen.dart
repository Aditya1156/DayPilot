import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daypilot/models/task.dart';
import 'package:daypilot/providers/app_providers.dart';
import 'package:daypilot/providers/user_provider_v2.dart';
import 'package:daypilot/utils/theme.dart';
import 'package:daypilot/widgets/circular_timeline.dart';
import 'package:daypilot/widgets/task_card.dart';
import 'package:daypilot/widgets/ai_suggestion_card.dart';
import 'package:daypilot/widgets/app_drawer.dart';
import 'package:daypilot/widgets/user_profile_menu.dart';
import 'package:daypilot/widgets/motivational_quote_card.dart';
import 'package:daypilot/widgets/empty_state_widget.dart';
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
    final username = ref.watch(userDisplayNameProvider);

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
                const UserProfileMenu(),
              ],
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Motivational Quote Card
                    const MotivationalQuoteCard(),
                    const SizedBox(height: 16),

                    // Circular Timeline
                    Center(
                      child: CircularTimeline(
                        tasks: tasks,
                        progress: progress,
                      ),
                    ),
                    const SizedBox(height: 32),

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
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.check),
            title: const Text('Mark Complete'),
            onTap: () async {
              await _hapticService.success();
              task.status = TaskStatus.completed;
              notifier.updateTask(task);
              _confettiController.play();
              Navigator.pop(context);
              
              // Show undo snackbar
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Task completed! 🎉'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        _hapticService.lightImpact();
                        task.status = TaskStatus.pending;
                        notifier.updateTask(task);
                      },
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Task'),
            onTap: () async {
              await _hapticService.lightImpact();
              // TODO: Implement edit task dialog
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Task'),
            onTap: () async {
              await _hapticService.warning();
              final deletedTask = task;
              notifier.deleteTask(task.id);
              Navigator.pop(context);
              
              // Show undo snackbar
              if (mounted) {
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
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _addNewTask(BuildContext context, TasksNotifier notifier) {
    _hapticService.lightImpact();
    final titleController = TextEditingController();
    TaskCategory selectedCategory = TaskCategory.personal;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            const SizedBox(height: 16),
            DropdownButton<TaskCategory>(
              value: selectedCategory,
              items: TaskCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedCategory = value!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final newTask = Task(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  category: selectedCategory,
                  startTime: DateTime.now().add(const Duration(hours: 1)),
                  endTime: DateTime.now().add(const Duration(hours: 2)),
                );
                notifier.addTask(newTask);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            } else {
              // Swipe right to complete
              task.status = TaskStatus.completed;
              tasksNotifier.updateTask(task);
              _confettiController.play();
              return false; // Don't dismiss, just update
            }
          },
          background: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 30,
            ),
          ),
          secondaryBackground: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 30,
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