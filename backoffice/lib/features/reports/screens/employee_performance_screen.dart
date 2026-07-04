import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../report_provider.dart';

class EmployeePerformanceScreen extends ConsumerWidget {
  const EmployeePerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byCashierAsync = ref.watch(salesByCashierProvider({'branchId': null, 'dateFrom': null, 'dateTo': null}));

    return Scaffold(
      appBar: AppBar(title: const Text('Employee Performance')),
      body: byCashierAsync.when(
        data: (data) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sales by Cashier', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.space4),
              Expanded(
                child: ListView(
                  children: data.map((e) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.accentSoft,
                        child: Icon(Icons.person, color: AppColors.accent),
                      ),
                      title: Text(e['CashierName'] as String? ?? 'Unknown'),
                      subtitle: Text('${e['orderCount'] as num? ?? 0} orders'),
                      trailing: Text('Rp ${_fmt((e['total'] as num?)?.toDouble() ?? 0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )).toList(),
                ),
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
}
