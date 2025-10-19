import 'package:flutter/material.dart';

class AIOptimizationScreen extends StatelessWidget {
  const AIOptimizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Optimization'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: const [
                    Text('Weekly performance graph placeholder'),
                    SizedBox(height: 12),
                    Text('AI suggestions and Generate Optimized Routine button'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Generate Optimized Routine'),
            ),
          ],
        ),
      ),
    );
  }
}
