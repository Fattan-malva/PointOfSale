import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_text_field.dart';
import 'tax_provider.dart';

class TaxScreen extends ConsumerStatefulWidget {
  const TaxScreen({super.key});

  @override
  ConsumerState<TaxScreen> createState() => _TaxScreenState();
}

class _TaxScreenState extends ConsumerState<TaxScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taxProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tax', style: AppTypography.h2),
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
                hintText: 'Search tax...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: (v) => ref.read(taxProvider.notifier).setSearch(v),
            ),
            const SizedBox(height: AppSpacing.space4),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.taxes.isEmpty
                      ? Center(child: Text(state.error ?? 'No tax found',
                          style: AppTypography.body.copyWith(color: AppColors.textSecondary)))
                      : ListView.builder(
                          itemCount: state.taxes.length,
                          itemBuilder: (_, i) {
                            final tax = state.taxes[i];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.warningSoft,
                                  child: const Icon(Icons.receipt_long, color: AppColors.warning, size: 20),
                                ),
                                title: Text(tax.name),
                                subtitle: Text('${tax.rate}%'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: tax.isActive
                                            ? AppColors.success.withAlpha(25)
                                            : AppColors.error.withAlpha(25),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(tax.isActive ? 'Active' : 'Inactive',
                                          style: TextStyle(fontSize: 12,
                                              color: tax.isActive ? AppColors.success : AppColors.error)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 20),
                                      onPressed: () => _showEditDialog(context, tax),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                      onPressed: () => _confirmDelete(context, tax.id, tax.name),
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
    final rateCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Tax'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: nameCtrl, label: 'Tax Name'),
            const SizedBox(height: 12),
            AppTextField(controller: rateCtrl, label: 'Tax Rate (%)', keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || rateCtrl.text.isEmpty) return;
              await ref.read(taxProvider.notifier).createTax({
                'TaxName': nameCtrl.text,
                'TaxRate': double.tryParse(rateCtrl.text) ?? 0,
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic tax) {
    final nameCtrl = TextEditingController(text: tax.name);
    final rateCtrl = TextEditingController(text: tax.rate.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Tax'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: nameCtrl, label: 'Tax Name'),
            const SizedBox(height: 12),
            AppTextField(controller: rateCtrl, label: 'Tax Rate (%)', keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || rateCtrl.text.isEmpty) return;
              await ref.read(taxProvider.notifier).updateTax(tax.id, {
                'TaxName': nameCtrl.text,
                'TaxRate': double.tryParse(rateCtrl.text) ?? 0,
              });
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
        title: const Text('Delete Tax'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await ref.read(taxProvider.notifier).deleteTax(id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
