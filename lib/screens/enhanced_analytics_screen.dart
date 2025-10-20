import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:daypilot/utils/modern_theme.dart';
import 'package:daypilot/models/task.dart';
import 'package:daypilot/providers/app_providers.dart';

class EnhancedAnalyticsScreen extends ConsumerStatefulWidget {
  const EnhancedAnalyticsScreen({super.key});

  @override
  ConsumerState<EnhancedAnalyticsScreen> createState() => _EnhancedAnalyticsScreenState();
}

class _EnhancedAnalyticsScreenState extends ConsumerState<EnhancedAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = ref.watch(tasksProvider);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: ModernTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(theme),
              _buildTabBar(theme),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(tasks, theme),
                    _buildTrendsTab(tasks, theme),
                    _buildInsightsTab(tasks, theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your productivity insights',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ModernTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: ModernTheme.primaryPurple,
        unselectedLabelColor: ModernTheme.textLight,
        indicatorColor: ModernTheme.primaryPurple,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Trends'),
          Tab(text: 'Insights'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(List<Task> tasks, ThemeData theme) {
    final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
    final completionRate = tasks.isEmpty ? 0.0 : completedTasks / tasks.length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Tasks', '${tasks.length}', Icons.task_alt, ModernTheme.primaryGradient)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Completed', '$completedTasks', Icons.check_circle, ModernTheme.successGradient)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Pending', '${tasks.length - completedTasks}', Icons.pending, ModernTheme.warningGradient)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Rate', '${(completionRate * 100).toInt()}%', Icons.trending_up, ModernTheme.accentGradient)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Completion Chart
          _buildSectionTitle('Weekly Completion', theme),
          const SizedBox(height: 16),
          _buildCompletionChart(tasks),
          
          const SizedBox(height: 24),
          
          // Time Distribution
          _buildSectionTitle('Time Distribution', theme),
          const SizedBox(height: 16),
          _buildTimeDistributionChart(tasks),
          
          const SizedBox(height: 24),
          
          // Priority Breakdown
          _buildSectionTitle('Priority Breakdown', theme),
          const SizedBox(height: 16),
          _buildPriorityChart(tasks),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(List<Task> tasks, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Productivity Trend', theme),
          const SizedBox(height: 16),
          _buildProductivityLineChart(),
          
          const SizedBox(height: 24),
          
          _buildSectionTitle('Daily Heatmap', theme),
          const SizedBox(height: 16),
          _buildHeatmapCalendar(),
          
          const SizedBox(height: 24),
          
          _buildSectionTitle('Streak Analysis', theme),
          const SizedBox(height: 16),
          _buildStreakCard(tasks),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(List<Task> tasks, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('AI Insights', theme),
          const SizedBox(height: 16),
          
          _buildInsightCard(
            '🔥 Strong Performance',
            'You\'ve completed 85% of tasks this week! Keep up the momentum.',
            ModernTheme.successGradient,
          ),
          
          const SizedBox(height: 12),
          
          _buildInsightCard(
            '⏰ Peak Productivity',
            'Your most productive hours are 9-11 AM. Schedule important tasks then.',
            ModernTheme.primaryGradient,
          ),
          
          const SizedBox(height: 12),
          
          _buildInsightCard(
            '📈 Improvement Area',
            'High-priority tasks take 20% longer. Consider breaking them into smaller steps.',
            ModernTheme.warningGradient,
          ),
          
          const SizedBox(height: 12),
          
          _buildInsightCard(
            '🎯 Consistency Tip',
            'You\'re most consistent on weekdays. Set reminders for weekend tasks.',
            ModernTheme.accentGradient,
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionTitle('Recommendations', theme),
          const SizedBox(height: 16),
          
          _buildRecommendationCard(
            'Morning Routine',
            'Start with 3 small wins to build momentum',
            Icons.wb_sunny,
          ),
          
          const SizedBox(height: 12),
          
          _buildRecommendationCard(
            'Focus Blocks',
            'Try 90-minute deep work sessions',
            Icons.timer,
          ),
          
          const SizedBox(height: 12),
          
          _buildRecommendationCard(
            'Weekly Review',
            'Review progress every Sunday evening',
            Icons.event_note,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, LinearGradient gradient) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionChart(List<Task> tasks) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 20,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  return Text(days[value.toInt() % 7], style: TextStyle(fontSize: 12));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (15 - index * 1.5 + (index % 3) * 2).clamp(5, 18),
                  gradient: ModernTheme.primaryGradient,
                  width: 20,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTimeDistributionChart(List<Task> tasks) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 50,
          sections: [
            PieChartSectionData(
              value: 35,
              title: '35%',
              color: ModernTheme.primaryPurple,
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: 30,
              title: '30%',
              color: ModernTheme.accentCyan,
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: 20,
              title: '20%',
              color: ModernTheme.successGreen,
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: 15,
              title: '15%',
              color: ModernTheme.warningOrange,
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChart(List<Task> tasks) {
    final workTasks = tasks.where((t) => t.category == TaskCategory.work).length;
    final healthTasks = tasks.where((t) => t.category == TaskCategory.health).length;
    final studyTasks = tasks.where((t) => t.category == TaskCategory.study).length;
    final personalTasks = tasks.where((t) => t.category == TaskCategory.personal).length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriorityBar('Work', workTasks, tasks.length, ModernTheme.primaryBlue),
          const SizedBox(height: 16),
          _buildPriorityBar('Health', healthTasks, tasks.length, ModernTheme.successGreen),
          const SizedBox(height: 16),
          _buildPriorityBar('Study', studyTasks, tasks.length, ModernTheme.primaryPurple),
          const SizedBox(height: 16),
          _buildPriorityBar('Personal', personalTasks, tasks.length, ModernTheme.warningOrange),
        ],
      ),
    );
  }

  Widget _buildPriorityBar(String label, int count, int total, Color color) {
    final percentage = total == 0 ? 0.0 : count / total;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('$count tasks', style: TextStyle(color: ModernTheme.textLight)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildProductivityLineChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
                  if (value.toInt() >= 0 && value.toInt() < weeks.length) {
                    return Text(weeks[value.toInt()], style: TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 3),
                const FlSpot(1, 4),
                const FlSpot(2, 3.5),
                const FlSpot(3, 5),
              ],
              isCurved: true,
              gradient: ModernTheme.primaryGradient,
              barWidth: 4,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    ModernTheme.primaryPurple.withOpacity(0.3),
                    ModernTheme.primaryBlue.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapCalendar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('Mon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Tue', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Wed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Thu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Fri', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Sat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Sun', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(4, (week) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (day) {
                  final intensity = (week * 7 + day) % 4;
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: ModernTheme.successGreen.withOpacity(0.2 + intensity * 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStreakCard(List<Task> tasks) {
    final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: ModernTheme.warningGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ModernTheme.warningOrange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$completedTasks Day Streak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep it going! You\'re on fire 🔥',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String description, LinearGradient gradient) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: ModernTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: ModernTheme.textLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
