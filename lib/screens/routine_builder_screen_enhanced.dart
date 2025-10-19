import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daypilot/widgets/app_drawer.dart';
import 'package:daypilot/services/haptic_service.dart';

/// Enhanced Routines Builder Screen
class RoutineBuilderScreenEnhanced extends ConsumerStatefulWidget {
  const RoutineBuilderScreenEnhanced({super.key});

  @override
  ConsumerState<RoutineBuilderScreenEnhanced> createState() => _RoutineBuilderScreenEnhancedState();
}

class _RoutineBuilderScreenEnhancedState extends ConsumerState<RoutineBuilderScreenEnhanced>
    with TickerProviderStateMixin {
  final HapticService _haptic = HapticService();
  final List<RoutineTemplate> _routineTemplates = [
    RoutineTemplate(
      name: 'Morning Energizer',
      icon: Icons.wb_sunny,
      color: Colors.orange,
      tasks: ['Wake up stretch', 'Meditate 10 min', 'Healthy breakfast', 'Review goals'],
    ),
    RoutineTemplate(
      name: 'Work Focus',
      icon: Icons.work,
      color: Colors.blue,
      tasks: ['Check calendar', 'Prioritize tasks', 'Deep work 2hrs', 'Break'],
    ),
    RoutineTemplate(
      name: 'Evening Wind Down',
      icon: Icons.nightlight,
      color: Colors.indigo,
      tasks: ['Review day', 'Light exercise', 'Dinner', 'Reading', 'Sleep prep'],
    ),
    RoutineTemplate(
      name: 'Fitness Pro',
      icon: Icons.fitness_center,
      color: Colors.red,
      tasks: ['Warm up', 'Cardio 20min', 'Strength training', 'Cool down', 'Protein shake'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            title: const Text('Routines'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  _haptic.lightImpact();
                  _showCreateRoutineDialog();
                },
              ),
            ],
          ),

          // Templates Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Popular Templates',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quick start with pre-made routines',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Template Cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final template = _routineTemplates[index];
                  return _buildTemplateCard(template, theme);
                },
                childCount: _routineTemplates.length,
              ),
            ),
          ),

          // Custom Routines Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Routines',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _haptic.lightImpact();
                          _showCreateRoutineDialog();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Create'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Empty State for custom routines
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primaryContainer,
                    ),
                    child: Icon(
                      Icons.event_repeat,
                      size: 50,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No custom routines yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your own routine or use a template above',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(RoutineTemplate template, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            template.color.withOpacity(0.1),
            template.color.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: template.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _haptic.mediumImpact();
            _showTemplateDetails(template);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: template.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        template.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${template.tasks.length} steps',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: template.color,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: template.tasks.take(3).map((task) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: template.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: template.color.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (template.tasks.length > 3) ...[
                  const SizedBox(height: 8),
                  Text(
                    '+${template.tasks.length - 3} more steps',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTemplateDetails(RoutineTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: template.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      template.icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      template.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: template.tasks.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: template.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: template.color.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: template.color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            template.tasks[index],
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    _haptic.success();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${template.name} added to your routines!')),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: template.color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Use This Template'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRoutineDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Routine'),
        content: const Text('Custom routine builder coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class RoutineTemplate {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> tasks;

  RoutineTemplate({
    required this.name,
    required this.icon,
    required this.color,
    required this.tasks,
  });
}
