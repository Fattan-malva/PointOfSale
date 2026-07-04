import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preferences', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.space4),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Notifications'),
                    subtitle: const Text('Enable push notifications'),
                    value: _notificationsEnabled,
                    onChanged: (v) => setState(() => _notificationsEnabled = v),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Use dark theme'),
                    value: _darkMode,
                    onChanged: (v) => setState(() => _darkMode = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space6),
            Text('About', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.space4),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    title: Text('Version'),
                    trailing: Text('1.0.0'),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    title: Text('App Name'),
                    trailing: Text('BackOffice'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
