import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_text_field.dart';
import 'modifier_provider.dart';
import '../../core/widgets/backoffice_shimmer.dart';

class ModifierScreen extends ConsumerStatefulWidget {
  const ModifierScreen({super.key});

  @override
  ConsumerState<ModifierScreen> createState() => _ModifierScreenState();
}

class _ModifierScreenState extends ConsumerState<ModifierScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(modifierProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(modifierProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(modifierProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space6),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Modifiers', style: AppTypography.h2),
                    IconButton(
                      icon:
                          const Icon(Icons.add_circle, color: AppColors.accent),
                      onPressed: () => _showAddModifierDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space6),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search modifiers...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  onChanged: (v) =>
                      ref.read(modifierProvider.notifier).setSearch(v),
                ),
                const SizedBox(height: AppSpacing.space4),
                state.isLoading
                    ? Column(
                        children: List.generate(
                          8,
                          (i) => const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: BackofficeShimmerRow(dense: true),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: state.modifiers.isEmpty
                                  ? Center(
                                      child: Text(
                                        state.error ?? 'No modifiers found',
                                        style: AppTypography.body.copyWith(
                                            color: AppColors.textSecondary),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: state.modifiers.length,
                                      itemBuilder: (_, i) {
                                        final m = state.modifiers[i];
                                        return Card(
                                          color:
                                              state.selectedModifierId == m.id
                                                  ? AppColors.accentSoft
                                                  : null,
                                          child: ListTile(
                                            title: Text(m.name),
                                            subtitle: Text(
                                                '${m.isRequired ? 'Required' : 'Optional'} • Max: ${m.maxSelect ?? 1}'),
                                            trailing: IconButton(
                                              icon: const Icon(
                                                  Icons.chevron_right),
                                              onPressed: () => ref
                                                  .read(
                                                      modifierProvider.notifier)
                                                  .loadOptions(m.id),
                                            ),
                                            onTap: () => ref
                                                .read(modifierProvider.notifier)
                                                .loadOptions(m.id),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            if (state.selectedModifierId != null) ...[
                              const SizedBox(width: AppSpacing.space4),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Options',
                                            style: AppTypography.h3),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle,
                                              color: AppColors.accent,
                                              size: 22),
                                          onPressed: () =>
                                              _showAddOptionDialog(context),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.space3),
                                    Expanded(
                                      child: state.isLoadingOptions
                                          ? ListView.builder(
                                              itemCount: 6,
                                              itemBuilder: (_, __) =>
                                                  const Padding(
                                                padding:
                                                    EdgeInsets.only(bottom: 10),
                                                child: BackofficeShimmerRow(),
                                              ),
                                            )
                                          : state.currentOptions.isEmpty
                                              ? Center(
                                                  child: Text('No options',
                                                      style: AppTypography.body
                                                          .copyWith(
                                                              color: AppColors
                                                                  .textSecondary)))
                                              : ListView.builder(
                                                  itemCount: state
                                                      .currentOptions.length,
                                                  itemBuilder: (_, i) {
                                                    final opt =
                                                        state.currentOptions[i];
                                                    return Card(
                                                      child: ListTile(
                                                        title: Text(opt.name),
                                                        subtitle: opt.additionalPrice !=
                                                                    null &&
                                                                opt.additionalPrice! >
                                                                    0
                                                            ? Text(
                                                                '+Rp ${_fmt(opt.additionalPrice!)}')
                                                            : null,
                                                        trailing: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                  Icons.edit,
                                                                  color: AppColors
                                                                      .textSecondary,
                                                                  size: 18),
                                                              onPressed: () =>
                                                                  _showEditOptionDialog(
                                                                      context,
                                                                      opt),
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                  Icons
                                                                      .delete_outline,
                                                                  color:
                                                                      AppColors
                                                                          .error,
                                                                  size: 18),
                                                              onPressed: () =>
                                                                  _confirmDeleteOption(
                                                                      context,
                                                                      opt.id,
                                                                      opt.name),
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
                            ],
                          ],
                        ),
                      ),
                // end content column children
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddModifierDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final maxSelectCtrl = TextEditingController();
    bool isRequired = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Modifier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: nameCtrl, label: 'Modifier Name'),
              const SizedBox(height: 12),
              AppTextField(
                  controller: maxSelectCtrl,
                  label: 'Max Select',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Required'),
                value: isRequired,
                onChanged: (v) => setDialogState(() => isRequired = v ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                await ref.read(modifierProvider.notifier).createModifier({
                  'ModifierName': nameCtrl.text,
                  'IsRequired': isRequired,
                  if (maxSelectCtrl.text.isNotEmpty)
                    'MaxSelect': int.tryParse(maxSelectCtrl.text),
                });
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptionDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Option'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: nameCtrl, label: 'Option Name'),
            const SizedBox(height: 12),
            AppTextField(
                controller: priceCtrl,
                label: 'Additional Price (optional)',
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              final modId = ref.read(modifierProvider).selectedModifierId;
              if (modId == null) return;
              await ref.read(modifierProvider.notifier).createOption(modId, {
                'OptionName': nameCtrl.text,
                if (priceCtrl.text.isNotEmpty)
                  'AdditionalPrice': double.tryParse(priceCtrl.text),
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditOptionDialog(BuildContext context, dynamic opt) {
    final nameCtrl = TextEditingController(text: opt.name);
    final priceCtrl =
        TextEditingController(text: opt.additionalPrice?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Option'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: nameCtrl, label: 'Option Name'),
            const SizedBox(height: 12),
            AppTextField(
                controller: priceCtrl,
                label: 'Additional Price',
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              await ref.read(modifierProvider.notifier).updateOption(opt.id, {
                'OptionName': nameCtrl.text,
                if (priceCtrl.text.isNotEmpty)
                  'AdditionalPrice': double.tryParse(priceCtrl.text),
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteOption(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Option'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await ref.read(modifierProvider.notifier).deleteOption(id);
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
