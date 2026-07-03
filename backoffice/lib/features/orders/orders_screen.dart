import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Orders', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.space4),
            // Filters
            Row(
              children: [
                _FilterChip('All'),
                const SizedBox(width: 8),
                _FilterChip('Pending'),
                const SizedBox(width: 8),
                _FilterChip('Confirmed'),
                const SizedBox(width: 8),
                _FilterChip('Completed'),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (_, i) {
                  final statuses = ['pending', 'confirmed', 'completed', 'cancelled'];
                  final status = statuses[i % 4];
                  final statusColors = {
                    'pending': AppColors.warning,
                    'confirmed': AppColors.info,
                    'completed': AppColors.success,
                    'cancelled': AppColors.error,
                  };
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.space2),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.accentSoft,
                        child: const Icon(Icons.receipt, color: AppColors.accent),
                      ),
                      title: Text('Order #${2026000 + i}'),
                      subtitle: Text('Table M${(i % 10) + 1} • ${statuses[i % 4]}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColors[status]!.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(color: statusColors[status], fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.space4),
                          child: Column(
                            children: [
                              ListTile(
                                title: const Text('Item 1'),
                                trailing: Text('Rp ${(i + 1) * 25000}'),
                              ),
                              ListTile(
                                title: const Text('Item 2'),
                                trailing: Text('Rp ${(i + 2) * 15000}'),
                              ),
                              const Divider(),
                              ListTile(
                                title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                                trailing: Text('Rp ${((i + 1) * 25000) + ((i + 2) * 15000)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {},
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {},
                                    child: const Text('Process'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  const _FilterChip(this.label);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: label == 'All',
      onSelected: (v) {},
    );
  }
}
