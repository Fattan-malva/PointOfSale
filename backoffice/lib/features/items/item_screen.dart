import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/item_model.dart';
import 'item_provider.dart';
import 'item_modal.dart';

class ItemScreen extends ConsumerStatefulWidget {
  const ItemScreen({super.key});

  @override
  ConsumerState<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends ConsumerState<ItemScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late final AnimationController _animController;
  int _lastListHash = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemProvider);

    final listHash = Object.hashAll(state.items.map((i) => i.id));
    if (listHash != _lastListHash && state.items.isNotEmpty) {
      _lastListHash = listHash;
      _animController.reset();
      _animController.forward();
    }

    return Scaffold(
      backgroundColor: AppColors.warmBone,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(state),
            const SizedBox(height: 24),
            _buildSearch(),
            const SizedBox(height: 16),
            _buildCategoryFilter(state),
            const SizedBox(height: 20),
            Expanded(child: _buildList(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ItemState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.04,
                height: 1.1,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${state.items.length} item${state.items.length != 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF787774),
                height: 1.5,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showAddDialog(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEAEAEA)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 16, color: Color(0xFF111111)),
                SizedBox(width: 8),
                Text(
                  'Add Item',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEAEAEA)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: Color(0xFF111111)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search items...',
                hintStyle: TextStyle(fontSize: 14, color: AppColors.textDisabled),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
              onChanged: (v) => ref.read(itemProvider.notifier).setSearch(v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(ItemState state) {
    if (state.categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'All',
            selected: state.selectedCategoryId == null,
            onTap: () => ref.read(itemProvider.notifier).setCategoryFilter(null),
          ),
          ...state.categories.map((c) => _FilterChip(
            label: c.name,
            selected: state.selectedCategoryId == c.id,
            onTap: () => ref.read(itemProvider.notifier).setCategoryFilter(c.id),
          )),
        ],
      ),
    );
  }

  Widget _buildList(ItemState state) {
    if (state.isLoading) {
      return const Center(
        child: SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Text(
          state.error ?? 'No items found',
          style: const TextStyle(fontSize: 14, color: Color(0xFF787774)),
        ),
      );
    }

    return ListView.builder(
      itemCount: state.items.length,
      itemBuilder: (_, i) {
        final item = state.items[i];
        return _AnimatedEntry(
          controller: _animController,
          index: i,
          child: _buildItemCard(item),
        );
      },
    );
  }

  Widget _buildItemCard(ItemModel item) {
    final (pastelBg, pastelFg) = _pastelFor(item.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEAEAEA)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: pastelBg,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                item.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: pastelFg,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111111),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.isActive
                              ? AppColors.pastelGreen
                              : AppColors.pastelRed,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.05,
                            color: item.isActive
                                ? AppColors.pastelGreenText
                                : AppColors.pastelRedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildSubtitle(item),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF787774),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.taxes.isNotEmpty || item.discounts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          if (item.taxes.isNotEmpty) ...[
                            _Tag(label: 'Tax', count: item.taxes.length),
                            const SizedBox(width: 6),
                          ],
                          if (item.discounts.isNotEmpty)
                            _Tag(label: 'Disc', count: item.discounts.length),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _IconAction(
              icon: Icons.edit_rounded,
              onTap: () => _showEditDialog(item),
            ),
            const SizedBox(width: 8),
            _IconAction(
              icon: Icons.delete_outline_rounded,
              iconColor: AppColors.pastelRedText,
              onTap: () => _confirmDelete(item.id, item.name),
            ),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle(ItemModel item) {
    final parts = <String>['Rp ${_fmt(item.price)}'];
    if (item.itemCode.isNotEmpty) parts.insert(0, item.itemCode);
    if (item.categoryName != null && item.categoryName!.isNotEmpty) {
      parts.add(item.categoryName!);
    }
    if (item.costPrice != null) {
      parts.add('Cost: Rp ${_fmt(item.costPrice!)}');
    }
    return parts.join(' • ');
  }

  (Color, Color) _pastelFor(String name) {
    final hash = name.hashCode.abs();
    final palettes = [
      (AppColors.pastelBlue, AppColors.pastelBlueText),
      (AppColors.pastelRed, AppColors.pastelRedText),
      (AppColors.pastelGreen, AppColors.pastelGreenText),
      (AppColors.pastelYellow, AppColors.pastelYellowText),
    ];
    return palettes[hash % palettes.length];
  }

  void _showAddDialog() async {
    final state = ref.read(itemProvider);
    final result = await ItemModal.create(
      context,
      categories: state.categories,
      allTaxes: state.allTaxes,
      allDiscounts: state.allDiscounts,
    );
    if (result == null || !context.mounted) return;

    final ok = await ref.read(itemProvider.notifier).createItem(
      {
        'ItemCode': result['ItemCode'],
        'ItemName': result['ItemName'],
        'Price': result['Price'],
        'ItemType': 'Product',
        if (result['CostPrice'] != null) 'CostPrice': result['CostPrice'],
        if (result['Description']?.isNotEmpty == true) 'Description': result['Description'],
        if (result['CategoryID'] != null) 'CategoryID': result['CategoryID'],
      },
      taxIds: (result['taxIds'] as List<String>?) ?? [],
      discountIds: (result['discountIds'] as List<String>?) ?? [],
    );
    if (context.mounted) _snack(ok ? 'Item created' : 'Failed to create item', ok: ok);
  }

  void _showEditDialog(ItemModel item) async {
    final state = ref.read(itemProvider);
    final result = await ItemModal.edit(
      context,
      item,
      categories: state.categories,
      allTaxes: state.allTaxes,
      allDiscounts: state.allDiscounts,
    );
    if (result == null || !context.mounted) return;

    final ok = await ref.read(itemProvider.notifier).updateItem(
      item.id,
      {
        'ItemCode': result['ItemCode'],
        'ItemName': result['ItemName'],
        'Price': result['Price'],
        if (result['CostPrice'] != null) 'CostPrice': result['CostPrice'],
        if (result['Description']?.isNotEmpty == true) 'Description': result['Description'],
        if (result['CategoryID'] != null) 'CategoryID': result['CategoryID'],
      },
      taxIds: (result['taxIds'] as List<String>?) ?? [],
      discountIds: (result['discountIds'] as List<String>?) ?? [],
    );
    if (context.mounted) _snack(ok ? 'Item updated' : 'Failed to update item', ok: ok);
  }

  void _confirmDelete(String id, String name) async {
    final confirmed = await ItemModal.confirmDelete(context, name);
    if (!confirmed || !context.mounted) return;

    final ok = await ref.read(itemProvider.notifier).deleteItem(id);
    if (context.mounted) _snack(ok ? 'Item deleted' : 'Failed to delete item', ok: ok);
  }

  void _snack(String message, {required bool ok}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: ok ? AppColors.pastelGreenText : AppColors.pastelRedText,
        )),
        backgroundColor: ok ? AppColors.pastelGreen : AppColors.pastelRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: Color(0xFFEAEAEA)),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _fmt(double a) => a.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

class _AnimatedEntry extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;

  const _AnimatedEntry({required this.controller, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final double start = (index * 0.06).clamp(0.0, 0.6);
    final double end = (start + 0.2).clamp(0.0, 1.0);
    const curve = Cubic(0.16, 1.0, 0.3, 1.0);

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Interval(start, end, curve: curve)),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(parent: controller, curve: Interval(start, end, curve: curve)),
        ),
        child: child,
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    this.iconColor = const Color(0xFF5C5C63),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEAEAEA)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF111111) : Colors.white,
            border: Border.all(color: selected ? const Color(0xFF111111) : const Color(0xFFEAEAEA)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : const Color(0xFF5C5C63),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final int count;

  const _Tag({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warmBone,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label +$count',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Color(0xFF787774),
        ),
      ),
    );
  }
}
