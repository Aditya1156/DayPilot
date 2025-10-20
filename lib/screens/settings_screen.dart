import 'package:flutter/material.dart';
import 'package:daypilot/widgets/app_drawer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Appearance'),
          _SettingTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            trailing: Switch(
              value: false,
              onChanged: (value) {},
            ),
          ),
          _SettingTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),
          
          const Divider(),
          const _SectionHeader(title: 'Notifications'),
          _SettingTile(
            icon: Icons.notifications,
            title: 'Push Notifications',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
          _SettingTile(
            icon: Icons.schedule,
            title: 'Reminder Time',
            subtitle: '30 minutes before',
            onTap: () {},
          ),
          
          const Divider(),
          const _SectionHeader(title: 'Data & Privacy'),
          _SettingTile(
            icon: Icons.backup,
            title: 'Backup & Sync',
            subtitle: 'Last synced: Just now',
            onTap: () {},
          ),
          _SettingTile(
            icon: Icons.delete_sweep,
            title: 'Clear Cache',
            onTap: () {},
          ),
          
          const Divider(),
          const _SectionHeader(title: 'About'),
          const _SettingTile(
            icon: Icons.info,
            title: 'Version',
            subtitle: '1.0.0',
          ),
          _SettingTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _SettingTile(
            icon: Icons.description,
            title: 'Terms of Service',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
