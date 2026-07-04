import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_text_field.dart';
import 'branch_provider.dart';

class BranchScreen extends ConsumerStatefulWidget {
  const BranchScreen({super.key});

  @override
  ConsumerState<BranchScreen> createState() => _BranchScreenState();
}

class _BranchScreenState extends ConsumerState<BranchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(branchProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Branches', style: AppTypography.h2),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.accent),
                  onPressed: () => _showAddBranchDialog(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space6),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search branches...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: (value) {
                ref.read(branchProvider.notifier).setSearch(value);
              },
            ),
            const SizedBox(height: AppSpacing.space4),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.branches.isEmpty
                      ? Center(
                          child: Text(state.error ?? 'No branches found', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                        )
                      : ListView.builder(
                          itemCount: state.branches.length,
                          itemBuilder: (_, i) {
                            final branch = state.branches[i];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.accentSoft,
                                  child: Text(branch.code.substring(0, 1).toUpperCase(), style: const TextStyle(color: AppColors.accent)),
                                ),
                                title: Text('${branch.code} - ${branch.name}'),
                                subtitle: Text(branch.address ?? branch.phone ?? 'No address'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: branch.isActive ? AppColors.success.withAlpha(25) : AppColors.error.withAlpha(25),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        branch.isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(color: branch.isActive ? AppColors.success : AppColors.error, fontSize: 12),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 20),
                                      onPressed: () => _showEditBranchDialog(context, branch),
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

  void _showAddBranchDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Branch'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: codeCtrl, label: 'Branch Code'),
              const SizedBox(height: 12),
              AppTextField(controller: nameCtrl, label: 'Branch Name'),
              const SizedBox(height: 12),
              AppTextField(controller: addressCtrl, label: 'Address'),
              const SizedBox(height: 12),
              AppTextField(controller: phoneCtrl, label: 'Phone'),
              const SizedBox(height: 12),
              AppTextField(controller: emailCtrl, label: 'Email'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (codeCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
              final data = <String, dynamic>{
                'BranchCode': codeCtrl.text,
                'BranchName': nameCtrl.text,
                'Address': addressCtrl.text,
                'Phone': phoneCtrl.text,
                'Email': emailCtrl.text,
              };
              await ref.read(branchProvider.notifier).createBranch(data);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditBranchDialog(BuildContext context, dynamic branch) {
    final codeCtrl = TextEditingController(text: branch.code);
    final nameCtrl = TextEditingController(text: branch.name);
    final addressCtrl = TextEditingController(text: branch.address ?? '');
    final phoneCtrl = TextEditingController(text: branch.phone ?? '');
    final emailCtrl = TextEditingController(text: branch.email ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Branch'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: codeCtrl, label: 'Branch Code'),
              const SizedBox(height: 12),
              AppTextField(controller: nameCtrl, label: 'Branch Name'),
              const SizedBox(height: 12),
              AppTextField(controller: addressCtrl, label: 'Address'),
              const SizedBox(height: 12),
              AppTextField(controller: phoneCtrl, label: 'Phone'),
              const SizedBox(height: 12),
              AppTextField(controller: emailCtrl, label: 'Email'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (codeCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
              final data = <String, dynamic>{
                'BranchCode': codeCtrl.text,
                'BranchName': nameCtrl.text,
                'Address': addressCtrl.text,
                'Phone': phoneCtrl.text,
                'Email': emailCtrl.text,
              };
              await ref.read(branchProvider.notifier).updateBranch(branch.id, data);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
