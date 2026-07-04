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
    final selectedItems = <ItemModel>[];
    final searchCtrl = TextEditingController();
    final availableItems = <ItemModel>[]; // Ini akan diisi dari data source

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: const Color(0x40A8A8AE),
      builder: (_) {
        return _PackageFormDialog(
          mode: _DialogMode.create,
          codeCtrl: codeCtrl,
          nameCtrl: nameCtrl,
          priceCtrl: priceCtrl,
          searchCtrl: searchCtrl,
          loading: loading,
          availableItems: availableItems,
          selectedItems: selectedItems,
          onSave: () async {
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
              'Items': selectedItems.map((e) => e.id).toList(),
            });
          },
        );
      },
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
    final selectedItems =
        <ItemModel>[]; // Ini akan diisi dengan item yang sudah dipilih
    final searchCtrl = TextEditingController();
    final availableItems = <ItemModel>[]; // Ini akan diisi dari data source

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: const Color(0x40A8A8AE),
      builder: (_) {
        return _PackageFormDialog(
          mode: _DialogMode.edit,
          codeCtrl: codeCtrl,
          nameCtrl: nameCtrl,
          priceCtrl: priceCtrl,
          searchCtrl: searchCtrl,
          loading: loading,
          availableItems: availableItems,
          selectedItems: selectedItems,
          onSave: () async {
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
              'Items': selectedItems.map((e) => e.id).toList(),
            });
          },
        );
      },
    );
  }

  // Method untuk add detail (dipertahankan dari kode sebelumnya)
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
          ConfirmContent(
              message: 'Are you sure you want to delete this package?'),
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

enum _DialogMode { create, edit }

class _PackageFormDialog extends StatefulWidget {
  final _DialogMode mode;
  final TextEditingController codeCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController searchCtrl;
  final ValueNotifier<bool> loading;
  final List<ItemModel> availableItems;
  final List<ItemModel> selectedItems;
  final VoidCallback onSave;

  const _PackageFormDialog({
    required this.mode,
    required this.codeCtrl,
    required this.nameCtrl,
    required this.priceCtrl,
    required this.searchCtrl,
    required this.loading,
    required this.availableItems,
    required this.selectedItems,
    required this.onSave,
  });

  @override
  State<_PackageFormDialog> createState() => _PackageFormDialogState();
}

class _PackageFormDialogState extends State<_PackageFormDialog> {
  late List<ItemModel> _filteredItems;
  late List<ItemModel> _selectedItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.availableItems);
    _selectedItems = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 600),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel - Available Items
            Expanded(
              flex: 1,
              child: _buildLeftPanel(),
            ),
            // Divider
            const VerticalDivider(
                width: 1, thickness: 1, color: Color(0xFFEAEAEA)),
            // Right Panel - Package Details & Selected Items
            Expanded(
              flex: 1,
              child: _buildRightPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.mode == _DialogMode.create
                ? 'Create Package'
                : 'Edit Package',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.03,
              height: 1.2,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select items to add',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF787774),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _buildSearchField(),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      'No items available',
                      style: TextStyle(fontSize: 14, color: Color(0xFF787774)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (_, index) {
                      final item = _filteredItems[index];
                      final isSelected =
                          _selectedItems.any((e) => e.id == item.id);
                      return _buildItemTile(item, isSelected);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEAEAEA)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: Color(0xFF111111)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search items...',
                hintStyle:
                    TextStyle(fontSize: 14, color: AppColors.textDisabled),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
              onChanged: (v) {
                final q = v.trim().toLowerCase();
                setState(() {
                  _filteredItems = widget.availableItems.where((item) {
                    return item.name.toLowerCase().contains(q) ||
                        item.itemCode.toLowerCase().contains(q);
                  }).toList();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(ItemModel item, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF7F6F3) : Colors.white,
        border: Border.all(color: const Color(0xFFEAEAEA)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedItems.removeWhere((e) => e.id == item.id);
              } else {
                _selectedItems.add(item);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 18,
                    color: isSelected
                        ? const Color(0xFF111111)
                        : const Color(0xFF5C5C63),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.itemCode} • Rp ${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF787774),
                          height: 1.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Package Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.03,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 16),
          _buildField('Package Code', widget.codeCtrl),
          const SizedBox(height: 12),
          _buildField('Package Name', widget.nameCtrl),
          const SizedBox(height: 12),
          _buildPriceField(),
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEAEAEA)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Selected Items',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F6F3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${_selectedItems.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF787774),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _selectedItems.isEmpty
                ? const Center(
                    child: Text(
                      'No items selected',
                      style: TextStyle(fontSize: 14, color: Color(0xFF787774)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _selectedItems.length,
                    itemBuilder: (_, index) {
                      final item = _selectedItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFEAEAEA)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF111111),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.itemCode} • Rp ${item.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF787774),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Color(0xFF787774),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedItems
                                      .removeWhere((e) => e.id == item.id);
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF787774),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder(
                valueListenable: widget.loading,
                builder: (_, isLoading, __) {
                  return FilledButton(
                    onPressed: isLoading ? null : widget.onSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFEAEAEA),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      minimumSize: const Size(80, 40),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.mode == _DialogMode.create
                                ? 'Create'
                                : 'Update',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.06,
            color: Color(0xFF787774),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEAEAEA)),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PRICE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.06,
            color: Color(0xFF787774),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEAEAEA)),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Text(
                'Rp ',
                style: TextStyle(fontSize: 14, color: Color(0xFF787774)),
              ),
              Expanded(
                child: TextField(
                  controller: widget.priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle:
                        TextStyle(fontSize: 14, color: AppColors.textDisabled),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF111111)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Kelas _AddDetailDialog (dipertahankan dari kode sebelumnya)
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
  void didUpdateWidget(covariant _AddDetailDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.filteredInit, widget.filteredInit)) {
      _filtered = List<ItemModel>.from(widget.filteredInit);
    }
    if (oldWidget.selectedItemId != widget.selectedItemId) {
      _selectedId = widget.selectedItemId;
    }
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
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedId = item.id;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Icon(
                                          selected
                                              ? Icons.check_circle_rounded
                                              : Icons.circle_outlined,
                                          size: 18,
                                          color: selected
                                              ? const Color(0xFF111111)
                                              : const Color(0xFF5C5C63),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF111111),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${item.itemCode} • Rp ${item.price.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF787774),
                                                height: 1.4,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              _buildField('QUANTITY', widget.qtyCtrl),
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

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEAEAEA)),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '1',
              hintStyle: TextStyle(fontSize: 14, color: AppColors.textDisabled),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
          ),
        ),
      ],
    );
  }
}

// Kelas ConfirmContent
class ConfirmContent extends StatelessWidget {
  final String message;
  const ConfirmContent({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFFE53935),
          size: 32,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF111111),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
