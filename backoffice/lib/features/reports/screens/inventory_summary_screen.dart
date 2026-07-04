import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../report_provider.dart';

class InventorySummaryScreen extends ConsumerWidget {
  const InventorySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockAsync = ref.watch(stockReportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Summary')),
      body: stockAsync.when(
        data: (data) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(label: 'Total Items', value: '${(data['totalItems'] as num?)?.toInt() ?? 0}', icon: Icons.inventory),
              const SizedBox(height: AppSpacing.space4),
              _SummaryCard(label: 'Low Stock Items', value: '${(data['lowStockItems'] as num?)?.toInt() ?? 0}', icon: Icons.warning),
              const SizedBox(height: AppSpacing.space4),
              _SummaryCard(label: 'Out of Stock', value: '${(data['outOfStock'] as num?)?.toInt() ?? 0}', icon: Icons.error),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
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
