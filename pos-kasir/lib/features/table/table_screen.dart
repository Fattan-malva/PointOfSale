import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/utils/responsive.dart';
import '../../models/table_model.dart';
import '../order/order_provider.dart';
import '../auth/auth_provider.dart';
import 'table_provider.dart';

class TableSelectionScreen extends ConsumerStatefulWidget {
  const TableSelectionScreen({super.key});

  @override
  ConsumerState<TableSelectionScreen> createState() => _TableSelectionScreenState();
}

class _TableSelectionScreenState extends ConsumerState<TableSelectionScreen> {
  String? _selectedTableId;
  String _orderType = 'DineIn';

  @override
  Widget build(BuildContext context) {
    final tablesAsync = ref.watch(tablesProvider);
    final orderState = ref.watch(currentOrderProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Pilih Meja'), elevation: 0),
      body: LoadingOverlay(
        isLoading: orderState.isLoading,
        child: Column(
          children: [
            // Order type selector
            Container(
              padding: const EdgeInsets.all(AppSpacing.space4),
              color: AppColors.surface,
              child: Row(
                children: [
                  _OrderTypeChip(
                    label: 'Dine In',
                    icon: Icons.restaurant,
                    isSelected: _orderType == 'DineIn',
                    onTap: () => setState(() => _orderType = 'DineIn'),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  _OrderTypeChip(
                    label: 'Take Away',
                    icon: Icons.shopping_bag,
                    isSelected: _orderType == 'TakeAway',
                    onTap: () => setState(() => _orderType = 'TakeAway'),
                  ),
                ],
              ),
            ),

            // Table grid
            Expanded(
              child: tablesAsync.when(
                data: (tables) {
                  final available = tables.where((t) => t.isAvailable).toList();
                  if (available.isEmpty) {
                    return const Center(child: Text('Tidak ada meja tersedia'));
                  }
                  return _TableGrid(
                    tables: available,
                    selectedTableId: _selectedTableId,
                    onTableTap: (table) {
                      setState(() => _selectedTableId = table.id);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),

            // Action button
            Container(
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))],
              ),
              child: SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: _orderType == 'DineIn'
                      ? (_selectedTableId != null ? 'Buat Pesanan' : 'Pilih Meja')
                      : 'Buat Pesanan',
                  onPressed: _orderType == 'DineIn' && _selectedTableId == null ? null : () => _createOrder(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createOrder(BuildContext context) async {
    final authState = ref.read(authStateProvider);
    if (authState.user == null) return;

    await ref.read(currentOrderProvider.notifier).createOrder(
      branchId: authState.user!.branchId!,
      userId: authState.user!.id,
      tableId: _selectedTableId,
      orderType: _orderType,
    );

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _OrderTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderTypeChip({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.space1),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.accentSoft,
      labelStyle: AppTypography.body.copyWith(
        color: isSelected ? AppColors.accent : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}

class _TableGrid extends StatelessWidget {
  final List<TableModel> tables;
  final String? selectedTableId;
  final Function(TableModel) onTableTap;

  const _TableGrid({required this.tables, this.selectedTableId, required this.onTableTap});

  @override
  Widget build(BuildContext context) {
    final breakpoint = AppBreakpoints.of(context);
    final crossAxisCount = breakpoint.isCompact ? 3 : 4;

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.space4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.space3,
        mainAxisSpacing: AppSpacing.space3,
        childAspectRatio: 1,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        final isSelected = table.id == selectedTableId;
        return AppCard(
          onTap: () => onTableTap(table),
          backgroundColor: isSelected ? AppColors.accentSoft : AppColors.surfaceRaised,
          border: isSelected ? Border.all(color: AppColors.accent, width: 2) : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.table_restaurant,
                size: 40,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                table.tableName,
                style: AppTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.accent : AppColors.textPrimary,
                ),
              ),
              Text(
                '${table.capacity} kursi',
                style: AppTypography.caption.copyWith(color: AppColors.textDisabled),
              ),
            ],
          ),
        );
      },
    );
  }
}
