import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents user analytics data for AI-powered insights
class UserAnalytics {
  final String userId;
  final DateTime date;
  final Map<String, dynamic> productivityData;
  final Map<String, dynamic> energyLevels;
  final Map<String, dynamic> completionPatterns;
  final String? mood;
  final int focusScore;
  final int tasksCompleted;
  final int tasksMissed;
  final Map<String, int> categoryBreakdown;

  UserAnalytics({
    required this.userId,
    required this.date,
    required this.productivityData,
    required this.energyLevels,
    required this.completionPatterns,
    this.mood,
    this.focusScore = 0,
    this.tasksCompleted = 0,
    this.tasksMissed = 0,
    this.categoryBreakdown = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'productivityData': productivityData,
      'energyLevels': energyLevels,
      'completionPatterns': completionPatterns,
      'mood': mood,
      'focusScore': focusScore,
      'tasksCompleted': tasksCompleted,
      'tasksMissed': tasksMissed,
      'categoryBreakdown': categoryBreakdown,
    };
  }

  factory UserAnalytics.fromMap(Map<String, dynamic> map) {
    return UserAnalytics(
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      productivityData: Map<String, dynamic>.from(map['productivityData'] ?? {}),
      energyLevels: Map<String, dynamic>.from(map['energyLevels'] ?? {}),
      completionPatterns: Map<String, dynamic>.from(map['completionPatterns'] ?? {}),
      mood: map['mood'],
      focusScore: map['focusScore'] ?? 0,
      tasksCompleted: map['tasksCompleted'] ?? 0,
      tasksMissed: map['tasksMissed'] ?? 0,
      categoryBreakdown: Map<String, int>.from(map['categoryBreakdown'] ?? {}),
    );
  }
}

/// User persona types for role-based experiences
enum UserPersona {
  student,
  professional,
  athlete,
  wellness,
  general,
}

extension UserPersonaExtension on UserPersona {
  String get displayName {
    switch (this) {
      case UserPersona.student:
        return 'Student';
      case UserPersona.professional:
        return 'Professional';
      case UserPersona.athlete:
        return 'Athlete';
      case UserPersona.wellness:
        return 'Wellness Focused';
      case UserPersona.general:
        return 'General';
    }
  }

  String get description {
    switch (this) {
      case UserPersona.student:
        return 'Optimized for study schedules, exams, and learning';
      case UserPersona.professional:
        return 'Focus on productivity, meetings, and deep work';
      case UserPersona.athlete:
        return 'Training schedules, nutrition, and recovery';
      case UserPersona.wellness:
        return 'Mental health, mindfulness, and balance';
      case UserPersona.general:
        return 'Balanced approach for everyday life';
    }
  }
}

/// Daily mood entry
class MoodEntry {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String mood; // 😄 great, 😐 okay, 😩 tired, 😰 stressed, 😊 happy
  final int energyLevel; // 1-5
  final String? notes;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.mood,
    required this.energyLevel,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      'mood': mood,
      'energyLevel': energyLevel,
      'notes': notes,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      mood: map['mood'] ?? '😐',
      energyLevel: map['energyLevel'] ?? 3,
      notes: map['notes'],
    );
  }
}

/// Productivity time slot analysis
class ProductivitySlot {
  final String timeSlot; // e.g., "06:00-09:00", "09:00-12:00"
  final double productivityScore; // 0-100
  final int tasksCompleted;
  final double averageFocusDuration; // in minutes
  final List<String> commonCategories;

  ProductivitySlot({
    required this.timeSlot,
    required this.productivityScore,
    required this.tasksCompleted,
    required this.averageFocusDuration,
    required this.commonCategories,
  });

  Map<String, dynamic> toMap() {
    return {
      'timeSlot': timeSlot,
      'productivityScore': productivityScore,
      'tasksCompleted': tasksCompleted,
      'averageFocusDuration': averageFocusDuration,
      'commonCategories': commonCategories,
    };
  }

  factory ProductivitySlot.fromMap(Map<String, dynamic> map) {
    return ProductivitySlot(
      timeSlot: map['timeSlot'] ?? '',
      productivityScore: (map['productivityScore'] ?? 0).toDouble(),
      tasksCompleted: map['tasksCompleted'] ?? 0,
      averageFocusDuration: (map['averageFocusDuration'] ?? 0).toDouble(),
      commonCategories: List<String>.from(map['commonCategories'] ?? []),
    );
  }
}

/// AI-generated routine suggestion
class RoutineSuggestion {
  final String id;
  final String userId;
  final DateTime targetDate;
  final List<TaskSuggestion> suggestedTasks;
  final double confidenceScore; // 0-100
  final String reasoning;
  final DateTime createdAt;
  final bool isAccepted;

  RoutineSuggestion({
    required this.id,
    required this.userId,
    required this.targetDate,
    required this.suggestedTasks,
    required this.confidenceScore,
    required this.reasoning,
    required this.createdAt,
    this.isAccepted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'targetDate': Timestamp.fromDate(targetDate),
      'suggestedTasks': suggestedTasks.map((t) => t.toMap()).toList(),
      'confidenceScore': confidenceScore,
      'reasoning': reasoning,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAccepted': isAccepted,
    };
  }

  factory RoutineSuggestion.fromMap(Map<String, dynamic> map) {
    return RoutineSuggestion(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      targetDate: (map['targetDate'] as Timestamp).toDate(),
      suggestedTasks: (map['suggestedTasks'] as List)
          .map((t) => TaskSuggestion.fromMap(t))
          .toList(),
      confidenceScore: (map['confidenceScore'] ?? 0).toDouble(),
      reasoning: map['reasoning'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isAccepted: map['isAccepted'] ?? false,
    );
  }
}

/// Individual task suggestion within a routine
class TaskSuggestion {
  final String title;
  final String category;
  final DateTime suggestedStartTime;
  final DateTime suggestedEndTime;
  final String? description;
  final int priorityScore; // 1-10

  TaskSuggestion({
    required this.title,
    required this.category,
    required this.suggestedStartTime,
    required this.suggestedEndTime,
    this.description,
    this.priorityScore = 5,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'suggestedStartTime': Timestamp.fromDate(suggestedStartTime),
      'suggestedEndTime': Timestamp.fromDate(suggestedEndTime),
      'description': description,
      'priorityScore': priorityScore,
    };
  }

  factory TaskSuggestion.fromMap(Map<String, dynamic> map) {
    return TaskSuggestion(
      title: map['title'] ?? '',
      category: map['category'] ?? 'personal',
      suggestedStartTime: (map['suggestedStartTime'] as Timestamp).toDate(),
      suggestedEndTime: (map['suggestedEndTime'] as Timestamp).toDate(),
      description: map['description'],
      priorityScore: map['priorityScore'] ?? 5,
    );
  }
}
