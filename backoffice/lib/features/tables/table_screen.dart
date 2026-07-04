import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_text_field.dart';
import 'table_provider.dart';

class TableScreen extends ConsumerStatefulWidget {
  const TableScreen({super.key});

  @override
  ConsumerState<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends ConsumerState<TableScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tableProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tables', style: AppTypography.h2),
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
                hintText: 'Search tables...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: (v) => ref.read(tableProvider.notifier).setSearch(v),
            ),
            const SizedBox(height: AppSpacing.space4),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.tables.isEmpty
                      ? Center(child: Text(state.error ?? 'No tables found',
                          style: AppTypography.body.copyWith(color: AppColors.textSecondary)))
                      : ListView.builder(
                          itemCount: state.tables.length,
                          itemBuilder: (_, i) {
                            final t = state.tables[i];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.accentSoft,
                                  child: Text(t.tableCode, style: const TextStyle(color: AppColors.accent, fontSize: 12)),
                                ),
                                title: Text(t.tableName ?? t.tableCode),
                                subtitle: Text(
                                  '${t.branchName ?? 'No branch'}'
                                  '${t.capacity != null ? ' • ${t.capacity} seats' : ''}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: t.isActive ? AppColors.success.withAlpha(25) : AppColors.error.withAlpha(25),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(t.isActive ? 'Active' : 'Inactive',
                                          style: TextStyle(fontSize: 12,
                                              color: t.isActive ? AppColors.success : AppColors.error)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 20),
                                      onPressed: () => _showEditDialog(context, t),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                      onPressed: () => _confirmDelete(context, t.id, t.tableCode),
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
    final capacityCtrl = TextEditingController();
    String? branchId;
    final state = ref.read(tableProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Table'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Branch', border: OutlineInputBorder()),
                items: state.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                onChanged: (v) => branchId = v,
              ),
              const SizedBox(height: 12),
              AppTextField(controller: codeCtrl, label: 'Table Code'),
              const SizedBox(height: 12),
              AppTextField(controller: nameCtrl, label: 'Table Name (optional)'),
              const SizedBox(height: 12),
              AppTextField(controller: capacityCtrl, label: 'Capacity (optional)', keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (branchId == null || codeCtrl.text.isEmpty) return;
              final data = <String, dynamic>{
                'BranchID': branchId,
                'TableCode': codeCtrl.text,
                'TableName': nameCtrl.text,
              };
              if (capacityCtrl.text.isNotEmpty) data['Capacity'] = int.tryParse(capacityCtrl.text);
              await ref.read(tableProvider.notifier).createTable(data);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic t) {
    final codeCtrl = TextEditingController(text: t.tableCode);
    final nameCtrl = TextEditingController(text: t.tableName ?? '');
    final capacityCtrl = TextEditingController(text: t.capacity?.toString() ?? '');
    String? branchId = t.branchId;
    final state = ref.read(tableProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Table'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: branchId,
                decoration: const InputDecoration(labelText: 'Branch', border: OutlineInputBorder()),
                items: state.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                onChanged: (v) => branchId = v,
              ),
              const SizedBox(height: 12),
              AppTextField(controller: codeCtrl, label: 'Table Code'),
              const SizedBox(height: 12),
              AppTextField(controller: nameCtrl, label: 'Table Name'),
              const SizedBox(height: 12),
              AppTextField(controller: capacityCtrl, label: 'Capacity', keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (branchId == null || codeCtrl.text.isEmpty) return;
              final data = <String, dynamic>{
                'BranchID': branchId,
                'TableCode': codeCtrl.text,
                'TableName': nameCtrl.text,
              };
              if (capacityCtrl.text.isNotEmpty) data['Capacity'] = int.tryParse(capacityCtrl.text);
              await ref.read(tableProvider.notifier).updateTable(t.id, data);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Table'),
        content: Text('Are you sure you want to delete table "$code"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await ref.read(tableProvider.notifier).deleteTable(id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
