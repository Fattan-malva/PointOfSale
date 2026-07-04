import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import 'order_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _statuses = ['all', 'pending', 'confirmed', 'completed', 'cancelled'];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Orders', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.space4),
            Row(
              children: _statuses.map((s) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(s[0].toUpperCase() + s.substring(1)),
                  selected: state.selectedStatus == s,
                  onSelected: (_) => ref.read(orderProvider.notifier).setStatusFilter(s),
                ),
              )).toList(),
            ),
            const SizedBox(height: AppSpacing.space4),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.orders.isEmpty
                      ? Center(
                          child: Text(state.error ?? 'No orders found', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                        )
                      : ListView.builder(
                          itemCount: state.orders.length,
                          itemBuilder: (_, i) {
                            final order = state.orders[i];
                            final statusColors = {
                              'pending': AppColors.warning,
                              'confirmed': AppColors.info,
                              'completed': AppColors.success,
                              'cancelled': AppColors.error,
                            };
                            final color = statusColors[order.status] ?? AppColors.textSecondary;

                            return Card(
                              margin: const EdgeInsets.only(bottom: AppSpacing.space2),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.accentSoft,
                                  child: const Icon(Icons.receipt, color: AppColors.accent),
                                ),
                                title: Text(order.orderNumber ?? 'Order #${order.id}'),
                                subtitle: Text('${order.tableNumber != null ? '${order.tableNumber} • ' : ''}${order.status}'),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    order.status.toUpperCase(),
                                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(AppSpacing.space4),
                                    child: Column(
                                      children: [
                                        ...order.items.map((item) => ListTile(
                                          dense: true,
                                          title: Text(item.itemName ?? 'Item'),
                                          trailing: Text('Rp ${_fmt(item.subtotal)}'),
                                        )),
                                        if (order.items.isEmpty) ...[
                                          ListTile(
                                            dense: true,
                                            title: const Text('Item 1'),
                                            trailing: const Text('Rp 0'),
                                          ),
                                        ],
                                        const Divider(),
                                        ListTile(
                                          title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                                          trailing: Text('Rp ${_fmt(order.total)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        if (order.status == 'pending') ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              OutlinedButton(
                                                onPressed: () => ref.read(orderProvider.notifier).cancelOrder(order.id),
                                                child: const Text('Cancel'),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () => ref.read(orderProvider.notifier).confirmOrder(order.id),
                                                child: const Text('Confirm'),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (order.status == 'confirmed') ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () => ref.read(orderProvider.notifier).completeOrder(order.id),
                                                child: const Text('Complete'),
                                              ),
                                            ],
                                          ),
                                        ],
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

  String _fmt(double a) => a.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
