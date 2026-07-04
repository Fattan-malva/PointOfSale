import 'package:flutter/material.dart';
import '../../core/widgets/app_modal.dart';
import '../../core/constants/app_colors.dart';
import '../../models/item_model.dart';
import '../../models/category_model.dart';
import '../../models/tax_model.dart';
import '../../models/discount_model.dart';

class ItemModal {
  static Future<Map<String, dynamic>?> create(
    BuildContext context, {
    required List<CategoryModel> categories,
    required List<TaxModel> allTaxes,
    required List<DiscountModel> allDiscounts,
  }) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final loading = ValueNotifier(false);
    String? categoryId;
    final taxIds = <String>{};
    final discountIds = <String>{};

    return AppModal.show<Map<String, dynamic>>(context, AppModalConfig(
      title: 'Create Item',
      subtitle: 'Add a new product or service item',
      loading: loading,
      submitLabel: 'Create',
      onSubmit: () async {
        if (nameCtrl.text.trim().isEmpty) return;
        loading.value = true;
        await Future.delayed(const Duration(milliseconds: 100));
        loading.value = false;
        Navigator.pop(context, {
          'ItemName': nameCtrl.text.trim(),
          'ItemCode': codeCtrl.text.trim(),
          'Price': double.tryParse(priceCtrl.text) ?? 0,
          'CostPrice': double.tryParse(costCtrl.text),
          'Description': descCtrl.text.trim(),
          'CategoryID': categoryId,
          'taxIds': taxIds.toList(),
          'discountIds': discountIds.toList(),
        });
      },
      fields: [
        _RespRow([
          ModalField(controller: nameCtrl, label: 'Item Name', hint: 'e.g. Nasi Goreng', autofocus: true),
          ModalField(controller: codeCtrl, label: 'Item Code', hint: 'e.g. ITM-001'),
        ]),
        const SizedBox(height: 20),
        _RespRow([
          _Field(label: 'PRICE', child: _CurrencyField(controller: priceCtrl, hint: '0')),
          _Field(label: 'COST PRICE', child: _CurrencyField(controller: costCtrl, hint: '0 (optional)')),
        ]),
        const SizedBox(height: 20),
        _RespRow([
          if (categories.isNotEmpty) _buildCategoryPicker(categories, (id) => categoryId = id),
          _Field(label: 'DESCRIPTION', child: _ModalTextField(controller: descCtrl, hint: 'Optional description', maxLines: 2)),
        ]),
        if (allTaxes.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildCheckboxGroup(
            label: 'Taxes',
            items: allTaxes.map((t) => _CheckItem(t.id, '${t.name} (${t.rate}%)')).toList(),
            selected: taxIds,
          ),
        ],
        if (allDiscounts.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildCheckboxGroup(
            label: 'Discounts',
            items: allDiscounts.map((d) => _CheckItem(
              d.id,
              d.discountType == 'Percentage'
                  ? '${d.name} (${d.discountValue}%)'
                  : '${d.name} (Rp ${d.discountValue.toStringAsFixed(0)})',
            )).toList(),
            selected: discountIds,
          ),
        ],
      ],
    ));
  }

  static Future<Map<String, dynamic>?> edit(
    BuildContext context,
    ItemModel item, {
    required List<CategoryModel> categories,
    required List<TaxModel> allTaxes,
    required List<DiscountModel> allDiscounts,
  }) {
    final codeCtrl = TextEditingController(text: item.itemCode);
    final nameCtrl = TextEditingController(text: item.name);
    final priceCtrl = TextEditingController(text: item.price.toStringAsFixed(0));
    final costCtrl = TextEditingController(text: item.costPrice?.toStringAsFixed(0) ?? '');
    final descCtrl = TextEditingController(text: item.description ?? '');
    final loading = ValueNotifier(false);
    String? categoryId = item.categoryId;
    final taxIds = Set<String>.from(item.taxes.map((t) => t.id));
    final discountIds = Set<String>.from(item.discounts.map((d) => d.id));

    return AppModal.show<Map<String, dynamic>>(context, AppModalConfig(
      title: 'Edit Item',
      subtitle: 'Update item details',
      loading: loading,
      submitLabel: 'Update',
      onSubmit: () async {
        if (nameCtrl.text.trim().isEmpty) return;
        loading.value = true;
        await Future.delayed(const Duration(milliseconds: 100));
        loading.value = false;
        Navigator.pop(context, {
          'ItemName': nameCtrl.text.trim(),
          'ItemCode': codeCtrl.text.trim(),
          'Price': double.tryParse(priceCtrl.text) ?? 0,
          'CostPrice': double.tryParse(costCtrl.text),
          'Description': descCtrl.text.trim(),
          'CategoryID': categoryId,
          'taxIds': taxIds.toList(),
          'discountIds': discountIds.toList(),
        });
      },
      fields: [
        _RespRow([
          ModalField(controller: nameCtrl, label: 'Item Name', autofocus: true),
          ModalField(controller: codeCtrl, label: 'Item Code'),
        ]),
        const SizedBox(height: 20),
        _RespRow([
          _Field(label: 'PRICE', child: _CurrencyField(controller: priceCtrl, hint: '0')),
          _Field(label: 'COST PRICE', child: _CurrencyField(controller: costCtrl, hint: '0 (optional)')),
        ]),
        const SizedBox(height: 20),
        _RespRow([
          if (categories.isNotEmpty) _buildCategoryPicker(categories, (id) => categoryId = id, initial: item.categoryId),
          _Field(label: 'DESCRIPTION', child: _ModalTextField(controller: descCtrl, hint: 'Optional description', maxLines: 2)),
        ]),
        if (allTaxes.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildCheckboxGroup(
            label: 'Taxes',
            items: allTaxes.map((t) => _CheckItem(t.id, '${t.name} (${t.rate}%)')).toList(),
            selected: taxIds,
          ),
        ],
        if (allDiscounts.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildCheckboxGroup(
            label: 'Discounts',
            items: allDiscounts.map((d) => _CheckItem(
              d.id,
              d.discountType == 'Percentage'
                  ? '${d.name} (${d.discountValue}%)'
                  : '${d.name} (Rp ${d.discountValue.toStringAsFixed(0)})',
            )).toList(),
            selected: discountIds,
          ),
        ],
      ],
    ));
  }

  static Future<bool> confirmDelete(BuildContext context, String name) {
    final loading = ValueNotifier(false);

    return AppModal.show<bool>(context, AppModalConfig(
      title: 'Delete Item',
      subtitle: 'This action cannot be undone',
      loading: loading,
      destructive: true,
      submitLabel: 'Delete',
      onSubmit: () async {
        loading.value = true;
        await Future.delayed(const Duration(milliseconds: 100));
        loading.value = false;
        Navigator.pop(context, true);
      },
      fields: [
        ConfirmContent(message: 'Are you sure you want to delete "$name"?'),
      ],
    )).then((v) => v ?? false);
  }

  static Widget _buildCategoryPicker(
    List<CategoryModel> categories,
    ValueChanged<String?> onSelected, {
    String? initial,
  }) {
    return _CategoryPicker(categories: categories, initial: initial, onSelected: onSelected);
  }

  static Widget _buildCheckboxGroup({
    required String label,
    required List<_CheckItem> items,
    required Set<String> selected,
  }) {
    return _CheckboxGroup(label: label, items: items, selected: selected);
  }
}

