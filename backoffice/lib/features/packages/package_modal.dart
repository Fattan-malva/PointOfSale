import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_modal.dart';
import '../../models/item_model.dart';

class PackageModal {
  static Future<Map<String, dynamic>?> create(
    BuildContext context,
  ) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final loading = ValueNotifier(false);

    return AppModal.show<Map<String, dynamic>>(
      context,
      AppModalConfig(
        title: 'Create Package',
        subtitle: 'Create a package and add items',
        loading: loading,
        submitLabel: 'Create',
        onSubmit: () async {
          final code = codeCtrl.text.trim();
          final name = nameCtrl.text.trim();
          final price = double.tryParse(priceCtrl.text);

          if (code.isEmpty || name.isEmpty || price == null) return;

          loading.value = true;
          await Future.delayed(const Duration(milliseconds: 100));
          loading.value = false;

          Navigator.pop(context, {
            'ItemCode': code,
            'ItemName': name,
            'Price': price,
          });
        },
        fields: [
          _RespRow([
            ModalField(controller: codeCtrl, label: 'Package Code'),
            ModalField(
                controller: nameCtrl, label: 'Package Name', autofocus: true),
          ]),
          const SizedBox(height: 20),
          _RespRow([
            _Field(
              label: 'PRICE',
              child: _CurrencyField(controller: priceCtrl, hint: '0'),
            ),
          ]),
        ],
      ),
    );
  }

  static Future<Map<String, dynamic>?> edit(
    BuildContext context,
    ItemModel pkg,
  ) {
    final codeCtrl = TextEditingController(text: pkg.itemCode);
    final nameCtrl = TextEditingController(text: pkg.name);
    final priceCtrl = TextEditingController(text: pkg.price.toStringAsFixed(0));
    final loading = ValueNotifier(false);

    return AppModal.show<Map<String, dynamic>>(
      context,
      AppModalConfig(
        title: 'Edit Package',
        subtitle: 'Update package details',
        loading: loading,
        submitLabel: 'Update',
        onSubmit: () async {
          final code = codeCtrl.text.trim();
          final name = nameCtrl.text.trim();
          final price = double.tryParse(priceCtrl.text);

          if (code.isEmpty || name.isEmpty || price == null) return;

          loading.value = true;
          await Future.delayed(const Duration(milliseconds: 100));
          loading.value = false;

          Navigator.pop(context, {
            'ItemCode': code,
            'ItemName': name,
            'Price': price,
          });
        },
        fields: [
          _RespRow([
            ModalField(controller: codeCtrl, label: 'Package Code'),
            ModalField(
                controller: nameCtrl, label: 'Package Name', autofocus: true),
          ]),
          const SizedBox(height: 20),
          _RespRow([
            _Field(
              label: 'PRICE',
              child: _CurrencyField(controller: priceCtrl, hint: '0'),
            ),
          ]),
        ],
      ),
    );
  }

  static Future<bool> confirmDelete(
    BuildContext context,
    String pkgName,
  ) {
    final loading = ValueNotifier(false);

    return AppModal.show<bool>(
      context,
      AppModalConfig(
        title: 'Delete Package',
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
          const ConfirmContent(
              message: 'Are you sure you want to delete this package?'),
          // keep text above; custom message below to keep consistent spacing:
          const SizedBox(height: 6),
          Text(
            '“$pkgName”',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF111111),
              height: 1.6,
            ),
          ),
        ],
      ),
    ).then((v) => v ?? false);
  }

  static Future<Map<String, dynamic>?> addDetail(
    BuildContext context, {
    required List<ItemModel> items,
    int initialQty = 1,
  }) {
    final qtyCtrl = TextEditingController(text: initialQty.toString());
    final searchCtrl = TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: const Color(0x40A8A8AE),
      builder: (_) {
        return _AddDetailDialog(
          items: items,
          filteredInit: List<ItemModel>.from(items),
          searchCtrl: searchCtrl,
          qtyCtrl: qtyCtrl,
          selectedItemId: null,
        );
      },
    );
  }

  static Future<bool> confirmRemoveDetail(
    BuildContext context,
    String itemName,
  ) {
    final loading = ValueNotifier(false);

    return AppModal.show<bool>(
      context,
      AppModalConfig(
        title: 'Remove Item',
        subtitle: 'This item will be removed from the package',
        loading: loading,
        destructive: true,
        submitLabel: 'Remove',
        onSubmit: () async {
          loading.value = true;
          await Future.delayed(const Duration(milliseconds: 100));
          loading.value = false;
          Navigator.pop(context, true);
        },
        fields: [
          ConfirmContent(message: 'Remove “$itemName” from this package?'),
        ],
      ),
    ).then((v) => v ?? false);
  }
}

