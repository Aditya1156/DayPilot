import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/task.dart';
import '../models/user_analytics.dart';
import '../models/gamification.dart';

/// AI-powered analytics and insights service
class AIAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== DAILY RHYTHM ANALYZER ====================

  /// Analyzes user's productivity patterns over the past 30 days
  Future<Map<String, ProductivitySlot>> analyzeDailyRhythm(String userId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final analyticsSnapshot = await _firestore
          .collection('user_analytics')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      // Time slots (3-hour blocks)
      final Map<String, List<double>> slotScores = {
        '06:00-09:00': [],
        '09:00-12:00': [],
        '12:00-15:00': [],
        '15:00-18:00': [],
        '18:00-21:00': [],
        '21:00-00:00': [],
      };

      final Map<String, List<int>> slotTaskCounts = {
        '06:00-09:00': [],
        '09:00-12:00': [],
        '12:00-15:00': [],
        '15:00-18:00': [],
        '18:00-21:00': [],
        '21:00-00:00': [],
      };

      final Map<String, Set<String>> slotCategories = {
        '06:00-09:00': {},
        '09:00-12:00': {},
        '12:00-15:00': {},
        '15:00-18:00': {},
        '18:00-21:00': {},
        '21:00-00:00': {},
      };

      // Analyze each day's data
      for (var doc in analyticsSnapshot.docs) {
        final analytics = UserAnalytics.fromMap(doc.data());
        final productivityData = analytics.productivityData;

        for (var slot in slotScores.keys) {
          if (productivityData.containsKey(slot)) {
            slotScores[slot]!.add(productivityData[slot]['score'] ?? 0.0);
            slotTaskCounts[slot]!.add(productivityData[slot]['tasksCompleted'] ?? 0);
            
            final categories = productivityData[slot]['categories'] as List<dynamic>?;
            if (categories != null) {
              slotCategories[slot]!.addAll(categories.cast<String>());
            }
          }
        }
      }

      // Calculate average productivity for each slot
      final Map<String, ProductivitySlot> productivitySlots = {};
      
      for (var slot in slotScores.keys) {
        final scores = slotScores[slot]!;
        final taskCounts = slotTaskCounts[slot]!;
        
        if (scores.isEmpty) continue;

        final avgScore = scores.reduce((a, b) => a + b) / scores.length;
        final avgTasks = taskCounts.reduce((a, b) => a + b) / taskCounts.length;
        
        productivitySlots[slot] = ProductivitySlot(
          timeSlot: slot,
          productivityScore: avgScore,
          tasksCompleted: avgTasks.toInt(),
          averageFocusDuration: avgScore * 0.6, // Estimate focus duration
          commonCategories: slotCategories[slot]!.toList(),
        );
      }

      return productivitySlots;
    } catch (e) {
      print('Error analyzing daily rhythm: $e');
      return {};
    }
  }

  /// Gets the best time slots for specific task categories
  Future<Map<String, String>> getOptimalTimeSlots(String userId) async {
    final productivitySlots = await analyzeDailyRhythm(userId);
    
    if (productivitySlots.isEmpty) {
      // Return default recommendations if no data
      return {
        'study': '09:00-12:00',
        'work': '09:00-12:00',
        'health': '06:00-09:00',
        'personal': '18:00-21:00',
      };
    }

    // Sort slots by productivity score
    final sortedSlots = productivitySlots.entries.toList()
      ..sort((a, b) => b.value.productivityScore.compareTo(a.value.productivityScore));

    final recommendations = <String, String>{};
    
    // Assign best slots to different categories
    for (var i = 0; i < sortedSlots.length && i < 4; i++) {
      final slot = sortedSlots[i].key;
      final categories = sortedSlots[i].value.commonCategories;
      
      if (categories.contains('study') && !recommendations.containsKey('study')) {
        recommendations['study'] = slot;
      } else if (categories.contains('work') && !recommendations.containsKey('work')) {
        recommendations['work'] = slot;
      } else if (categories.contains('health') && !recommendations.containsKey('health')) {
        recommendations['health'] = slot;
      } else if (!recommendations.containsKey('personal')) {
        recommendations['personal'] = slot;
      }
    }

    return recommendations;
  }

  // ==================== ADAPTIVE ROUTINE GENERATION ====================

  /// Generates an AI-powered routine for the week based on user goals
  Future<List<RoutineSuggestion>> generateAdaptiveRoutine({
    required String userId,
    required List<String> goals,
    required DateTime startDate,
    int daysCount = 7,
  }) async {
    try {
      final optimalSlots = await getOptimalTimeSlots(userId);
      final userMoodHistory = await _getMoodHistory(userId, days: 7);
      final suggestions = <RoutineSuggestion>[];

      for (var i = 0; i < daysCount; i++) {
        final targetDate = startDate.add(Duration(days: i));
        final dayTasks = await _generateDayTasks(
          userId: userId,
          goals: goals,
          targetDate: targetDate,
          optimalSlots: optimalSlots,
          avgMoodScore: _calculateAverageMood(userMoodHistory),
        );

        final suggestion = RoutineSuggestion(
          id: '${userId}_${targetDate.millisecondsSinceEpoch}',
          userId: userId,
          targetDate: targetDate,
          suggestedTasks: dayTasks,
          confidenceScore: _calculateConfidenceScore(userMoodHistory),
          reasoning: _generateReasoning(goals, optimalSlots, userMoodHistory),
          createdAt: DateTime.now(),
        );

        suggestions.add(suggestion);
      }

      // Save suggestions to Firestore
      for (var suggestion in suggestions) {
        await _firestore
            .collection('routine_suggestions')
            .doc(suggestion.id)
            .set(suggestion.toMap());
      }

      return suggestions;
    } catch (e) {
      print('Error generating adaptive routine: $e');
      return [];
    }
  }

  Future<List<TaskSuggestion>> _generateDayTasks({
    required String userId,
    required List<String> goals,
    required DateTime targetDate,
    required Map<String, String> optimalSlots,
    required double avgMoodScore,
  }) async {
    final tasks = <TaskSuggestion>[];
    final random = Random();

    // Parse goals and generate tasks
    for (var goal in goals) {
      final goalLower = goal.toLowerCase();
      
      if (goalLower.contains('gate') || goalLower.contains('exam') || goalLower.contains('study')) {
        // Study-focused tasks
        final studySlot = optimalSlots['study'] ?? '09:00-12:00';
        final startTime = _parseTimeSlot(targetDate, studySlot).start;
        
        tasks.add(TaskSuggestion(
          title: 'Study Session: ${_extractSubject(goal)}',
          category: 'study',
          suggestedStartTime: startTime,
          suggestedEndTime: startTime.add(const Duration(hours: 2)),
          description: 'Focused study session during your peak productivity time',
          priorityScore: 9,
        ));

        // Add practice session
        tasks.add(TaskSuggestion(
          title: 'Practice Problems',
          category: 'study',
          suggestedStartTime: startTime.add(const Duration(hours: 3)),
          suggestedEndTime: startTime.add(const Duration(hours: 4)),
          description: 'Solve practice problems to reinforce learning',
          priorityScore: 8,
        ));
      }
      
      if (goalLower.contains('fitness') || goalLower.contains('gym') || goalLower.contains('health')) {
        // Fitness tasks
        final healthSlot = optimalSlots['health'] ?? '06:00-09:00';
        final startTime = _parseTimeSlot(targetDate, healthSlot).start;
        
        tasks.add(TaskSuggestion(
          title: 'Workout Session',
          category: 'health',
          suggestedStartTime: startTime,
          suggestedEndTime: startTime.add(const Duration(minutes: 45)),
          description: 'Your optimal workout time based on energy patterns',
          priorityScore: 8,
        ));
      }

      if (goalLower.contains('project') || goalLower.contains('work')) {
        // Work/Project tasks
        final workSlot = optimalSlots['work'] ?? '09:00-12:00';
        final startTime = _parseTimeSlot(targetDate, workSlot).start;
        
        tasks.add(TaskSuggestion(
          title: 'Project Work: ${_extractProjectName(goal)}',
          category: 'work',
          suggestedStartTime: startTime,
          suggestedEndTime: startTime.add(const Duration(hours: 2)),
          description: 'Deep work session on your project',
          priorityScore: 9,
        ));
      }
    }

    // Add wellness tasks if mood is low
    if (avgMoodScore < 3.0) {
      tasks.add(TaskSuggestion(
        title: 'Mindfulness Break',
        category: 'personal',
        suggestedStartTime: targetDate.add(const Duration(hours: 12)),
        suggestedEndTime: targetDate.add(const Duration(hours: 12, minutes: 15)),
        description: 'Take a break to recharge',
        priorityScore: 7,
      ));
    }

    // Sort by priority and time
    tasks.sort((a, b) {
      final timeCompare = a.suggestedStartTime.compareTo(b.suggestedStartTime);
      if (timeCompare != 0) return timeCompare;
      return b.priorityScore.compareTo(a.priorityScore);
    });

    return tasks;
  }

  // ==================== MOOD-BASED ADJUSTMENTS ====================

  /// Adjusts today's routine based on current mood
  Future<List<Task>> adjustRoutineByMood({
    required String userId,
    required List<Task> todaysTasks,
    required String mood,
    required int energyLevel,
  }) async {
    try {
      // Save mood entry
      final moodEntry = MoodEntry(
        id: '${userId}_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        timestamp: DateTime.now(),
        mood: mood,
        energyLevel: energyLevel,
      );

      await _firestore
          .collection('mood_entries')
          .doc(moodEntry.id)
          .set(moodEntry.toMap());

      // Adjust tasks based on mood
      final adjustedTasks = <Task>[];
      
      for (var task in todaysTasks) {
        if (energyLevel <= 2 && mood == '😩') {
          // Low energy - prioritize lighter tasks
          if (task.category == TaskCategory.personal || 
              task.category == TaskCategory.others) {
            adjustedTasks.add(task);
          } else {
            // Move heavy tasks to later
            adjustedTasks.add(task.copyWith(
              startTime: task.startTime.add(const Duration(hours: 2)),
              endTime: task.endTime.add(const Duration(hours: 2)),
            ));
          }
        } else if (energyLevel >= 4 && mood == '😄') {
          // High energy - front-load important tasks
          if (task.category == TaskCategory.work || 
              task.category == TaskCategory.study) {
            adjustedTasks.insert(0, task);
          } else {
            adjustedTasks.add(task);
          }
        } else {
          // Normal mood - keep tasks as is
          adjustedTasks.add(task);
        }
      }

      return adjustedTasks;
    } catch (e) {
      print('Error adjusting routine by mood: $e');
      return todaysTasks;
    }
  }

  // ==================== HELPER METHODS ====================

  Future<List<MoodEntry>> _getMoodHistory(String userId, {int days = 7}) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    
    final snapshot = await _firestore
        .collection('mood_entries')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(startDate))
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => MoodEntry.fromMap(doc.data())).toList();
  }

  double _calculateAverageMood(List<MoodEntry> moodHistory) {
    if (moodHistory.isEmpty) return 3.0;
    
    final sum = moodHistory.fold<int>(0, (sum, entry) => sum + entry.energyLevel);
    return sum / moodHistory.length;
  }

  double _calculateConfidenceScore(List<MoodEntry> moodHistory) {
    if (moodHistory.isEmpty) return 50.0;
    
    // Higher confidence if consistent mood patterns
    final variance = _calculateVariance(
      moodHistory.map((e) => e.energyLevel.toDouble()).toList()
    );
    
    return max(50.0, 100.0 - (variance * 10));
  }

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => pow(v - mean, 2));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  String _generateReasoning(
    List<String> goals,
    Map<String, String> optimalSlots,
    List<MoodEntry> moodHistory,
  ) {
    final avgMood = _calculateAverageMood(moodHistory);
    final confidence = _calculateConfidenceScore(moodHistory);
    
    return 'Based on your ${goals.length} active goals and '
        '${moodHistory.length} days of mood data (avg energy: ${avgMood.toStringAsFixed(1)}/5), '
        'this routine is optimized for your peak productivity times. '
        'Confidence: ${confidence.toStringAsFixed(0)}%';
  }

  ({DateTime start, DateTime end}) _parseTimeSlot(DateTime date, String slot) {
    final parts = slot.split('-');
    final startParts = parts[0].split(':');
    final endParts = parts[1].split(':');
    
    return (
      start: DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      ),
      end: DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      ),
    );
  }

  String _extractSubject(String goal) {
    // Simple extraction - can be enhanced with NLP
    final keywords = ['gate', 'math', 'physics', 'chemistry', 'coding', 'english'];
    for (var keyword in keywords) {
      if (goal.toLowerCase().contains(keyword)) {
        return keyword.toUpperCase();
      }
    }
    return 'General';
  }

  String _extractProjectName(String goal) {
    // Extract project name from goal
    final words = goal.split(' ');
    if (words.length > 2) {
      return words.sublist(0, min(3, words.length)).join(' ');
    }
    return 'Current Project';
  }

  /// Records task completion for analytics
  Future<void> recordTaskCompletion({
    required String userId,
    required Task task,
    required DateTime completionTime,
  }) async {
    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month}-${today.day}';
      final docId = '${userId}_$todayStr';

      final timeSlot = _getTimeSlot(completionTime);
      
      await _firestore
          .collection('user_analytics')
          .doc(docId)
          .set({
        'userId': userId,
        'date': Timestamp.fromDate(today),
        'productivityData.$timeSlot': {
          'score': FieldValue.increment(10),
          'tasksCompleted': FieldValue.increment(1),
          'categories': FieldValue.arrayUnion([task.category.name]),
        },
        'tasksCompleted': FieldValue.increment(1),
        'categoryBreakdown.${task.category.name}': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error recording task completion: $e');
    }
  }

  String _getTimeSlot(DateTime time) {
    final hour = time.hour;
    if (hour >= 6 && hour < 9) return '06:00-09:00';
    if (hour >= 9 && hour < 12) return '09:00-12:00';
    if (hour >= 12 && hour < 15) return '12:00-15:00';
    if (hour >= 15 && hour < 18) return '15:00-18:00';
    if (hour >= 18 && hour < 21) return '18:00-21:00';
    return '21:00-00:00';
  }
}
