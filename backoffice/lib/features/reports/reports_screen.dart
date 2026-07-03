import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reports', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.space6),
            Expanded(
              child: ListView(
                children: [
                  _ReportCard(
                    icon: Icons.today,
                    title: 'Daily Sales',
                    subtitle: 'View today\'s sales report',
                    onTap: () {},
                  ),
                  _ReportCard(
                    icon: Icons.calendar_month,
                    title: 'Monthly Report',
                    subtitle: 'Monthly sales and performance',
                    onTap: () {},
                  ),
                  _ReportCard(
                    icon: Icons.inventory,
                    title: 'Inventory Summary',
                    subtitle: 'Current stock levels and alerts',
                    onTap: () {},
                  ),
                  _ReportCard(
                    icon: Icons.people,
                    title: 'Employee Performance',
                    subtitle: 'Staff activity and productivity',
                    onTap: () {},
                  ),
                  _ReportCard(
                    icon: Icons.trending_up,
                    title: 'Revenue Analytics',
                    subtitle: 'Revenue trends and comparisons',
                    onTap: () {},
                  ),
                  _ReportCard(
                    icon: Icons.pie_chart,
                    title: 'Category Analysis',
                    subtitle: 'Sales breakdown by category',
                    onTap: () {},
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

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.space3),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.accentSoft,
          child: Icon(icon, color: AppColors.accent),
        ),
        title: Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
