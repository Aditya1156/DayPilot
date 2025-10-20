import 'package:flutter/material.dart';
import 'package:daypilot/widgets/app_drawer.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.amber,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.withAlpha((0.1 * 255).round()),
              Colors.orange.withAlpha((0.1 * 255).round()),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAchievementCard(
              context,
              title: '7 Day Streak',
              description: 'Complete tasks for 7 consecutive days',
              icon: Icons.local_fire_department,
              color: Colors.orange,
              progress: 1.0,
              isUnlocked: true,
            ),
            _buildAchievementCard(
              context,
              title: 'Early Bird',
              description: 'Complete 5 tasks before 9 AM',
              icon: Icons.wb_sunny,
              color: Colors.amber,
              progress: 0.6,
              isUnlocked: false,
            ),
            _buildAchievementCard(
              context,
              title: 'Task Master',
              description: 'Complete 100 tasks',
              icon: Icons.emoji_events,
              color: Colors.yellow,
              progress: 0.47,
              isUnlocked: false,
            ),
            _buildAchievementCard(
              context,
              title: 'Productivity Pro',
              description: 'Maintain 90% completion rate for a month',
              icon: Icons.trending_up,
              color: Colors.green,
              progress: 0.25,
              isUnlocked: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required double progress,
    required bool isUnlocked,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUnlocked ? color : Colors.grey.withAlpha((0.3 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 40,
                color: isUnlocked ? Colors.white : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withAlpha((0.2 * 255).round()),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
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
