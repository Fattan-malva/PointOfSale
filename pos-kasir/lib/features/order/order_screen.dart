import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/utils/currency_formatter.dart';
import '../order/order_provider.dart';

class OrderScreen extends ConsumerWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(currentOrderProvider);

    if (!orderState.hasOrder || orderState.order!.details.isEmpty) {
      return const EmptyView(
        icon: Icons.shopping_cart_outlined,
        title: 'Keranjang kosong',
        subtitle: 'Tambahkan menu dari daftar menu',
      );
    }

    final order = orderState.order!;

    return Column(
      children: [
        // Order type & table info
        Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          color: AppColors.surface,
          child: Row(
            children: [
              _InfoChip(icon: Icons.receipt_long, label: order.orderType),
              const SizedBox(width: AppSpacing.space2),
              if (order.tableId != null)
                _InfoChip(
                  icon: Icons.table_restaurant,
                  label: 'Meja ${order.tableId}',
                ),
              const Spacer(),
              Text(
                '${order.itemCount} item',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Order items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.space4),
            itemCount: order.details.length,
            itemBuilder: (context, index) {
              final detail = order.details[index];
              return _OrderItemCard(
                detail: detail,
                onIncrement: () {
                  ref
                      .read(currentOrderProvider.notifier)
                      .updateItemQty(detail.id, detail.qty + 1);
                },
                onDecrement: () {
                  ref
                      .read(currentOrderProvider.notifier)
                      .updateItemQty(detail.id, detail.qty - 1);
                },
                onRemove: () {
                  ref.read(currentOrderProvider.notifier).removeItem(detail.id);
                },
              );
            },
          ),
        ),

        // Order summary
        _OrderSummary(order: order),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accent),
          const SizedBox(width: AppSpacing.space1),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  final dynamic detail;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _OrderItemCard({
    required this.detail,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: Row(
        children: [
          // Item info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.itemName,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  CurrencyFormatter.format(detail.price),
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (detail.modifiers.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space1),
                  Wrap(
                    spacing: AppSpacing.space1,
                    children: detail.modifiers.map<Widget>((m) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space2,
                          vertical: AppSpacing.space1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Text(
                          m.optionName,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                if (detail.note != null && detail.note!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    'Catatan: ${detail.note}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Quantity controls
          Column(
            children: [
              // Remove button
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.error,
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: AppSpacing.space2),
              // Quantity controls
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: detail.qty > 1 ? onDecrement : onRemove,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space2,
                      ),
                      child: Text(
                        '${detail.qty}',
                        style: AppTypography.numeric.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: onIncrement,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              // Subtotal
              Text(
                CurrencyFormatter.format(detail.subtotal),
                style: AppTypography.numeric.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends ConsumerWidget {
  final dynamic order;

  const _OrderSummary({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        boxShadow: [AppShadows.md],
      ),
      child: Column(
        children: [
          // Subtotal
          _SummaryRow(
            label: 'Subtotal',
            value: CurrencyFormatter.format(order.subtotal),
          ),
          if (order.taxAmount > 0) ...[
            const SizedBox(height: AppSpacing.space2),
            _SummaryRow(
              label: 'Pajak',
              value: CurrencyFormatter.format(order.taxAmount),
            ),
          ],
          if (order.discountAmount > 0) ...[
            const SizedBox(height: AppSpacing.space2),
            _SummaryRow(
              label: 'Diskon',
              value: '-${CurrencyFormatter.format(order.discountAmount)}',
              valueColor: AppColors.success,
            ),
          ],
          const Divider(height: AppSpacing.space4),
          // Total
          _SummaryRow(
            label: 'Total',
            value: CurrencyFormatter.format(order.totalAmount),
            isBold: true,
          ),
          const SizedBox(height: AppSpacing.space4),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Batal',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    _showCancelDialog(context, ref);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: AppButton(
                  label: 'Bayar',
                  onPressed: () {
                    // TODO: Navigate to payment
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: const Text('Semua item akan dihapus dari keranjang'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              ref.read(currentOrderProvider.notifier).cancelOrder();
              Navigator.pop(context);
            },
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isBold ? AppTypography.bodyLg : AppTypography.body).copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: (isBold ? AppTypography.title : AppTypography.numeric)
              .copyWith(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}
