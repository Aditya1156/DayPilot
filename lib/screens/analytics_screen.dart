import 'package:flutter/material.dart';
import '../widgets/surface_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Enhanced placeholder metrics with trends
    final double completionRate = 0.82;
    final double avgFocusHours = 5.2;
    final int streakDays = 12;
    final double weeklyGrowth = 0.15; // 15% improvement
    
    // Weekly completion data for mini chart
    final List<double> weeklyData = [0.65, 0.72, 0.78, 0.75, 0.82, 0.85, 0.82];

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
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(14),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Completion', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha(180))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withAlpha(25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.trending_up, size: 12, color: Color(0xFF10B981)),
                                  const SizedBox(width: 2),
                                  Text('+${(weeklyGrowth * 100).round()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(completionRate * 100).round()}%',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: weeklyData.map((val) => Container(
                              width: 6,
                              height: val * 30,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withAlpha(180),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(14),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Focus Time', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha(180))),
                            Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.tertiary),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${avgFocusHours.toStringAsFixed(1)}h',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Daily avg', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(140))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(14),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Streak', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha(180))),
                            const Icon(Icons.local_fire_department, size: 14, color: Color(0xFFFF8A3D)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$streakDays',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('days', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(140))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SurfaceCard(
              padding: const EdgeInsets.all(14),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insights_outlined, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('AI Insights', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInsightItem(
                    context,
                    Icons.calendar_today,
                    'Weekday productivity is 18% higher than weekends',
                    const Color(0xFF2E7EF0),
                  ),
                  const SizedBox(height: 10),
                  _buildInsightItem(
                    context,
                    Icons.schedule,
                    'Short breaks after 50 min increased completion by ~12%',
                    const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 10),
                  _buildInsightItem(
                    context,
                    Icons.trending_up,
                    'Your focus time improved 23% this month — keep it up!',
                    const Color(0xFF7C3AED),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.file_download_outlined, size: 18),
                          label: const Text('Export CSV'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share_outlined, size: 18),
                          label: const Text('Share Report'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: Center(child: Text('Charts and deeper analytics will be integrated here.'))),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInsightItem(BuildContext context, IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
