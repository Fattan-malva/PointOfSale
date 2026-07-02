import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/responsive.dart';
import '../../models/item_model.dart';
import '../order/order_provider.dart';
import 'menu_provider.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final itemsAsync = ref.watch(filteredItemsProvider);
    final orderState = ref.watch(currentOrderProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(menuSearchQueryProvider);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
            child: AppTextField(
            label: 'Cari',
            controller: _searchController,
            hintText: 'Cari menu...',
            prefixIcon: Icons.search,
            onChanged: (value) {
              ref.read(menuSearchQueryProvider.notifier).state = value;
            },
          ),
        ),

        // Categories horizontal list
        categoriesAsync.when(
          data: (categories) => SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
              ),
              children: [
                // "All" chip
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.space2),
                  child: FilterChip(
                    label: Text('Semua'),
                    selected: selectedCategory == null,
                    onSelected: (_) {
                      ref.read(selectedCategoryProvider.notifier).state = null;
                    },
                    selectedColor: AppColors.accentSoft,
                    labelStyle: AppTypography.body.copyWith(
                      color: selectedCategory == null
                          ? AppColors.accent
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                // Category chips
                ...categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.space2),
                    child: FilterChip(
                      label: Text(cat.categoryName),
                      selected: selectedCategory == cat.id,
                      onSelected: (_) {
                        ref.read(selectedCategoryProvider.notifier).state =
                            selectedCategory == cat.id ? null : cat.id;
                      },
                      selectedColor: AppColors.accentSoft,
                      labelStyle: AppTypography.body.copyWith(
                        color: selectedCategory == cat.id
                            ? AppColors.accent
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          loading: () => const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => const SizedBox.shrink(),
        ),

        const SizedBox(height: AppSpacing.space3),

        // Items grid
        Expanded(
          child: itemsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const EmptyView(
                  icon: Icons.restaurant_menu,
                  title: 'Tidak ada menu',
                  subtitle: 'Menu belum tersedia',
                );
              }
              return _ItemsGrid(items: items);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(filteredItemsProvider),
            ),
          ),
        ),

        // Order summary bar
        if (orderState.hasOrder)
          _OrderSummaryBar(
            itemCount: orderState.itemCount,
            totalAmount: orderState.totalAmount,
          ),
      ],
    );
  }
}

class _ItemsGrid extends ConsumerWidget {
  final List<ItemModel> items;

  const _ItemsGrid({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakpoint = AppBreakpoints.of(context);

    int crossAxisCount;
    if (breakpoint.isCompact) {
      crossAxisCount = 2;
    } else if (breakpoint.isMedium) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.space3,
        mainAxisSpacing: AppSpacing.space3,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ItemCard(item: item);
      },
    );
  }
}

class _ItemCard extends ConsumerWidget {
  final ItemModel item;

  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      onTap: () => _addToOrder(context, ref),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image or placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.restaurant,
                          size: 48,
                          color: AppColors.textDisabled,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.restaurant,
                      size: 48,
                      color: AppColors.textDisabled,
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          // Name
          Text(
            item.itemName,
            style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.space1),
          // Price
          Text(
            CurrencyFormatter.format(item.price),
            style: AppTypography.numeric.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _addToOrder(BuildContext context, WidgetRef ref) async {
    final orderState = ref.read(currentOrderProvider);

    // If no order exists, create one first
    if (!orderState.hasOrder) {
      // TODO: Get branchId and userId from auth
      // For now, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buat pesanan terlebih dahulu'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    await ref.read(currentOrderProvider.notifier).addItem(item.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.itemName} ditambahkan'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}

class _OrderSummaryBar extends ConsumerWidget {
  final int itemCount;
  final double totalAmount;

  const _OrderSummaryBar({required this.itemCount, required this.totalAmount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        boxShadow: [AppShadows.md],
      ),
      child: Row(
        children: [
          // Item count
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space3,
              vertical: AppSpacing.space2,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Text(
              '$itemCount item',
              style: AppTypography.body.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          // Total
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(totalAmount),
                  style: AppTypography.title.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          // Pay button
          AppButton(
            label: 'Bayar',
            onPressed: () {
              // TODO: Navigate to payment screen
            },
          ),
        ],
      ),
    );
  }
}
