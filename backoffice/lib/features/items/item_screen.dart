import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../categories/category_provider.dart';
import 'item_provider.dart';

class ItemScreen extends ConsumerStatefulWidget {
  const ItemScreen({super.key});

  @override
  ConsumerState<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends ConsumerState<ItemScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Items', style: AppTypography.h2),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.accent),
                  onPressed: () => _showAddDialog(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space6),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: (v) => ref.read(itemProvider.notifier).setSearch(v),
            ),
            if (state.categories.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.space3),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _ChipBtn(
                      label: 'All',
                      selected: state.selectedCategoryId == null,
                      onTap: () => ref.read(itemProvider.notifier).setCategoryFilter(null),
                    ),
                    ...state.categories.map((c) => _ChipBtn(
                      label: c.name,
                      selected: state.selectedCategoryId == c.id,
                      onTap: () => ref.read(itemProvider.notifier).setCategoryFilter(c.id),
                    )),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.space4),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.items.isEmpty
                      ? Center(child: Text(state.error ?? 'No items found',
                          style: AppTypography.body.copyWith(color: AppColors.textSecondary)))
                      : ListView.builder(
                          itemCount: state.items.length,
                          itemBuilder: (_, i) {
                            final item = state.items[i];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.accentSoft,
                                  child: Text(item.name.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(color: AppColors.accent)),
                                ),
                                title: Text(item.name),
                                subtitle: Text(
                                  '${item.itemCode} • ${item.categoryName ?? ''} • Rp ${_fmt(item.price)}'
                                  '${item.costPrice != null ? ' (Cost: Rp ${_fmt(item.costPrice!)})' : ''}',
                                  style: AppTypography.caption,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: item.isActive
                                            ? AppColors.success.withAlpha(25)
                                            : AppColors.error.withAlpha(25),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(item.isActive ? 'Active' : 'Inactive',
                                          style: TextStyle(fontSize: 12,
                                              color: item.isActive ? AppColors.success : AppColors.error)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 20),
                                      onPressed: () => _showEditDialog(context, item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                      onPressed: () => _confirmDelete(context, item.id, item.name),
                                    ),
                                  ],
                                ),
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

  void _showAddDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    String? categoryId;
    final catState = ref.read(categoryProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: codeCtrl, label: 'Item Code'),
              const SizedBox(height: 12),
              AppTextField(controller: nameCtrl, label: 'Item Name'),
              const SizedBox(height: 12),
              AppTextField(controller: descCtrl, label: 'Description (optional)'),
              const SizedBox(height: 12),
              AppTextField(controller: priceCtrl, label: 'Price', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              AppTextField(controller: costCtrl, label: 'Cost Price (optional)', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: catState.categories
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => categoryId = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (codeCtrl.text.isEmpty || nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
              final data = <String, dynamic>{
                'ItemCode': codeCtrl.text,
                'ItemName': nameCtrl.text,
                'Price': double.tryParse(priceCtrl.text) ?? 0,
                'ItemType': 'Product',
              };
              if (descCtrl.text.isNotEmpty) data['Description'] = descCtrl.text;
              if (costCtrl.text.isNotEmpty) data['CostPrice'] = double.tryParse(costCtrl.text);
              if (categoryId != null) data['CategoryID'] = categoryId;
              await ref.read(itemProvider.notifier).createItem(data);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic item) {
    final codeCtrl = TextEditingController(text: item.itemCode);
    final nameCtrl = TextEditingController(text: item.name);
    final descCtrl = TextEditingController(text: item.description ?? '');
    final priceCtrl = TextEditingController(text: item.price.toString());
    final costCtrl = TextEditingController(text: item.costPrice?.toString() ?? '');
    String? categoryId = item.categoryId;
    final catState = ref.read(categoryProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: codeCtrl, label: 'Item Code'),
              const SizedBox(height: 12),
              AppTextField(controller: nameCtrl, label: 'Item Name'),
              const SizedBox(height: 12),
              AppTextField(controller: descCtrl, label: 'Description'),
              const SizedBox(height: 12),
              AppTextField(controller: priceCtrl, label: 'Price', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              AppTextField(controller: costCtrl, label: 'Cost Price', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: categoryId,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: catState.categories
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => categoryId = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (codeCtrl.text.isEmpty || nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
              final data = <String, dynamic>{
                'ItemCode': codeCtrl.text,
                'ItemName': nameCtrl.text,
                'Price': double.tryParse(priceCtrl.text) ?? 0,
              };
              if (descCtrl.text.isNotEmpty) data['Description'] = descCtrl.text;
              if (costCtrl.text.isNotEmpty) data['CostPrice'] = double.tryParse(costCtrl.text);
              if (categoryId != null) data['CategoryID'] = categoryId;
              await ref.read(itemProvider.notifier).updateItem(item.id, data);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await ref.read(itemProvider.notifier).deleteItem(id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _fmt(double a) => a.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

class _ChipBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChipBtn({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
    );
  }
}
