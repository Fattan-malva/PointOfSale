import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/utils/currency_formatter.dart';
import '../order/order_provider.dart';
import '../payment/payment_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String? _selectedPaymentMethodId;
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(currentOrderProvider);
    final paymentMethodsAsync = ref.watch(paymentMethodsProvider);
    final paymentState = ref.watch(paymentProvider);

    if (!orderState.hasOrder) {
      return const Scaffold(
        body: Center(child: Text('Tidak ada pesanan aktif')),
      );
    }

    final order = orderState.order!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Pembayaran'), elevation: 0),
      body: LoadingOverlay(
        isLoading: paymentState.isLoading,
        message: 'Memproses pembayaran...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ringkasan Pesanan', style: AppTypography.title),
                    const SizedBox(height: AppSpacing.space3),
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
                        value:
                            '-${CurrencyFormatter.format(order.discountAmount)}',
                        valueColor: AppColors.success,
                      ),
                    ],
                    const Divider(height: AppSpacing.space4),
                    _SummaryRow(
                      label: 'Total',
                      value: CurrencyFormatter.format(order.totalAmount),
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space6),

              // Payment method selection
              Text('Metode Pembayaran', style: AppTypography.title),
              const SizedBox(height: AppSpacing.space3),
              paymentMethodsAsync.when(
                data: (methods) => Wrap(
                  spacing: AppSpacing.space2,
                  runSpacing: AppSpacing.space2,
                  children: methods.map((method) {
                    final isSelected = _selectedPaymentMethodId == method.id;
                    return ChoiceChip(
                      label: Text(method.methodName),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedPaymentMethodId = method.id;
                        });
                      },
                      selectedColor: AppColors.accentSoft,
                      labelStyle: AppTypography.body.copyWith(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    );
                  }).toList(),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: AppSpacing.space6),

              // Amount input
              Text('Jumlah Bayar', style: AppTypography.title),
              const SizedBox(height: AppSpacing.space3),
              AppTextField(
                controller: _amountController,
                hintText: CurrencyFormatter.format(order.totalAmount),
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
              ),
              const SizedBox(height: AppSpacing.space3),

              // Quick amount buttons
              Wrap(
                spacing: AppSpacing.space2,
                runSpacing: AppSpacing.space2,
                children: [
                  _QuickAmountButton(
                    label: 'Tepat',
                    amount: order.totalAmount,
                    onTap: (amount) {
                      _amountController.text = amount.toStringAsFixed(0);
                    },
                  ),
                  _QuickAmountButton(
                    label: '+50K',
                    amount: order.totalAmount + 50000,
                    onTap: (amount) {
                      _amountController.text = amount.toStringAsFixed(0);
                    },
                  ),
                  _QuickAmountButton(
                    label: '+100K',
                    amount: order.totalAmount + 100000,
                    onTap: (amount) {
                      _amountController.text = amount.toStringAsFixed(0);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space6),

              // Reference number (for non-cash)
              if (_selectedPaymentMethodId != null) ...[
                Text('Nomor Referensi (opsional)', style: AppTypography.title),
                const SizedBox(height: AppSpacing.space3),
                AppTextField(
                  controller: _referenceController,
                  hintText: 'Masukkan nomor referensi',
                  prefixIcon: Icons.confirmation_number,
                ),
                const SizedBox(height: AppSpacing.space6),
              ],

              // Pay button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Bayar ${CurrencyFormatter.format(order.totalAmount)}',
                  onPressed: _selectedPaymentMethodId == null
                      ? null
                      : () => _processPayment(context, ref, order.totalAmount),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processPayment(
    BuildContext context,
    WidgetRef ref,
    double totalAmount,
  ) async {
    final orderState = ref.read(currentOrderProvider);
    if (orderState.order == null) return;

    final amount = double.tryParse(_amountController.text) ?? totalAmount;
    if (amount < totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah bayar kurang dari total'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await ref
        .read(paymentProvider.notifier)
        .processPayment(
          orderState.order!.id,
          paymentMethodId: _selectedPaymentMethodId!,
          paymentAmount: amount,
          referenceNumber: _referenceController.text.isNotEmpty
              ? _referenceController.text
              : null,
        );

    final paymentState = ref.read(paymentProvider);
    if (paymentState.success && context.mounted) {
      // Complete the order
      await ref.read(currentOrderProvider.notifier).confirmOrder();

      // Show success and navigate back
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 64,
          ),
          title: const Text('Pembayaran Berhasil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kembalian: ${CurrencyFormatter.format(amount - totalAmount)}',
              ),
            ],
          ),
          actions: [
            AppButton(
              label: 'Selesai',
              onPressed: () {
                ref.read(currentOrderProvider.notifier).clearOrder();
                ref.read(paymentProvider.notifier).reset();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      );
    } else if (paymentState.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentState.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
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

class _QuickAmountButton extends StatelessWidget {
  final String label;
  final double amount;
  final Function(double) onTap;

  const _QuickAmountButton({
    required this.label,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () => onTap(amount),
      backgroundColor: AppColors.surface,
      labelStyle: AppTypography.body.copyWith(color: AppColors.textPrimary),
    );
  }
}
