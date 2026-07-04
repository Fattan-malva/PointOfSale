import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.accent,
              child: Text(
                (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                style: AppTypography.h1.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(user?.name ?? 'User', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.space2),
            Text(user?.email ?? '', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.space8),
            Card(
              child: Column(
                children: [
                  _ProfileTile(icon: Icons.badge, label: 'Role', value: user?.role ?? '-'),
                  const Divider(height: 1),
                  _ProfileTile(icon: Icons.business, label: 'Branch ID', value: user?.branchId ?? '-'),
                  const Divider(height: 1),
                  _ProfileTile(icon: Icons.person, label: 'User ID', value: user?.id ?? '-'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ProfileTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(label),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
