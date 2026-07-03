import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/modifier_model.dart';
import 'menu_provider.dart';
import 'repositories/menu_repository.dart';

class ModifierDialog extends ConsumerStatefulWidget {
  final String itemId;
  final String itemName;
  final double itemPrice;

  const ModifierDialog({
    super.key,
    required this.itemId,
    required this.itemName,
    required this.itemPrice,
  });

  static Future<Map<String, dynamic>?> show(BuildContext context, {required String itemId, required String itemName, required double itemPrice}) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ModifierDialog(itemId: itemId, itemName: itemName, itemPrice: itemPrice),
    );
  }

  @override
  ConsumerState<ModifierDialog> createState() => _ModifierDialogState();
}

class _ModifierDialogState extends ConsumerState<ModifierDialog> {
  final Map<String, String> _selectedOptions = {};
  final _qtyController = TextEditingController(text: '1');
  final _noteController = TextEditingController();
  late Future<List<ModifierModel>> _modifiersFuture;

  @override
  void initState() {
    super.initState();
    _modifiersFuture = _fetchModifiers();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<List<ModifierModel>> _fetchModifiers() async {
    try {
      final repo = ref.read(menuRepositoryProvider);
      final item = await repo.getItemById(widget.itemId);
      return item.modifiers;
    } catch (e) {
      return [];
    }
  }

  double get _additionalPrice {
    double total = 0;
    for (final optId in _selectedOptions.values) {
      if (optId.isNotEmpty) total += 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.itemName, style: AppTypography.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Harga: ${CurrencyFormatter.format(widget.itemPrice)}', style: AppTypography.body.copyWith(color: AppColors.accent)),
            const SizedBox(height: AppSpacing.space4),

            // Quantity
            Text('Jumlah', style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.space2),
            Row(
              children: [
                IconButton.filled(
                  icon: const Icon(Icons.remove, size: 20),
                  onPressed: () {
                    final qty = int.tryParse(_qtyController.text) ?? 1;
                    if (qty > 1) _qtyController.text = '${qty - 1}';
                  },
                ),
                const SizedBox(width: AppSpacing.space3),
                Text(_qtyController.text, style: AppTypography.title),
                const SizedBox(width: AppSpacing.space3),
                IconButton.filled(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () {
                    final qty = int.tryParse(_qtyController.text) ?? 1;
                    _qtyController.text = '${qty + 1}';
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),

            // Modifiers
            FutureBuilder<List<ModifierModel>>(
              future: _modifiersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final modifiers = snapshot.data ?? [];
                if (modifiers.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Opsi', style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppSpacing.space2),
                    ...modifiers.map((modifier) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            modifier.modifierName,
                            style: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: AppSpacing.space1),
                          ...modifier.options.map((option) {
                            final isSelected = _selectedOptions[modifier.id] == option.id;
                            return RadioListTile<String>(
                              title: Row(
                                children: [
                                  Expanded(child: Text(option.optionName, style: AppTypography.body)),
                                  if (option.additionalPrice > 0)
                                    Text(
                                      '+${CurrencyFormatter.format(option.additionalPrice)}',
                                      style: AppTypography.caption.copyWith(color: AppColors.accent),
                                    ),
                                ],
                              ),
                              value: option.id,
                              groupValue: _selectedOptions[modifier.id],
                              onChanged: (val) {
                                setState(() => _selectedOptions[modifier.id] = val!);
                              },
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            );
                          }),
                        ],
                      ),
                    )),
                  ],
                );
              },
            ),

            // Notes
            const SizedBox(height: AppSpacing.space4),
            Text('Catatan', style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.space2),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Contoh: Tidak pedas',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        AppButton(
          label: 'Tambahkan',
          onPressed: () {
            Navigator.pop(context, {
              'qty': int.tryParse(_qtyController.text) ?? 1,
              'note': _noteController.text.isNotEmpty ? _noteController.text : null,
              'modifierOptions': Map<String, String>.from(_selectedOptions),
            });
          },
        ),
      ],
    );
  }
}
