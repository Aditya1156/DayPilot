import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import '../utils/theme.dart';
import '../models/gamification.dart';
import '../providers/ai_providers.dart';
import '../services/haptic_service.dart';
import '../services/gamification_service.dart';
import '../widgets/xp_progress_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Comprehensive gamification hub with XP, badges, challenges, and leaderboards
class GamificationHubScreen extends ConsumerStatefulWidget {
  const GamificationHubScreen({super.key});

  @override
  ConsumerState<GamificationHubScreen> createState() => _GamificationHubScreenState();
}

class _GamificationHubScreenState extends ConsumerState<GamificationHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final progressAsync = ref.watch(userProgressProvider(userId));

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryExtraLight,
                  AppColors.secondaryLight,
                  AppColors.tertiaryLight,
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                _buildAppBar(context),

                // Progress Card
                progressAsync.when(
                  data: (progress) {
                    if (progress == null) {
                      return _buildNoProgressCard(context);
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: XPProgressBar(
                        progress: progress,
                        showDetails: true,
                        onTap: () => _showLevelUpDialog(context, progress),
                      ),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Error: $err'),
                  ),
                ),

                const SizedBox(height: 20),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPeach.withAlpha(20),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    dividerColor: Colors.transparent,
                    padding: const EdgeInsets.all(4),
                    onTap: (_) => HapticService().selectionClick(),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.emoji_events_rounded, size: 20),
                        text: 'Badges',
                      ),
                      Tab(
                        icon: Icon(Icons.local_fire_department, size: 20),
                        text: 'Streaks',
                      ),
                      Tab(
                        icon: Icon(Icons.leaderboard_rounded, size: 20),
                        text: 'Challenges',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBadgesTab(userId),
                      _buildStreaksTab(userId),
                      _buildChallengesTab(userId),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Confetti Overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              shouldLoop: false,
              colors: [
                AppTheme.primaryPeach,
                AppTheme.mintSoft,
                AppTheme.lilacSoft,
                AppColors.successColor,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticService().lightImpact();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Achievements',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                ),
                Text(
                  'Track your progress & rewards',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPeach.withAlpha(30),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppTheme.primaryPeach,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProgressCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPeach.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.rocket_launch_rounded,
            size: 64,
            color: AppTheme.primaryPeach,
          ),
          const SizedBox(height: 16),
          Text(
            'Start Your Journey!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete tasks to earn XP, unlock badges, and level up!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesTab(String userId) {
    return ref.watch(recentBadgeUnlocksProvider(userId)).when(
          data: (unlocks) {
            final allBadges = PredefinedBadges.allBadges;
            final unlockedIds = unlocks.map((u) => u['badgeId'] as String).toSet();

            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: allBadges.length,
              itemBuilder: (context, index) {
                final badge = allBadges[index];
                final isUnlocked = unlockedIds.contains(badge.id);
                return _buildBadgeCard(badge, isUnlocked);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        );
  }

  Widget _buildBadgeCard(Badge badge, bool isUnlocked) {
    return GestureDetector(
      onTap: () {
        HapticService().lightImpact();
        _showBadgeDetail(badge, isUnlocked);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked
                ? _getRarityColor(badge.rarity)
                : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: _getRarityColor(badge.rarity).withAlpha(30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Rarity Indicator
            if (isUnlocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRarityColor(badge.rarity),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge.rarity.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? _getRarityColor(badge.rarity).withAlpha(25)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconData(badge.iconName),
                      size: 40,
                      color: isUnlocked
                          ? _getRarityColor(badge.rarity)
                          : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Badge Name
                  Text(
                    badge.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isUnlocked ? AppColors.textDark : Colors.grey.shade400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // XP Reward
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? AppTheme.primaryPeach.withAlpha(25)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt,
                          size: 12,
                          color: isUnlocked ? AppTheme.primaryPeach : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${badge.xpReward}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isUnlocked ? AppTheme.primaryPeach : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Locked Overlay
                  if (!isUnlocked)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreaksTab(String userId) {
    return ref.watch(userProgressProvider(userId)).when(
          data: (progress) {
            if (progress == null) {
              return const Center(child: Text('No streak data yet'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Main Streak Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.warningColor,
                          AppColors.warningColor.withAlpha(200),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warningColor.withAlpha(40),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${progress.currentStreak}',
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          progress.currentStreak == 1 ? 'Day Streak' : 'Days Streak',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStreakStat(
                                icon: Icons.emoji_events_rounded,
                                label: 'Best Streak',
                                value: '${progress.longestStreak}',
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withAlpha(50),
                              ),
                              _buildStreakStat(
                                icon: Icons.check_circle_rounded,
                                label: 'Total Tasks',
                                value: '${progress.totalTasksCompleted}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Streak Milestones
                  _buildStreakMilestones(progress.currentStreak),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        );
  }

  Widget _buildStreakStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withAlpha(200),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakMilestones(int currentStreak) {
    final milestones = [
      (days: 3, title: 'Early Bird', icon: Icons.wb_sunny_rounded),
      (days: 7, title: 'Week Warrior', icon: Icons.calendar_today_rounded),
      (days: 30, title: 'Month Master', icon: Icons.star_rounded),
      (days: 100, title: 'Century Legend', icon: Icons.military_tech_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestone Progress',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        ...milestones.map((milestone) {
          final isAchieved = currentStreak >= milestone.days;
          final progress = (currentStreak / milestone.days).clamp(0.0, 1.0);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isAchieved ? AppColors.successColor : Colors.grey.shade200,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAchieved
                        ? AppColors.successColor.withAlpha(25)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    milestone.icon,
                    color: isAchieved ? AppColors.successColor : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isAchieved ? AppColors.textDark : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${milestone.days} days',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(
                            isAchieved ? AppColors.successColor : AppTheme.primaryPeach,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAchieved)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.successColor,
                    size: 28,
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildChallengesTab(String userId) {
    return ref.watch(activeChallengesProvider).when(
          data: (challenges) {
            if (challenges.isEmpty) {
              return _buildNoChallengesView();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                return _buildChallengeCard(challenges[index], userId);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        );
  }

  Widget _buildNoChallengesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/trophy.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text(
            'No Active Challenges',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon for new challenges!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(WeeklyChallenge challenge, String userId) {
    final isParticipating = challenge.participantIds.contains(userId);
    final userScore = challenge.leaderboard[userId] ?? 0;
    final daysLeft = challenge.endDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPeach.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.secondaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$daysLeft days',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  challenge.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(230),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rewards
                Row(
                  children: [
                    _buildRewardChip(
                      icon: Icons.bolt,
                      label: '+${challenge.xpReward} XP',
                      color: AppTheme.primaryPeach,
                    ),
                    if (challenge.badgeReward != null) ...[
                      const SizedBox(width: 8),
                      _buildRewardChip(
                        icon: Icons.emoji_events,
                        label: 'Badge',
                        color: AppColors.successColor,
                      ),
                    ],
                  ],
                ),

                if (isParticipating) ...[
                  const SizedBox(height: 16),
                  // User Score
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPeach.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Score',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          '$userScore points',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryPeach,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // View Leaderboard Button
                  TextButton(
                    onPressed: () {
                      HapticService().lightImpact();
                      _showLeaderboard(challenge);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.leaderboard_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('View Leaderboard'),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  // Join Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticService().mediumImpact();
                        _joinChallenge(challenge.id, userId);
                      },
                      child: const Text('Join Challenge'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Color _getRarityColor(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.common:
        return Colors.grey;
      case BadgeRarity.rare:
        return AppColors.infoColor;
      case BadgeRarity.epic:
        return AppTheme.lilacSoft;
      case BadgeRarity.legendary:
        return AppColors.warningColor;
    }
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'emoji_events': Icons.emoji_events_rounded,
      'stars': Icons.stars_rounded,
      'workspace_premium': Icons.workspace_premium_rounded,
      'military_tech': Icons.military_tech_rounded,
      'task_alt': Icons.task_alt_rounded,
      'verified': Icons.verified_rounded,
      'check_circle': Icons.check_circle_rounded,
      'wb_sunny': Icons.wb_sunny_rounded,
      'psychology': Icons.psychology_rounded,
      'favorite': Icons.favorite_rounded,
    };
    return iconMap[iconName] ?? Icons.emoji_events_rounded;
  }

  void _showBadgeDetail(Badge badge, bool isUnlocked) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getRarityColor(badge.rarity).withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(badge.iconName),
                size: 64,
                color: _getRarityColor(badge.rarity),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (!isUnlocked)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.lock_rounded, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      'Complete the requirements to unlock',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLevelUpDialog(BuildContext context, UserProgress progress) {
    _confettiController.play();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/trophy.json',
              width: 120,
              height: 120,
              repeat: false,
            ),
            Text(
              'Level ${progress.level}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${progress.experiencePoints} Total XP',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaderboard(WeeklyChallenge challenge) {
    ref.read(challengeLeaderboardProvider(challenge.id)).whenData((leaderboard) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Leaderboard',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                // List
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: leaderboard.length,
                    itemBuilder: (context, index) {
                      final entry = leaderboard[index];
                      final rank = index + 1;
                      return _buildLeaderboardItem(rank, entry.key, entry.value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLeaderboardItem(int rank, String userId, int score) {
    Color rankColor;
    if (rank == 1) {
      rankColor = AppColors.warningColor;
    } else if (rank == 2) {
      rankColor = Colors.grey;
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
    } else {
      rankColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rank <= 3 ? rankColor.withAlpha(10) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank <= 3 ? rankColor.withAlpha(50) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rankColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: rankColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'User ${userId.substring(0, 8)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$score pts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: rankColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _joinChallenge(String challengeId, String userId) async {
    try {
      final service = ref.read(gamificationServiceProvider);
      await service.joinChallenge(userId, challengeId);
      ref.invalidate(activeChallengesProvider);
      HapticService().success();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined challenge!')),
        );
      }
    } catch (e) {
      HapticService().error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
