import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_text_field.dart';
import 'discount_provider.dart';

class DiscountScreen extends ConsumerStatefulWidget {
  const DiscountScreen({super.key});

  @override
  ConsumerState<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends ConsumerState<DiscountScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discountProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Discounts', style: AppTypography.h2),
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
                hintText: 'Search discounts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: (v) => ref.read(discountProvider.notifier).setSearch(v),
            ),
            const SizedBox(height: AppSpacing.space4),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.discounts.isEmpty
                      ? Center(child: Text(state.error ?? 'No discounts found',
                          style: AppTypography.body.copyWith(color: AppColors.textSecondary)))
                      : ListView.builder(
                          itemCount: state.discounts.length,
                          itemBuilder: (_, i) {
                            final d = state.discounts[i];
                            final isActive = d.isActive &&
                                (d.endDate == null || d.endDate!.isAfter(DateTime.now()));
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.infoSoft,
                                  child: const Icon(Icons.local_offer, color: AppColors.info, size: 20),
                                ),
                                title: Text(d.name),
                                subtitle: Text(
                                  '${d.discountType == 'Percentage' ? '${d.discountValue}%' : 'Rp ${_fmt(d.discountValue)}'}'
                                  '${d.minPurchase != null ? ' • Min: Rp ${_fmt(d.minPurchase!)}' : ''}'
                                  '${d.endDate != null ? ' • Until: ${_date(d.endDate!)}' : ''}',
                                  style: AppTypography.caption,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isActive ? AppColors.success.withAlpha(25) : AppColors.error.withAlpha(25),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(fontSize: 12, color: isActive ? AppColors.success : AppColors.error),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 20),
                                      onPressed: () => _showEditDialog(context, d),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                      onPressed: () => _confirmDelete(context, d.id, d.name),
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
    final nameCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final minPurchaseCtrl = TextEditingController();
    final maxDiscountCtrl = TextEditingController();
    String discountType = 'Percentage';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Discount'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(controller: nameCtrl, label: 'Discount Name'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: discountType,
                  decoration: const InputDecoration(labelText: 'Discount Type', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Percentage', child: Text('Percentage (%)')),
                    DropdownMenuItem(value: 'Nominal', child: Text('Nominal (Rp)')),
                  ],
                  onChanged: (v) => setDialogState(() => discountType = v!),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: valueCtrl,
                  label: discountType == 'Percentage' ? 'Discount Value (%)' : 'Discount Value (Rp)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                AppTextField(controller: minPurchaseCtrl, label: 'Min Purchase (optional)', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                AppTextField(controller: maxDiscountCtrl, label: 'Max Discount (optional)', keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || valueCtrl.text.isEmpty) return;
                final data = <String, dynamic>{
                  'DiscountName': nameCtrl.text,
                  'DiscountType': discountType,
                  'DiscountValue': double.tryParse(valueCtrl.text) ?? 0,
                };
                if (minPurchaseCtrl.text.isNotEmpty) data['MinPurchase'] = double.tryParse(minPurchaseCtrl.text);
                if (maxDiscountCtrl.text.isNotEmpty) data['MaxDiscount'] = double.tryParse(maxDiscountCtrl.text);
                await ref.read(discountProvider.notifier).createDiscount(data);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic d) {
    final nameCtrl = TextEditingController(text: d.name);
    final valueCtrl = TextEditingController(text: d.discountValue.toString());
    final minPurchaseCtrl = TextEditingController(text: d.minPurchase?.toString() ?? '');
    final maxDiscountCtrl = TextEditingController(text: d.maxDiscount?.toString() ?? '');
    String discountType = d.discountType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Discount'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(controller: nameCtrl, label: 'Discount Name'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: discountType,
                  decoration: const InputDecoration(labelText: 'Discount Type', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Percentage', child: Text('Percentage (%)')),
                    DropdownMenuItem(value: 'Nominal', child: Text('Nominal (Rp)')),
                  ],
                  onChanged: (v) => setDialogState(() => discountType = v!),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: valueCtrl,
                  label: discountType == 'Percentage' ? 'Discount Value (%)' : 'Discount Value (Rp)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                AppTextField(controller: minPurchaseCtrl, label: 'Min Purchase', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                AppTextField(controller: maxDiscountCtrl, label: 'Max Discount', keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || valueCtrl.text.isEmpty) return;
                final data = <String, dynamic>{
                  'DiscountName': nameCtrl.text,
                  'DiscountType': discountType,
                  'DiscountValue': double.tryParse(valueCtrl.text) ?? 0,
                };
                if (minPurchaseCtrl.text.isNotEmpty) data['MinPurchase'] = double.tryParse(minPurchaseCtrl.text);
                if (maxDiscountCtrl.text.isNotEmpty) data['MaxDiscount'] = double.tryParse(maxDiscountCtrl.text);
                await ref.read(discountProvider.notifier).updateDiscount(d.id, data);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Discount'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await ref.read(discountProvider.notifier).deleteDiscount(id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';
  String _fmt(double a) => a.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
