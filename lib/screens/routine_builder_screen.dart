import 'package:flutter/material.dart';

class RoutineBuilderScreen extends StatelessWidget {
  const RoutineBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routine Builder'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Drag-and-drop routine builder (UI scaffold).\nIntegrate drag/drop and AI suggestions here.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
