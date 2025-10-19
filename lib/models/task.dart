import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
enum TaskStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
  @HiveField(3)
  missed,
}

@HiveType(typeId: 1)
enum TaskCategory {
  @HiveField(0)
  work,
  @HiveField(1)
  health,
  @HiveField(2)
  study,
  @HiveField(3)
  personal,
}

@HiveType(typeId: 2)
class Task extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final TaskCategory category;
  @HiveField(4)
  final DateTime startTime;
  @HiveField(5)
  final DateTime endTime;
  @HiveField(6)
  TaskStatus status;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.startTime,
    required this.endTime,
    this.status = TaskStatus.pending,
  });

  // Get color based on category
  Color get categoryColor {
    switch (category) {
      case TaskCategory.work:
        return const Color(0xFF3A86FF); // Blue
      case TaskCategory.health:
        return const Color(0xFF06D6A0); // Green
      case TaskCategory.study:
        return const Color(0xFF8338EC); // Purple
      case TaskCategory.personal:
        return const Color(0xFFFFBE0B); // Yellow
    }
  }

  // Get icon based on category
  IconData get categoryIcon {
    switch (category) {
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.health:
        return Icons.fitness_center;
      case TaskCategory.study:
        return Icons.school;
      case TaskCategory.personal:
        return Icons.person;
    }
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toString(),
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'status': status.toString(),
    };
  }

  // Create from Map (Firestore)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: TaskCategory.values.firstWhere(
        (e) => e.toString() == map['category'],
        orElse: () => TaskCategory.personal,
      ),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => TaskStatus.pending,
      ),
    );
  }
}