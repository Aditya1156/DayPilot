import 'package:flutter/material.dart';
import '../widgets/surface_card.dart';

class AIOptimizationScreen extends StatefulWidget {
  const AIOptimizationScreen({super.key});

  @override
  State<AIOptimizationScreen> createState() => _AIOptimizationScreenState();
}

class _AIOptimizationScreenState extends State<AIOptimizationScreen> {
  double focusPreference = 0.7; // 0..1 (higher = longer focus blocks)
  bool preferMorning = true;
  int dailyAvailableHours = 8;
  double energyLevel = 0.8;
  String workStyle = 'Deep Focus';

  final List<String> workStyles = ['Deep Focus', 'Balanced', 'Flexible', 'Sprint-Based'];
  final List<String> suggestions = [];
  
  // Simulated productivity insights
  final Map<String, double> productivityByHour = {
    '9 AM': 0.85,
    '11 AM': 0.92,
    '2 PM': 0.68,
    '4 PM': 0.75,
  };

  void _generate() {
    // Enhanced AI suggestions based on parameters
    setState(() {
      suggestions.clear();
      suggestions.add('🎯 Consolidate two 30-min meetings into one 60-min block to reduce context switching');
      suggestions.add('☀️ Schedule high-focus tasks in the morning (9-11 AM) when your energy peaks at ${(energyLevel * 100).round()}%');
      if (focusPreference > 0.6) {
        suggestions.add('⏱️ Use ${workStyle == 'Deep Focus' ? '90-min' : '50-min'} deep work blocks with 20-min recovery windows');
      }
      if (preferMorning) {
        suggestions.add('🌅 Front-load challenging tasks before noon — your historical productivity is 23% higher in AM');
      }
      suggestions.add('📊 Based on your routine, you have ${dailyAvailableHours - 2}h of focused work time after accounting for breaks');
      suggestions.add('💡 Try batching similar tasks together — reduces mental switching cost by ~40%');
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ AI optimization complete'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('AI Optimization')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('AI Parameters', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SurfaceCard(
              padding: const EdgeInsets.all(14),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology_outlined, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('AI Parameters', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Text('Focus preference', style: TextStyle(fontSize: 13))),
                      Expanded(
                        flex: 2,
                        child: Slider(
                          value: focusPreference,
                          onChanged: (v) => setState(() => focusPreference = v),
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${(focusPreference * 100).round()}%', style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(child: Text('Energy level', style: TextStyle(fontSize: 13))),
                      Expanded(
                        flex: 2,
                        child: Slider(
                          value: energyLevel,
                          onChanged: (v) => setState(() => energyLevel = v),
                          activeColor: theme.colorScheme.tertiary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${(energyLevel * 100).round()}%', style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.tertiary)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Work Style', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: workStyle,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              items: workStyles.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                              onChanged: (v) => setState(() => workStyle = v ?? 'Balanced'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Daily hours', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              initialValue: dailyAvailableHours,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              items: [4, 6, 8, 10, 12].map((h) => DropdownMenuItem(value: h, child: Text('$h hrs', style: const TextStyle(fontSize: 13)))).toList(),
                              onChanged: (v) => setState(() => dailyAvailableHours = v ?? 8),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Prefer morning sessions', style: TextStyle(fontSize: 13)),
                    value: preferMorning,
                    onChanged: (v) => setState(() => preferMorning = v),
                    activeThumbColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _generate,
                      icon: const Icon(Icons.auto_fix_high),
                      label: const Text('Generate Optimized Routine'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (suggestions.isNotEmpty) ...[
              Text('Suggestions', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                    itemCount: suggestions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) => SurfaceCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                        title: Text(suggestions[idx]),
                        trailing: IconButton(icon: const Icon(Icons.add), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to routine')))),
                      ),
                    ),
                  ),
              ),
            ] else ...[
              const Expanded(child: Center(child: Text('No suggestions yet. Adjust parameters and tap Generate.'))),
            ],
          ],
        ),
      ),
    );
  }
}
