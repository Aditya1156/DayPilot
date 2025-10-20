import 'package:cloud_firestore/cloud_firestore.dart';

/// User progress and gamification data
class UserProgress {
  final String userId;
  final int level;
  final int experiencePoints;
  final int totalTasksCompleted;
  final int currentStreak;
  final int longestStreak;
  final List<String> unlockedBadges;
  final Map<String, int> categoryMastery; // category -> completion count
  final DateTime lastActivityDate;

  UserProgress({
    required this.userId,
    this.level = 1,
    this.experiencePoints = 0,
    this.totalTasksCompleted = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.unlockedBadges = const [],
    this.categoryMastery = const {},
    required this.lastActivityDate,
  });

  // Calculate XP needed for next level (exponential growth)
  int get xpForNextLevel => (level * 100 * 1.5).toInt();

  // Calculate progress percentage to next level
  double get progressToNextLevel {
    final currentLevelXP = experiencePoints % xpForNextLevel;
    return currentLevelXP / xpForNextLevel;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'level': level,
      'experiencePoints': experiencePoints,
      'totalTasksCompleted': totalTasksCompleted,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'unlockedBadges': unlockedBadges,
      'categoryMastery': categoryMastery,
      'lastActivityDate': Timestamp.fromDate(lastActivityDate),
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['userId'] ?? '',
      level: map['level'] ?? 1,
      experiencePoints: map['experiencePoints'] ?? 0,
      totalTasksCompleted: map['totalTasksCompleted'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      unlockedBadges: List<String>.from(map['unlockedBadges'] ?? []),
      categoryMastery: Map<String, int>.from(map['categoryMastery'] ?? {}),
      lastActivityDate: (map['lastActivityDate'] as Timestamp).toDate(),
    );
  }

  UserProgress copyWith({
    int? level,
    int? experiencePoints,
    int? totalTasksCompleted,
    int? currentStreak,
    int? longestStreak,
    List<String>? unlockedBadges,
    Map<String, int>? categoryMastery,
    DateTime? lastActivityDate,
  }) {
    return UserProgress(
      userId: userId,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      categoryMastery: categoryMastery ?? this.categoryMastery,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }
}

/// Achievement/Badge system
class Badge {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final BadgeRarity rarity;
  final BadgeCategory category;
  final int xpReward;
  final Map<String, dynamic> unlockCriteria;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.rarity,
    required this.category,
    this.xpReward = 100,
    required this.unlockCriteria,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'rarity': rarity.name,
      'category': category.name,
      'xpReward': xpReward,
      'unlockCriteria': unlockCriteria,
    };
  }

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconName: map['iconName'] ?? '',
      rarity: BadgeRarity.values.firstWhere(
        (r) => r.name == map['rarity'],
        orElse: () => BadgeRarity.common,
      ),
      category: BadgeCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => BadgeCategory.general,
      ),
      xpReward: map['xpReward'] ?? 100,
      unlockCriteria: Map<String, dynamic>.from(map['unlockCriteria'] ?? {}),
    );
  }
}

enum BadgeRarity {
  common,
  rare,
  epic,
  legendary,
}

enum BadgeCategory {
  general,
  streak,
  productivity,
  wellness,
  social,
  mastery,
}

/// Weekly challenge
class WeeklyChallenge {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> goalCriteria;
  final int xpReward;
  final String? badgeReward;
  final List<String> participantIds;
  final Map<String, int> leaderboard; // userId -> score

  WeeklyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.goalCriteria,
    this.xpReward = 500,
    this.badgeReward,
    this.participantIds = const [],
    this.leaderboard = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'goalCriteria': goalCriteria,
      'xpReward': xpReward,
      'badgeReward': badgeReward,
      'participantIds': participantIds,
      'leaderboard': leaderboard,
    };
  }

  factory WeeklyChallenge.fromMap(Map<String, dynamic> map) {
    return WeeklyChallenge(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      goalCriteria: Map<String, dynamic>.from(map['goalCriteria'] ?? {}),
      xpReward: map['xpReward'] ?? 500,
      badgeReward: map['badgeReward'],
      participantIds: List<String>.from(map['participantIds'] ?? []),
      leaderboard: Map<String, int>.from(map['leaderboard'] ?? {}),
    );
  }
}

/// Predefined badges configuration
class PredefinedBadges {
  static final List<Badge> allBadges = [
    // Streak badges
    Badge(
      id: 'streak_3',
      name: 'Early Bird',
      description: 'Complete 3 days in a row',
      iconName: 'emoji_events',
      rarity: BadgeRarity.common,
      category: BadgeCategory.streak,
      xpReward: 50,
      unlockCriteria: {'type': 'streak', 'days': 3},
    ),
    Badge(
      id: 'streak_7',
      name: 'Consistent Champion',
      description: 'Maintain a 7-day streak',
      iconName: 'stars',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.streak,
      xpReward: 150,
      unlockCriteria: {'type': 'streak', 'days': 7},
    ),
    Badge(
      id: 'streak_30',
      name: 'Habit Master',
      description: '30-day streak! Unstoppable!',
      iconName: 'workspace_premium',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.streak,
      xpReward: 500,
      unlockCriteria: {'type': 'streak', 'days': 30},
    ),
    Badge(
      id: 'streak_100',
      name: 'Century Legend',
      description: '100 days of excellence',
      iconName: 'military_tech',
      rarity: BadgeRarity.legendary,
      category: BadgeCategory.streak,
      xpReward: 2000,
      unlockCriteria: {'type': 'streak', 'days': 100},
    ),

    // Productivity badges
    Badge(
      id: 'tasks_50',
      name: 'Go-Getter',
      description: 'Complete 50 tasks',
      iconName: 'task_alt',
      rarity: BadgeRarity.common,
      category: BadgeCategory.productivity,
      xpReward: 100,
      unlockCriteria: {'type': 'total_tasks', 'count': 50},
    ),
    Badge(
      id: 'tasks_200',
      name: 'Productivity Pro',
      description: 'Complete 200 tasks',
      iconName: 'verified',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.productivity,
      xpReward: 300,
      unlockCriteria: {'type': 'total_tasks', 'count': 200},
    ),
    Badge(
      id: 'perfect_day',
      name: 'Perfect Day',
      description: 'Complete all tasks in a day',
      iconName: 'check_circle',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.productivity,
      xpReward: 200,
      unlockCriteria: {'type': 'perfect_day'},
    ),
    Badge(
      id: 'early_riser',
      name: 'Morning Warrior',
      description: 'Complete morning routine 10 times',
      iconName: 'wb_sunny',
      rarity: BadgeRarity.common,
      category: BadgeCategory.productivity,
      xpReward: 100,
      unlockCriteria: {'type': 'morning_routine', 'count': 10},
    ),

    // Focus badges
    Badge(
      id: 'focus_master',
      name: 'Focus Master',
      description: 'Achieve 10 hours of deep focus',
      iconName: 'psychology',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.mastery,
      xpReward: 400,
      unlockCriteria: {'type': 'focus_hours', 'hours': 10},
    ),

    // Wellness badges
    Badge(
      id: 'wellness_week',
      name: 'Wellness Warrior',
      description: 'Complete health tasks for 7 days',
      iconName: 'favorite',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.wellness,
      xpReward: 200,
      unlockCriteria: {'type': 'health_streak', 'days': 7},
    ),
  ];
}
