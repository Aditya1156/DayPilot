import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_analytics_service.dart';
import '../services/gamification_service.dart';
import '../services/smart_alarm_service.dart';
import '../models/user_analytics.dart';
import '../models/gamification.dart';

// ==================== SERVICE PROVIDERS ====================

/// Provides AI Analytics Service instance
final aiAnalyticsServiceProvider = Provider<AIAnalyticsService>((ref) {
  return AIAnalyticsService();
});

/// Provides Gamification Service instance
final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService();
});

/// Provides Smart Alarm Service instance
final smartAlarmServiceProvider = Provider<SmartAlarmService>((ref) {
  return SmartAlarmService();
});

// ==================== USER PROGRESS PROVIDERS ====================

/// Fetches user progress data
final userProgressProvider = FutureProvider.family<UserProgress?, String>((ref, userId) async {
  final service = ref.read(gamificationServiceProvider);
  return await service.getUserProgress(userId);
});

/// Stream of user progress updates
final userProgressStreamProvider = StreamProvider.family<UserProgress?, String>((ref, userId) {
  return ref
      .read(gamificationServiceProvider)
      ._firestore
      .collection('user_progress')
      .doc(userId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return null;
    return UserProgress.fromMap(snapshot.data()!);
  });
});

// ==================== ANALYTICS PROVIDERS ====================

/// Fetches optimal time slots for user
final optimalTimeSlotsProvider = FutureProvider.family<Map<String, String>, String>((ref, userId) async {
  final service = ref.read(aiAnalyticsServiceProvider);
  return await service.getOptimalTimeSlots(userId);
});

/// Fetches daily rhythm analysis
final dailyRhythmProvider = FutureProvider.family<Map<String, ProductivitySlot>, String>((ref, userId) async {
  final service = ref.read(aiAnalyticsServiceProvider);
  return await service.analyzeDailyRhythm(userId);
});

/// Fetches routine suggestions for a date range
final routineSuggestionsProvider = FutureProvider.family<List<RoutineSuggestion>, RoutineSuggestionParams>(
  (ref, params) async {
    final service = ref.read(aiAnalyticsServiceProvider);
    return await service.generateAdaptiveRoutine(
      userId: params.userId,
      goals: params.goals,
      startDate: params.startDate,
      daysCount: params.daysCount,
    );
  },
);

// ==================== GAMIFICATION PROVIDERS ====================

/// Fetches recent badge unlocks
final recentBadgeUnlocksProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, userId) async {
    final service = ref.read(gamificationServiceProvider);
    return await service.getRecentBadgeUnlocks(userId, limit: 5);
  },
);

/// Fetches active weekly challenges
final activeChallengesProvider = FutureProvider<List<WeeklyChallenge>>((ref) async {
  final service = ref.read(gamificationServiceProvider);
  return await service.getActiveChallenges();
});

/// Fetches leaderboard for a challenge
final challengeLeaderboardProvider = FutureProvider.family<List<MapEntry<String, int>>, String>(
  (ref, challengeId) async {
    final service = ref.read(gamificationServiceProvider);
    return await service.getChallengeLeaderboard(challengeId);
  },
);

// ==================== ALARM PROVIDERS ====================

/// Fetches active alarms for user
final activeAlarmsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, userId) async {
    final service = ref.read(smartAlarmServiceProvider);
    return await service.getActiveAlarms(userId);
  },
);

// ==================== STATE NOTIFIERS ====================

/// Manages current mood state
class MoodState {
  final String? mood;
  final int? energyLevel;
  final DateTime? timestamp;

  MoodState({this.mood, this.energyLevel, this.timestamp});

  MoodState copyWith({String? mood, int? energyLevel, DateTime? timestamp}) {
    return MoodState(
      mood: mood ?? this.mood,
      energyLevel: energyLevel ?? this.energyLevel,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class MoodNotifier extends StateNotifier<MoodState> {
  MoodNotifier() : super(MoodState());

  void setMood(String mood, int energyLevel) {
    state = state.copyWith(
      mood: mood,
      energyLevel: energyLevel,
      timestamp: DateTime.now(),
    );
  }

  void clearMood() {
    state = MoodState();
  }
}

final moodProvider = StateNotifierProvider<MoodNotifier, MoodState>((ref) {
  return MoodNotifier();
});

/// Manages user goals
class UserGoalsNotifier extends StateNotifier<List<String>> {
  UserGoalsNotifier() : super([]);

  void addGoal(String goal) {
    state = [...state, goal];
  }

  void removeGoal(String goal) {
    state = state.where((g) => g != goal).toList();
  }

  void setGoals(List<String> goals) {
    state = goals;
  }

  void clearGoals() {
    state = [];
  }
}

final userGoalsProvider = StateNotifierProvider<UserGoalsNotifier, List<String>>((ref) {
  return UserGoalsNotifier();
});

/// Manages user persona
class UserPersonaNotifier extends StateNotifier<UserPersona> {
  UserPersonaNotifier() : super(UserPersona.general);

  void setPersona(UserPersona persona) {
    state = persona;
  }
}

final userPersonaProvider = StateNotifierProvider<UserPersonaNotifier, UserPersona>((ref) {
  return UserPersonaNotifier();
});

// ==================== HELPER CLASSES ====================

/// Parameters for routine suggestion provider
class RoutineSuggestionParams {
  final String userId;
  final List<String> goals;
  final DateTime startDate;
  final int daysCount;

  RoutineSuggestionParams({
    required this.userId,
    required this.goals,
    required this.startDate,
    this.daysCount = 7,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoutineSuggestionParams &&
        other.userId == userId &&
        other.goals.toString() == goals.toString() &&
        other.startDate == startDate &&
        other.daysCount == daysCount;
  }

  @override
  int get hashCode {
    return userId.hashCode ^ goals.hashCode ^ startDate.hashCode ^ daysCount.hashCode;
  }
}
