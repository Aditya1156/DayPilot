import 'package:flutter/material.dart';

class AIOptimizationScreen extends StatefulWidget {
  const AIOptimizationScreen({super.key});

  @override
  State<AIOptimizationScreen> createState() => _AIOptimizationScreenState();
}

class _AIOptimizationScreenState extends State<AIOptimizationScreen> {
  double focusPreference = 0.7; // 0..1 (higher = longer focus blocks)
  bool preferMorning = true;
  int dailyAvailableHours = 8;

  final List<String> suggestions = [];

  void _generate() {
    // Placeholder for real AI call. We'll simulate a few suggestions.
    setState(() {
      suggestions.clear();
      suggestions.add('Consolidate two 30-min meetings into one 60-min block to reduce context switching');
      suggestions.add('Schedule high-focus tasks in the morning when energy is highest');
      if (focusPreference > 0.6) suggestions.add('Use 90-min deep work blocks with 20-min recovery windows');
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI optimization complete')));
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
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Focus preference'),
                        Expanded(child: Slider(value: focusPreference, onChanged: (v) => setState(() => focusPreference = v))),
                        Text('${(focusPreference * 100).round()}%'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Prefer morning:'),
                        Switch(value: preferMorning, onChanged: (v) => setState(() => preferMorning = v)),
                        const Spacer(),
                        const Text('Daily hours'),
                        const SizedBox(width: 8),
                        DropdownButton<int>(value: dailyAvailableHours, items: [6,8,10,12].map((h) => DropdownMenuItem(value: h, child: Text('$h'))).toList(), onChanged: (v) => setState(() => dailyAvailableHours = v ?? 8)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(onPressed: _generate, icon: const Icon(Icons.auto_fix_high), label: const Text('Generate Optimized Routine')),
                  ],
                ),
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
                    itemBuilder: (context, idx) => Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                        title: Text(suggestions[idx]),
                        trailing: IconButton(icon: const Icon(Icons.add), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to routine')))),
                      ),
                    ),
                  ),
              ),
            ] else ...[
              Expanded(child: Center(child: Text('No suggestions yet. Adjust parameters and tap Generate.'))),
            ],
          ],
        ),
      ),
    );
  }
}
