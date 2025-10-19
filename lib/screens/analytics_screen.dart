import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Placeholder metrics
    final double completionRate = 0.78;
    final double avgFocusHours = 4.5;
    final int streakDays = 7;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Weekly Overview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text('Completion', style: theme.textTheme.bodySmall),
                          const SizedBox(height: 8),
                          Text('${(completionRate * 100).round()}%', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text('Focus Hours', style: theme.textTheme.bodySmall),
                          const SizedBox(height: 8),
                          Text('${avgFocusHours.toStringAsFixed(1)}h', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text('Streak', style: theme.textTheme.bodySmall),
                          const SizedBox(height: 8),
                          Text('$streakDays days', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Insights', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('1) You complete focused work more on weekdays than weekends.'),
                    const SizedBox(height: 6),
                    Text('2) Short breaks after every 50 minutes increased completion by ~12%'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.file_download_outlined), label: const Text('Export')),                        
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: Center(child: Text('Charts and deeper analytics will be integrated here.'))),
          ],
        ),
      ),
    );
  }
}
