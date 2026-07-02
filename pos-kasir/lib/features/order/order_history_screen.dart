import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/utils/currency_formatter.dart';
import '../order/order_provider.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Riwayat Pesanan'), elevation: 0),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyView(
              icon: Icons.history,
              title: 'Belum ada riwayat',
              subtitle: 'Pesanan yang sudah selesai akan muncul di sini',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.space4),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderHistoryCard(order: order);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(orderHistoryProvider),
        ),
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final dynamic order;

  const _OrderHistoryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.id.substring(0, 8).toUpperCase()}',
                style: AppTypography.numeric.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              StatusBadge(label: order.status.toString(), status: AppBadgeStatus.info),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),

          // Order info
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.space1),
              Text(
                order.orderType,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.space4),
              Icon(
                Icons.shopping_bag,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.space1),
              Text(
                '${order.itemCount} item',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),

          // Date & total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
              Text(
                CurrencyFormatter.format(order.totalAmount),
                style: AppTypography.numeric.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),

          // Payment status
          if (order.paymentStatus == 'Paid') ...[
            const SizedBox(height: AppSpacing.space2),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppSpacing.space1),
                Text(
                  'Lunas',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
