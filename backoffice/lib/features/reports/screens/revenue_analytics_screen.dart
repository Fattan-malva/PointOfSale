import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../report_provider.dart';

class RevenueAnalyticsScreen extends ConsumerWidget {
  const RevenueAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byPaymentAsync = ref.watch(salesByPaymentProvider({'branchId': null, 'dateFrom': null, 'dateTo': null}));
    final topItemsAsync = ref.watch(topItemsProvider({'branchId': null, 'dateFrom': null, 'dateTo': null}));

    return Scaffold(
      appBar: AppBar(title: const Text('Revenue Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenue by Payment', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.space3),
            byPaymentAsync.when(
              data: (data) => Column(
                children: data.map((e) => Card(
                  child: ListTile(
                    leading: Icon(Icons.payment, color: AppColors.accent),
                    title: Text(e['PaymentMethod'] as String? ?? 'Unknown'),
                    trailing: Text('Rp ${_fmt((e['total'] as num?)?.toDouble() ?? 0)}'),
                  ),
                )).toList(),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: AppSpacing.space6),
            Text('Top Items', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.space3),
            topItemsAsync.when(
              data: (data) => Column(
                children: data.take(10).toList().asMap().entries.map((e) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accentSoft,
                      child: Text('${e.key + 1}', style: const TextStyle(color: AppColors.accent)),
                    ),
                    title: Text(e.value['ItemName'] as String? ?? 'Item'),
                    trailing: Text('${e.value['quantity'] as num? ?? 0}x'),
                  ),
                )).toList(),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double a) => a.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
