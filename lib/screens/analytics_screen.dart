import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Weekly overview: Tasks done %, Focus hours, Streaks'),
            SizedBox(height: 12),
            Text('Charts and AI insight cards go here.'),
          ],
        ),
      ),
    );
  }
}
