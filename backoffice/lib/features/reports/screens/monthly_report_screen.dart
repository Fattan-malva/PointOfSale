import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../report_provider.dart';

class MonthlyReportScreen extends ConsumerWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final firstDay = DateTime(today.year, today.month, 1);
    final dateFrom = '${firstDay.year}-${firstDay.month.toString().padLeft(2, '0')}-01';
    final dateTo = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final salesAsync = ref.watch(salesReportProvider({'branchId': null, 'dateFrom': dateFrom, 'dateTo': dateTo}));

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Report')),
      body: salesAsync.when(
        data: (data) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_monthName(today.month)} ${today.year}', style: AppTypography.h2),
              const SizedBox(height: AppSpacing.space6),
              _SummaryCard(label: 'Total Revenue', value: 'Rp ${_fmt((data['totalSales'] as num?)?.toDouble() ?? 0)}', icon: Icons.attach_money),
              const SizedBox(height: AppSpacing.space4),
              _SummaryCard(label: 'Total Orders', value: '${(data['totalOrders'] as num?)?.toInt() ?? 0}', icon: Icons.receipt_long),
              const SizedBox(height: AppSpacing.space4),
              Row(
                children: [
                  Expanded(child: _MiniCard(label: 'Avg Order', value: 'Rp ${_fmt((data['averageOrder'] as num?)?.toDouble() ?? 0)}')),
                  const SizedBox(width: 12),
                  Expanded(child: _MiniCard(label: 'Days', value: '${today.day}')),
                ],
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _fmt(double a) => a.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  String _monthName(int m) => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
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
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: AppTypography.caption),
              Text(value, style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String label, value;
  const _MiniCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.caption),
            const SizedBox(height: 4),
            Text(value, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
