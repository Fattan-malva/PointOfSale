import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../report_provider.dart';

class DailySalesScreen extends ConsumerWidget {
  const DailySalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final salesAsync = ref.watch(salesReportProvider({'branchId': null, 'dateFrom': dateStr, 'dateTo': dateStr}));

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Sales')),
      body: salesAsync.when(
        data: (data) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(label: 'Total Sales', value: 'Rp ${_fmt((data['totalSales'] as num?)?.toDouble() ?? 0)}', icon: Icons.attach_money),
              const SizedBox(height: AppSpacing.space4),
              _SummaryCard(label: 'Total Orders', value: '${(data['totalOrders'] as num?)?.toInt() ?? 0}', icon: Icons.receipt_long),
              const SizedBox(height: AppSpacing.space4),
              _SummaryCard(label: 'Average Order', value: 'Rp ${_fmt((data['averageOrder'] as num?)?.toDouble() ?? 0)}', icon: Icons.trending_up),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _fmt(double a) => a.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _SummaryCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 40),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.caption),
                Text(value, style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
