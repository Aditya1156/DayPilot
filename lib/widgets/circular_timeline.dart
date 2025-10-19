import 'dart:math';
import 'package:flutter/material.dart';
import 'package:daypilot/models/task.dart';
import 'package:daypilot/utils/theme.dart';

class CircularTimeline extends StatelessWidget {
  final List<Task> tasks;
  final double progress;

  const CircularTimeline({
    super.key,
    required this.tasks,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle (progress indicator)
          SizedBox(
            height: 200,
            width: 200,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          ),
          
          // Task markers around the circle
          ...List.generate(tasks.length, (index) {
            // Calculate position on the circle
            final angle = 2 * pi * (index / tasks.length);
            final radius = 85.0; // Slightly smaller than the progress indicator
            final x = radius * cos(angle);
            final y = radius * sin(angle);
            
            return Positioned(
              left: 100 + x - 15, // Center + offset - half of marker size
              top: 100 + y - 15,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: tasks[index].categoryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  tasks[index].categoryIcon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            );
          }),
          
          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              Text(
                'Completed',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}