import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daypilot/utils/theme.dart';
import 'package:daypilot/providers/user_profile_provider.dart';
import 'package:daypilot/widgets/user_profile_menu.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);
    
    return Drawer(
            child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryPeach.withOpacity(0.08),
              AppTheme.lilacSoft.withOpacity(0.06),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Use the same UserProfileMenu control inside the drawer header so profile actions
                    // are bound to the left sidebar instead of the top-right header.
                    userProfileAsync.when(
                      data: (profile) => Column(
                        children: [
                          // Small padding around the profile menu so it looks like an avatar in header
                          const Align(
                            alignment: Alignment.center,
                            child: UserProfileMenu(),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            profile?.username ?? 'User',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            profile?.email ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      loading: () => Column(
                        children: [
                          // Show a loading avatar
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey[300],
                                child: const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Loading...',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      error: (_, __) => Column(
                        children: [
                          const Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: AppTheme.primaryPeach,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'User',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Streak Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.accentBeige,
                            Colors.orange,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '7 Day Streak!',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.home,
                      title: 'Dashboard',
                      subtitle: 'Today\'s overview',
                      route: '/',
                      color: AppTheme.primaryPeach,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.calendar_today,
                      title: 'Routines',
                      subtitle: 'Daily schedules',
                      route: '/routines',
                      color: AppTheme.lilacSoft,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.notifications_active,
                      title: 'Reminders',
                      subtitle: 'Notifications',
                      route: '/reminders',
                      color: AppTheme.accentBeige,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.psychology,
                      title: 'AI Insights',
                      subtitle: 'Smart suggestions',
                      route: '/ai',
                      color: AppTheme.mintSoft,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.analytics,
                      title: 'Analytics',
                      subtitle: 'Performance tracking',
                      route: '/analytics',
                      color: Colors.blue,
                    ),
                    
                    const Divider(),
                    
                    _buildMenuItem(
                      context,
                      icon: Icons.emoji_events,
                      title: 'Achievements',
                      subtitle: 'Your progress',
                      route: '/achievements',
                      color: Colors.amber,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.people,
                      title: 'Social',
                      subtitle: 'Team collaboration',
                      route: '/social',
                      color: Colors.pink,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.mic,
                      title: 'Voice Commands',
                      subtitle: 'Speak your tasks',
                      route: '/voice',
                      color: Colors.deepPurple,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings,
                      title: 'Settings',
                      subtitle: 'App preferences',
                      route: '/settings',
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              
              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          icon: Icons.check_circle,
                          value: '47',
                          label: 'Tasks',
                        ),
                        _buildStatItem(
                          context,
                          icon: Icons.schedule,
                          value: '3.5h',
                          label: 'Saved',
                        ),
                        _buildStatItem(
                          context,
                          icon: Icons.trending_up,
                          value: '92%',
                          label: 'Rate',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'DayPilot v1.0.0',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isCurrentRoute = ModalRoute.of(context)?.settings.name == route;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentRoute
            ? color.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: isCurrentRoute ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall,
        ),
        trailing: isCurrentRoute
            ? Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color,
              )
            : null,
        onTap: () {
          Navigator.pop(context);
          if (!isCurrentRoute) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryPeach,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