class _AddDetailDialog extends StatefulWidget {
  final List<ItemModel> items;
  final List<ItemModel> filteredInit;
  final TextEditingController searchCtrl;
  final TextEditingController qtyCtrl;
  final String? selectedItemId;

  const _AddDetailDialog({
    required this.items,
    required this.filteredInit,
    required this.searchCtrl,
    required this.qtyCtrl,
    required this.selectedItemId,
  });

  @override
  State<_AddDetailDialog> createState() => _AddDetailDialogState();
}

class _AddDetailDialogState extends State<_AddDetailDialog> {
  late List<ItemModel> _filtered;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(widget.filteredInit);
    _selectedId = widget.selectedItemId;
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _filtered.isEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Item to Package',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.03,
                  height: 1.2,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select an item and quantity',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF787774),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEAEAEA)),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        size: 18, color: Color(0xFF111111)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: widget.searchCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Search items...',
                          hintStyle: TextStyle(
                              fontSize: 14, color: AppColors.textDisabled),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF111111)),
                        onChanged: (v) {
                          final q = v.trim().toLowerCase();
                          setState(() {
                            _filtered = widget.items.where((item) {
                              return item.name.toLowerCase().contains(q) ||
                                  item.itemCode.toLowerCase().contains(q);
                            }).toList();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: isEmpty
                    ? Center(
                        child: Text(
                          'No items found',
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF787774)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final item = _filtered[i];
                          final selected = _selectedId == item.id;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFF7F6F3)
                                  : Colors.white,
                              border:
                                  Border.all(color: const Color(0xFFEAEAEA)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              dense: true,
                              leading: Radio<String>(
                                value: item.id,
                                groupValue: _selectedId,
                                onChanged: (v) {
                                  setState(() {
                                    _selectedId = v;
                                  });
                                },
                              ),
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111111)),
                              ),
                              subtitle: Text(
                                '${item.itemCode} • Rp ${item.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF787774),
                                    height: 1.4),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedId = item.id;
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              _Field(
                label: 'QUANTITY',
                child:
                    _SimpleNumberField(controller: widget.qtyCtrl, hint: '1'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF787774),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: (_selectedId == null)
                        ? null
                        : () {
                            final qty =
                                int.tryParse(widget.qtyCtrl.text.trim()) ?? 1;
                            Navigator.pop(context, {
                              'ItemID': _selectedId,
                              'Qty': qty,
                            });
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFEAEAEA),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      'Save',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _SimpleNumberField({required this.controller, required this.hint});

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
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(fontSize: 14, color: AppColors.textDisabled),
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
                if (i < children.length - 1 &&
                    children[i] is! SizedBox &&
                    children[i] is! SizedBox)
                  const SizedBox(height: 16),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (children[i] is! SizedBox) Expanded(child: children[i]),
              if (i < children.length - 1 &&
                  children[i] is! SizedBox &&
                  children[i + 1] is! SizedBox)
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.06,
            color: Color(0xFF787774),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
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
          const Text('Rp ',
              style: TextStyle(fontSize: 14, color: Color(0xFF787774))),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 14, color: AppColors.textDisabled),
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