class _CheckItem {
  final String id;
  final String label;
  const _CheckItem(this.id, this.label);
}

class _RespRow extends StatelessWidget {
  final List<Widget> children;
  const _RespRow(this.children);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth < 400) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (children[i] is! SizedBox) children[i],
                if (i < children.length - 1 && children[i] is! SizedBox)
                  const SizedBox(height: 16),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (children[i] is! SizedBox)
                Expanded(child: children[i]),
              if (i < children.length - 1 && children[i] is! SizedBox && children[i + 1] is! SizedBox)
                const SizedBox(width: 16),
            ],
          ],
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;

  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.06, color: Color(0xFF787774))),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _ModalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  const _ModalTextField({required this.controller, this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEAEAEA)),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.textDisabled),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
      ),
    );
  }
}

class _CurrencyField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _CurrencyField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEAEAEA)),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Text('Rp ', style: TextStyle(fontSize: 14, color: Color(0xFF787774))),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.textDisabled),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPicker extends StatefulWidget {
  final List<CategoryModel> categories;
  final String? initial;
  final ValueChanged<String?> onSelected;

  const _CategoryPicker({required this.categories, this.initial, required this.onSelected});

  @override
  State<_CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<_CategoryPicker> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.06, color: Color(0xFF787774))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEAEAEA)),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selected,
              isExpanded: true,
              hint: const Text('Select category', style: TextStyle(fontSize: 14, color: Color(0xFF111111))),
              items: [
                const DropdownMenuItem(value: null, child: Text('No category', style: TextStyle(fontSize: 14, color: Color(0xFF787774)))),
                ...widget.categories.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name, style: const TextStyle(fontSize: 14, color: Color(0xFF111111))),
                )),
              ],
              onChanged: (v) {
                setState(() => _selected = v);
                widget.onSelected(v);
              },
              style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckboxGroup extends StatefulWidget {
  final String label;
  final List<_CheckItem> items;
  final Set<String> selected;

  const _CheckboxGroup({required this.label, required this.items, required this.selected});

  @override
  State<_CheckboxGroup> createState() => _CheckboxGroupState();
}

class _CheckboxGroupState extends State<_CheckboxGroup> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.06, color: Color(0xFF787774))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEAEAEA)),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.items.map((item) {
              final checked = _selected.contains(item.id);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (checked) { _selected.remove(item.id); } else { _selected.add(item.id); }
                  });
                  widget.selected
                    ..clear()
                    ..addAll(_selected);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: checked ? const Color(0xFFF7F6F3) : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: checked ? const Color(0xFF111111) : const Color(0xFFEAEAEA),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                        size: 16,
                        color: checked ? const Color(0xFF111111) : const Color(0xFF111111),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: checked ? FontWeight.w500 : FontWeight.w400,
                          color: checked ? const Color(0xFF111111) : const Color(0xFF5C5C63),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
