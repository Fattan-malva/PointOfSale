import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../../models/item_model.dart';
import 'package_provider.dart';
import '../items/repositories/item_repository.dart';

class PackageScreen extends ConsumerStatefulWidget {
  const PackageScreen({super.key});

  @override
  ConsumerState<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends ConsumerState<PackageScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packageProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Packages', style: AppTypography.h2),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.accent),
                  onPressed: () => _showAddPackageDialog(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space6),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search packages...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: (v) => ref.read(packageProvider.notifier).setSearch(v),
            ),
            const SizedBox(height: AppSpacing.space4),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.packages.isEmpty
                      ? Center(child: Text(state.error ?? 'No packages found',
                          style: AppTypography.body.copyWith(color: AppColors.textSecondary)))
                      : Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ListView.builder(
                                itemCount: state.packages.length,
                                itemBuilder: (_, i) {
                                  final pkg = state.packages[i];
                                  return Card(
                                    color: state.selectedPackageId == pkg.id ? AppColors.accentSoft : null,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.accentSoft,
                                        child: const Icon(Icons.inventory_2, color: AppColors.accent, size: 20),
                                      ),
                                      title: Text(pkg.name),
                                      subtitle: Text('${pkg.itemCode} • Rp ${_fmt(pkg.price)}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 20),
                                            onPressed: () => _showEditPackageDialog(context, pkg),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                            onPressed: () => _confirmDeletePackage(context, pkg.id, pkg.name),
                                          ),
                                        ],
                                      ),
                                      onTap: () => ref.read(packageProvider.notifier).loadPackageDetails(pkg.id),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (state.selectedPackageId != null) ...[
                              const SizedBox(width: AppSpacing.space4),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Package Items', style: AppTypography.h3),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle, color: AppColors.accent, size: 22),
                                          onPressed: () => _showAddDetailDialog(context),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.space3),
                                    Expanded(
                                      child: state.isLoadingDetails
                                          ? const Center(child: CircularProgressIndicator())
                                          : state.packageDetails.isEmpty
                                              ? Center(child: Text('No items in this package',
                                                  style: AppTypography.body.copyWith(color: AppColors.textSecondary)))
                                              : ListView.builder(
                                                  itemCount: state.packageDetails.length,
                                                  itemBuilder: (_, i) {
                                                    final detail = state.packageDetails[i];
                                                    return Card(
                                                      child: ListTile(
                                                        title: Text(detail.itemName ?? detail.itemId),
                                                        subtitle: Text('Qty: ${detail.qty}'),
                                                        trailing: IconButton(
                                                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                                                          onPressed: () => _confirmDeleteDetail(context, state.selectedPackageId!, detail.id, detail.itemName ?? ''),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPackageDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Package'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: codeCtrl, label: 'Package Code'),
            const SizedBox(height: 12),
            AppTextField(controller: nameCtrl, label: 'Package Name'),
            const SizedBox(height: 12),
            AppTextField(controller: priceCtrl, label: 'Price', keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (codeCtrl.text.isEmpty || nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
              await ref.read(packageProvider.notifier).createPackage({
                'ItemCode': codeCtrl.text,
                'ItemName': nameCtrl.text,
                'Price': double.tryParse(priceCtrl.text) ?? 0,
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditPackageDialog(BuildContext context, dynamic pkg) {
    final codeCtrl = TextEditingController(text: pkg.itemCode);
    final nameCtrl = TextEditingController(text: pkg.name);
    final priceCtrl = TextEditingController(text: pkg.price.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Package'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: codeCtrl, label: 'Package Code'),
            const SizedBox(height: 12),
            AppTextField(controller: nameCtrl, label: 'Package Name'),
            const SizedBox(height: 12),
            AppTextField(controller: priceCtrl, label: 'Price', keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (codeCtrl.text.isEmpty || nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
              await ref.read(packageProvider.notifier).updatePackage(pkg.id, {
                'ItemCode': codeCtrl.text,
                'ItemName': nameCtrl.text,
                'Price': double.tryParse(priceCtrl.text) ?? 0,
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAddDetailDialog(BuildContext context) async {
    final qtyCtrl = TextEditingController(text: '1');
    final searchCtrl = TextEditingController();
    String? selectedItemId;
    final packageId = ref.read(packageProvider).selectedPackageId;

    List<ItemModel> items = ref.read(packageProvider).availableItems;
    if (items.isEmpty) {
      items = await ref.read(itemRepositoryProvider).getItems(itemType: 'Product');
    }
    List<ItemModel> filteredItems = List.from(items);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Item to Package'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  onChanged: (v) => setDialogState(() {
                    filteredItems = items.where((item) =>
                      item.name.toLowerCase().contains(v.toLowerCase()) ||
                      item.itemCode.toLowerCase().contains(v.toLowerCase())
                    ).toList();
                  }),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: filteredItems.isEmpty
                      ? Center(child: Text('No items found',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary)))
                      : ListView.builder(
                          itemCount: filteredItems.length,
                          itemBuilder: (_, i) {
                            final item = filteredItems[i];
                            final isSelected = selectedItemId == item.id;
                            return Card(
                              color: isSelected ? AppColors.accentSoft : null,
                              child: ListTile(
                                dense: true,
                                leading: Radio<String>(
                                  value: item.id,
                                  groupValue: selectedItemId,
                                  onChanged: (v) => setDialogState(() => selectedItemId = v),
                                ),
                                title: Text(item.name, style: const TextStyle(fontSize: 14)),
                                subtitle: Text('${item.itemCode} • Rp ${_fmt(item.price)}',
                                    style: AppTypography.caption),
                                onTap: () => setDialogState(() => selectedItemId = item.id),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                AppTextField(controller: qtyCtrl, label: 'Quantity', keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (packageId == null || selectedItemId == null || qtyCtrl.text.isEmpty) return;
                await ref.read(packageProvider.notifier).addDetail(
                  packageId,
                  selectedItemId!,
                  int.tryParse(qtyCtrl.text) ?? 1,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePackage(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Package'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await ref.read(packageProvider.notifier).deletePackage(id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDetail(BuildContext context, String packageId, String detailId, String itemName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove "$itemName" from this package?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await ref.read(packageProvider.notifier).removeDetail(packageId, detailId);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _fmt(double a) => a.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
