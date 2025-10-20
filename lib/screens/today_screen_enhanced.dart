import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daypilot/services/haptic_service.dart';
import 'package:daypilot/models/task.dart';

/// Enhanced Today Screen - Focus on today's tasks with beautiful animations
class TodayScreenEnhanced extends ConsumerStatefulWidget {
  const TodayScreenEnhanced({super.key});

  @override
  ConsumerState<TodayScreenEnhanced> createState() => _TodayScreenEnhancedState();
}

class _TodayScreenEnhancedState extends ConsumerState<TodayScreenEnhanced>
    with TickerProviderStateMixin {
  final HapticService _haptic = HapticService();
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  // Sample tasks for today
  final List<Task> _morningTasks = [
    Task(
      id: '1',
      title: 'Morning Meditation',
      description: '10 minutes mindfulness',
      category: TaskCategory.personal,
      startTime: DateTime.now().copyWith(hour: 6, minute: 30),
      endTime: DateTime.now().copyWith(hour: 6, minute: 40),
      status: TaskStatus.completed,
    ),
    Task(
      id: '2',
      title: 'Healthy Breakfast',
      description: 'Oats with fruits',
      category: TaskCategory.health,
      startTime: DateTime.now().copyWith(hour: 7, minute: 0),
      endTime: DateTime.now().copyWith(hour: 7, minute: 30),
      status: TaskStatus.completed,
    ),
  ];

  final List<Task> _afternoonTasks = [
    Task(
      id: '3',
      title: 'Project Presentation',
      description: 'Present Q1 results to team',
      category: TaskCategory.work,
      startTime: DateTime.now().copyWith(hour: 14, minute: 0),
      endTime: DateTime.now().copyWith(hour: 15, minute: 0),
      status: TaskStatus.pending,
    ),
    Task(
      id: '4',
      title: 'Code Review',
      description: 'Review pull requests',
      category: TaskCategory.work,
      startTime: DateTime.now().copyWith(hour: 15, minute: 30),
      endTime: DateTime.now().copyWith(hour: 16, minute: 30),
      status: TaskStatus.pending,
    ),
  ];

  final List<Task> _eveningTasks = [
    Task(
      id: '5',
      title: 'Gym Workout',
      description: 'Upper body strength training',
      category: TaskCategory.health,
      startTime: DateTime.now().copyWith(hour: 18, minute: 0),
      endTime: DateTime.now().copyWith(hour: 19, minute: 0),
      status: TaskStatus.pending,
    ),
    Task(
      id: '6',
      title: 'Read Book',
      description: 'Atomic Habits - Chapter 5',
      category: TaskCategory.study,
      startTime: DateTime.now().copyWith(hour: 20, minute: 0),
      endTime: DateTime.now().copyWith(hour: 21, minute: 0),
      status: TaskStatus.pending,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  int get _totalTasks => _morningTasks.length + _afternoonTasks.length + _eveningTasks.length;
  int get _completedTasks {
    return _morningTasks.where((t) => t.status == TaskStatus.completed).length +
        _afternoonTasks.where((t) => t.status == TaskStatus.completed).length +
        _eveningTasks.where((t) => t.status == TaskStatus.completed).length;
  }

  double get _progressPercentage => _totalTasks > 0 ? _completedTasks / _totalTasks : 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final hour = now.hour;
    
    String greeting;
    IconData greetingIcon;
    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_twilight;
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icons.nights_stay;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Animated Header
          SliverAppBar.large(
            floating: false,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: FadeTransition(
                opacity: _headerAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withAlpha((0.1 * 255).round()),
                        theme.colorScheme.secondary.withAlpha((0.05 * 255).round()),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(greetingIcon, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            greeting,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getMotivationalQuote(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Progress Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha((0.2 * 255).round()),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Progress',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_completedTasks of $_totalTasks tasks completed',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: _progressPercentage,
                                strokeWidth: 8,
                                backgroundColor: theme.colorScheme.surface.withAlpha((0.3 * 255).round()),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                              Center(
                                child: Text(
                                  '${(_progressPercentage * 100).toInt()}%',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_progressPercentage == 1.0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha((0.2 * 255).round()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.celebration, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'Amazing! All tasks completed! 🎉',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Morning Tasks
          if (_morningTasks.isNotEmpty) ...[
            _buildSectionHeader('Morning', Icons.wb_sunny, Colors.amber, theme),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildTaskCard(_morningTasks[index], theme),
                  childCount: _morningTasks.length,
                ),
              ),
            ),
          ],

          // Afternoon Tasks
          if (_afternoonTasks.isNotEmpty) ...[
            _buildSectionHeader('Afternoon', Icons.wb_twilight, Colors.orange, theme),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildTaskCard(_afternoonTasks[index], theme),
                  childCount: _afternoonTasks.length,
                ),
              ),
            ),
          ],

          // Evening Tasks
          if (_eveningTasks.isNotEmpty) ...[
            _buildSectionHeader('Evening', Icons.nights_stay, Colors.indigo, theme),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildTaskCard(_eveningTasks[index], theme),
                  childCount: _eveningTasks.length,
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _haptic.mediumImpact();
          _showAddTaskSheet(context, theme);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task, ThemeData theme) {
    final categoryColor = _getCategoryColor(task.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
                border: Border.all(
          color: task.status == TaskStatus.completed
              ? Colors.green.withAlpha((0.3 * 255).round())
              : categoryColor.withAlpha((0.3 * 255).round()),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _haptic.lightImpact();
            setState(() {
              task.status = task.status == TaskStatus.completed
                  ? TaskStatus.pending
                  : TaskStatus.completed;
            });
            if (task.status == TaskStatus.completed) {
              _haptic.success();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: task.status == TaskStatus.completed ? Colors.green : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.status == TaskStatus.completed ? Colors.green : categoryColor,
                      width: 2,
                    ),
                  ),
                  child: task.status == TaskStatus.completed
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: task.status == TaskStatus.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                            decoration: task.status == TaskStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withAlpha((0.2 * 255).round()),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.category.name.toUpperCase(),
                              style: TextStyle(
                                color: categoryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: categoryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${task.startTime.hour}:${task.startTime.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: categoryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(TaskCategory category) {
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

  String _getMotivationalQuote() {
    final quotes = [
      'Make today amazing!',
      'You\'ve got this!',
      'Small progress is still progress',
      'Focus on what matters',
      'One task at a time',
    ];
    return quotes[DateTime.now().day % quotes.length];
  }

  void _showAddTaskSheet(BuildContext context, ThemeData theme) {
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
                  'New Task',
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
                    label: const Text('Add Task'),
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
