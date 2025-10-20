import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gamification.dart';
import '../models/task.dart';

/// Service for managing gamification features
class GamificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== XP & LEVELING ====================

  /// Awards XP to user and handles level-ups
  Future<UserProgress> awardXP({
    required String userId,
    required int xpAmount,
    required String reason,
  }) async {
    try {
      final docRef = _firestore.collection('user_progress').doc(userId);
      final doc = await docRef.get();

      UserProgress progress;
      if (doc.exists) {
        progress = UserProgress.fromMap(doc.data()!);
      } else {
        progress = UserProgress(
          userId: userId,
          lastActivityDate: DateTime.now(),
        );
      }

      // Add XP
      int newXP = progress.experiencePoints + xpAmount;
      int newLevel = progress.level;

      // Check for level up
      while (newXP >= _xpForLevel(newLevel + 1)) {
        newXP -= _xpForLevel(newLevel + 1);
        newLevel++;
        
        // Award level-up bonus
        await _awardLevelUpBadge(userId, newLevel);
      }

      final updatedProgress = progress.copyWith(
        experiencePoints: newXP + (_xpForLevel(newLevel) * (newLevel - 1)),
        level: newLevel,
        lastActivityDate: DateTime.now(),
      );

      await docRef.set(updatedProgress.toMap());

      // Log XP transaction
      await _logXPTransaction(userId, xpAmount, reason);

      return updatedProgress;
    } catch (e) {
      print('Error awarding XP: $e');
      rethrow;
    }
  }

  int _xpForLevel(int level) => (level * 100 * 1.5).toInt();

  /// Handles task completion and awards appropriate XP
  Future<UserProgress> handleTaskCompletion({
    required String userId,
    required Task task,
  }) async {
    // Calculate XP based on task properties
    int xp = 20; // Base XP

    // Category multipliers
    switch (task.category) {
      case TaskCategory.work:
      case TaskCategory.study:
        xp += 10; // More XP for productive tasks
        break;
      case TaskCategory.health:
        xp += 5;
        break;
      default:
        break;
    }

    // Duration bonus
    final durationHours = task.endTime.difference(task.startTime).inHours;
    if (durationHours >= 2) xp += 10;

    final progress = await awardXP(
      userId: userId,
      xpAmount: xp,
      reason: 'Completed: ${task.title}',
    );

    // Update task completion count
    await _firestore.collection('user_progress').doc(userId).update({
      'totalTasksCompleted': FieldValue.increment(1),
      'categoryMastery.${task.category.name}': FieldValue.increment(1),
    });

    // Check for badge unlocks
    await checkBadgeUnlocks(userId);

    return progress;
  }

  // ==================== STREAK MANAGEMENT ====================

  /// Updates user's streak based on activity
  Future<UserProgress> updateStreak(String userId) async {
    try {
      final docRef = _firestore.collection('user_progress').doc(userId);
      final doc = await docRef.get();

      if (!doc.exists) {
        return UserProgress(
          userId: userId,
          currentStreak: 1,
          longestStreak: 1,
          lastActivityDate: DateTime.now(),
        );
      }

      final progress = UserProgress.fromMap(doc.data()!);
      final now = DateTime.now();
      final lastActivity = progress.lastActivityDate;

      final daysDiff = now.difference(lastActivity).inDays;

      int newStreak = progress.currentStreak;
      int newLongest = progress.longestStreak;

      if (daysDiff == 0) {
        // Same day, no change
        return progress;
      } else if (daysDiff == 1) {
        // Consecutive day, increment streak
        newStreak++;
        if (newStreak > newLongest) {
          newLongest = newStreak;
        }

        // Award streak XP
        await awardXP(
          userId: userId,
          xpAmount: 10 + (newStreak * 2), // More XP for longer streaks
          reason: '🔥 ${newStreak}-day streak!',
        );
      } else {
        // Streak broken
        newStreak = 1;
      }

      final updatedProgress = progress.copyWith(
        currentStreak: newStreak,
        longestStreak: newLongest,
        lastActivityDate: now,
      );

      await docRef.set(updatedProgress.toMap());

      // Check streak badges
      await _checkStreakBadges(userId, newStreak);

      return updatedProgress;
    } catch (e) {
      print('Error updating streak: $e');
      rethrow;
    }
  }

  // ==================== BADGE SYSTEM ====================

  /// Checks and unlocks badges based on user progress
  Future<List<Badge>> checkBadgeUnlocks(String userId) async {
    try {
      final progressDoc = await _firestore.collection('user_progress').doc(userId).get();
      if (!progressDoc.exists) return [];

      final progress = UserProgress.fromMap(progressDoc.data()!);
      final newBadges = <Badge>[];

      for (var badge in PredefinedBadges.allBadges) {
        // Skip if already unlocked
        if (progress.unlockedBadges.contains(badge.id)) continue;

        // Check unlock criteria
        if (await _checkBadgeCriteria(badge, progress)) {
          await _unlockBadge(userId, badge);
          newBadges.add(badge);
        }
      }

      return newBadges;
    } catch (e) {
      print('Error checking badge unlocks: $e');
      return [];
    }
  }

  Future<bool> _checkBadgeCriteria(Badge badge, UserProgress progress) async {
    final criteria = badge.unlockCriteria;
    final type = criteria['type'] as String?;

    switch (type) {
      case 'streak':
        final requiredDays = criteria['days'] as int;
        return progress.currentStreak >= requiredDays;

      case 'total_tasks':
        final requiredCount = criteria['count'] as int;
        return progress.totalTasksCompleted >= requiredCount;

      case 'perfect_day':
        // Check if user completed all tasks today (implementation needed)
        return false; // Placeholder

      case 'morning_routine':
        // Check morning routine completion count
        return false; // Placeholder

      case 'focus_hours':
        // Check total focus hours
        return false; // Placeholder

      case 'health_streak':
        // Check health category streak
        return false; // Placeholder

      default:
        return false;
    }
  }

  Future<void> _unlockBadge(String userId, Badge badge) async {
    await _firestore.collection('user_progress').doc(userId).update({
      'unlockedBadges': FieldValue.arrayUnion([badge.id]),
    });

    // Award badge XP
    await awardXP(
      userId: userId,
      xpAmount: badge.xpReward,
      reason: '🏆 Unlocked: ${badge.name}',
    );

    // Save badge unlock notification
    await _firestore.collection('badge_unlocks').add({
      'userId': userId,
      'badgeId': badge.id,
      'badgeName': badge.name,
      'unlockedAt': FieldValue.serverTimestamp(),
      'seen': false,
    });
  }

  Future<void> _checkStreakBadges(String userId, int streak) async {
    final streakMilestones = [3, 7, 30, 100];
    
    for (var milestone in streakMilestones) {
      if (streak == milestone) {
        final badge = PredefinedBadges.allBadges.firstWhere(
          (b) => b.unlockCriteria['type'] == 'streak' && 
                 b.unlockCriteria['days'] == milestone,
        );
        await _unlockBadge(userId, badge);
      }
    }
  }

  Future<void> _awardLevelUpBadge(String userId, int level) async {
    // Award special badges at milestone levels
    final milestones = [5, 10, 25, 50, 100];
    
    if (milestones.contains(level)) {
      await _firestore.collection('badge_unlocks').add({
        'userId': userId,
        'badgeId': 'level_$level',
        'badgeName': 'Level $level Master',
        'unlockedAt': FieldValue.serverTimestamp(),
        'seen': false,
      });
    }
  }

  // ==================== WEEKLY CHALLENGES ====================

  /// Creates a new weekly challenge
  Future<WeeklyChallenge> createWeeklyChallenge({
    required String title,
    required String description,
    required Map<String, dynamic> goalCriteria,
    int xpReward = 500,
    String? badgeReward,
  }) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final challenge = WeeklyChallenge(
      id: 'challenge_${now.millisecondsSinceEpoch}',
      title: title,
      description: description,
      startDate: startOfWeek,
      endDate: endOfWeek,
      goalCriteria: goalCriteria,
      xpReward: xpReward,
      badgeReward: badgeReward,
    );

    await _firestore
        .collection('weekly_challenges')
        .doc(challenge.id)
        .set(challenge.toMap());

    return challenge;
  }

  /// Joins a user to a challenge
  Future<void> joinChallenge(String userId, String challengeId) async {
    await _firestore.collection('weekly_challenges').doc(challengeId).update({
      'participantIds': FieldValue.arrayUnion([userId]),
      'leaderboard.$userId': 0,
    });
  }

  /// Updates user's challenge progress
  Future<void> updateChallengeProgress({
    required String userId,
    required String challengeId,
    required int points,
  }) async {
    await _firestore.collection('weekly_challenges').doc(challengeId).update({
      'leaderboard.$userId': FieldValue.increment(points),
    });
  }

  /// Gets active challenges
  Future<List<WeeklyChallenge>> getActiveChallenges() async {
    final now = DateTime.now();
    
    final snapshot = await _firestore
        .collection('weekly_challenges')
        .where('endDate', isGreaterThan: Timestamp.fromDate(now))
        .get();

    return snapshot.docs
        .map((doc) => WeeklyChallenge.fromMap(doc.data()))
        .toList();
  }

  /// Gets leaderboard for a challenge
  Future<List<MapEntry<String, int>>> getChallengeLeaderboard(
    String challengeId,
  ) async {
    final doc = await _firestore
        .collection('weekly_challenges')
        .doc(challengeId)
        .get();

    if (!doc.exists) return [];

    final challenge = WeeklyChallenge.fromMap(doc.data()!);
    final leaderboard = challenge.leaderboard.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return leaderboard;
  }

  // ==================== UTILITY METHODS ====================

  Future<void> _logXPTransaction(String userId, int xpAmount, String reason) async {
    await _firestore.collection('xp_transactions').add({
      'userId': userId,
      'amount': xpAmount,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Gets user's progress data
  Future<UserProgress?> getUserProgress(String userId) async {
    final doc = await _firestore.collection('user_progress').doc(userId).get();
    
    if (!doc.exists) return null;
    
    return UserProgress.fromMap(doc.data()!);
  }

  /// Gets recent badge unlocks for a user
  Future<List<Map<String, dynamic>>> getRecentBadgeUnlocks(
    String userId, {
    int limit = 5,
  }) async {
    final snapshot = await _firestore
        .collection('badge_unlocks')
        .where('userId', isEqualTo: userId)
        .orderBy('unlockedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Marks badge unlock notification as seen
  Future<void> markBadgeUnlockSeen(String unlockId) async {
    await _firestore.collection('badge_unlocks').doc(unlockId).update({
      'seen': true,
    });
  }
}
