import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_modal.dart';
import '../../models/item_model.dart';

class PackageModal {
  static Future<Map<String, dynamic>?> create(
    BuildContext context, {
    List<ItemModel> availableItems = const [],
  }) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final searchCtrl = TextEditingController();
    final loading = ValueNotifier(false);
    final selectedItems = <ItemModel>[];
    final itemQuantities = <String, int>{};
    bool isPriceManuallyEdited = false;

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
          itemQuantities: itemQuantities,
          isPriceManuallyEdited: isPriceManuallyEdited,
          onSave: () async {
            final code = codeCtrl.text.trim();
            final name = nameCtrl.text.trim();
            final price = double.tryParse(priceCtrl.text);

            if (code.isEmpty || name.isEmpty || price == null || price <= 0) {
              return;
            }

            loading.value = true;
            await Future.delayed(const Duration(milliseconds: 100));
            loading.value = false;

            // Build package data for API
            final packageData = {
              'ItemCode': code,
              'ItemName': name,
              'Price': price,
              'ItemType': 'Package',
              'IsActive': true,
            };

            // Build package details
            final details = selectedItems.map((item) {
              return {
                'ItemID': item.id,
                'Qty': itemQuantities[item.id] ?? 1,
                'UnitPrice': item.price,
              };
            }).toList();

            if (context.mounted) {
              Navigator.pop(context, {
                'package': packageData,
                'details': details,
                'priceManuallySet': isPriceManuallyEdited,
              });
            }
          },
        );
      },
    );
  }

  static Future<Map<String, dynamic>?> edit(
    BuildContext context,
    ItemModel pkg, {
    List<ItemModel> availableItems = const [],
    List<PackageDetailModel> existingDetails = const [],
  }) {
    final codeCtrl = TextEditingController(text: pkg.itemCode);
    final nameCtrl = TextEditingController(text: pkg.name);
    final priceCtrl = TextEditingController(text: pkg.price.toStringAsFixed(0));
    final searchCtrl = TextEditingController();
    final loading = ValueNotifier(false);
    final selectedItems = <ItemModel>[];
    final itemQuantities = <String, int>{};
    bool isPriceManuallyEdited = false;

    // Load existing package items
    for (var detail in existingDetails) {
      final item = availableItems.firstWhere(
        (e) => e.id == detail.itemId,
        orElse: () => ItemModel(
          id: '',
          itemCode: '',
          name: '',
          price: 0,
          isActive: false,
          createdAt: DateTime.now(),
        ),
      );
      if (item.id.isNotEmpty) {
        selectedItems.add(item);
        itemQuantities[item.id] = detail.qty;
      }
    }

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
          itemQuantities: itemQuantities,
          isPriceManuallyEdited: isPriceManuallyEdited,
          onSave: () async {
            final code = codeCtrl.text.trim();
            final name = nameCtrl.text.trim();
            final price = double.tryParse(priceCtrl.text);

            if (code.isEmpty || name.isEmpty || price == null || price <= 0) {
              return;
            }

            loading.value = true;
            await Future.delayed(const Duration(milliseconds: 100));
            loading.value = false;

            // Build package data for API
            final packageData = {
              'ItemCode': code,
              'ItemName': name,
              'Price': price,
            };

            // Build package details
            final details = selectedItems.map((item) {
              return {
                'ItemID': item.id,
                'Qty': itemQuantities[item.id] ?? 1,
                'UnitPrice': item.price,
              };
            }).toList();

            if (context.mounted) {
              Navigator.pop(context, {
                'package': packageData,
                'details': details,
                'priceManuallySet': isPriceManuallyEdited,
              });
            }
          },
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
          if (context.mounted) {
            Navigator.pop(context, true);
          }
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
          if (context.mounted) {
            Navigator.pop(context, true);
          }
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
  final Map<String, int> itemQuantities;
  final bool isPriceManuallyEdited;
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
    required this.itemQuantities,
    required this.isPriceManuallyEdited,
    required this.onSave,
  });

  @override
  State<_PackageFormDialog> createState() => _PackageFormDialogState();
}

class _PackageFormDialogState extends State<_PackageFormDialog> {
  late List<ItemModel> _filteredItems;
  late List<ItemModel> _selectedItems;
  late Map<String, int> _itemQuantities;
  late bool _isPriceManuallyEdited;
  final _quantityControllers = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.availableItems);
    _selectedItems = List.from(widget.selectedItems);
    _itemQuantities = Map.from(widget.itemQuantities);
    _isPriceManuallyEdited = widget.isPriceManuallyEdited;

    // Initialize quantity controllers for selected items
    for (var item in _selectedItems) {
      _quantityControllers[item.id] = TextEditingController(
        text: (_itemQuantities[item.id] ?? 1).toString(),
      );
    }

    // Calculate initial price if not manually edited
    if (!_isPriceManuallyEdited) {
      _updatePrice();
    }
  }

  @override
  void dispose() {
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double _calculateTotalPrice() {
    double total = 0;
    for (var item in _selectedItems) {
      final qty = _itemQuantities[item.id] ?? 1;
      total += item.price * qty;
    }
    return total;
  }

  void _updatePrice() {
    if (!_isPriceManuallyEdited) {
      final total = _calculateTotalPrice();
      widget.priceCtrl.text = total.toStringAsFixed(0);
    }
  }

  void _updateQuantity(ItemModel item, String value) {
    final qty = int.tryParse(value) ?? 1;
    if (qty <= 0) return;

    setState(() {
      _itemQuantities[item.id] = qty;
      _updatePrice();
    });
  }

  void _toggleItemSelection(ItemModel item) {
    setState(() {
      if (_selectedItems.any((e) => e.id == item.id)) {
        _selectedItems.removeWhere((e) => e.id == item.id);
        _itemQuantities.remove(item.id);
        _quantityControllers.remove(item.id);
      } else {
        _selectedItems.add(item);
        _itemQuantities[item.id] = 1;
        _quantityControllers[item.id] = TextEditingController(text: '1');
      }
      _updatePrice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 700),
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
            'Select items to add to package',
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
          // Info footer
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F6F3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: const Color(0xFF787774)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selected: ${_selectedItems.length} items',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF787774),
                      ),
                    ),
                  ),
                ],
              ),
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
        border: Border.all(
          color: isSelected ? const Color(0xFF111111) : const Color(0xFFEAEAEA),
          width: isSelected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleItemSelection(item),
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
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEAEAEA)),
          const SizedBox(height: 12),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_rounded,
                            size: 48, color: Color(0xFFEAEAEA)),
                        SizedBox(height: 12),
                        Text(
                          'No items selected',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF787774),
                          ),
                        ),
                        Text(
                          'Select items from the left panel',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF787774),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _selectedItems.length,
                    itemBuilder: (_, index) {
                      final item = _selectedItems[index];
                      return _buildSelectedItemCard(item);
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

  Widget _buildSelectedItemCard(ItemModel item) {
    final qtyController = _quantityControllers[item.id] ??
        TextEditingController(text: (_itemQuantities[item.id] ?? 1).toString());

    final subtotal = (item.price * (_itemQuantities[item.id] ?? 1));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEAEAEA)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
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
                      'Rp ${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF787774),
                      ),
                    ),
                  ],
                ),
              ),
              // Quantity input
              SizedBox(
                width: 70,
                child: TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Qty',
                    hintStyle:
                        TextStyle(fontSize: 12, color: Color(0xFF787774)),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    isDense: true,
                  ),
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF111111)),
                  onChanged: (value) => _updateQuantity(item, value),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Color(0xFF787774),
                ),
                onPressed: () {
                  setState(() {
                    _selectedItems.removeWhere((e) => e.id == item.id);
                    _itemQuantities.remove(item.id);
                    _quantityControllers.remove(item.id);
                    _updatePrice();
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          // Subtotal per item
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Subtotal: Rp ${subtotal.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF787774),
                fontWeight: FontWeight.w500,
              ),
            ),
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
    final totalPrice = _calculateTotalPrice();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            // Manual edit toggle
            Row(
              children: [
                const Text(
                  'Auto',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF787774),
                  ),
                ),
                const SizedBox(width: 4),
                Switch(
                  value: _isPriceManuallyEdited,
                  onChanged: (value) {
                    setState(() {
                      _isPriceManuallyEdited = value;
                      if (!value) {
                        // Switch to auto: recalculate
                        final total = _calculateTotalPrice();
                        widget.priceCtrl.text = total.toStringAsFixed(0);
                      }
                    });
                  },
                  activeTrackColor: const Color(0xFF111111),
                  inactiveTrackColor: const Color(0xFFEAEAEA),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Text(
                  'Manual',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF787774),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _isPriceManuallyEdited
                  ? const Color(0xFF111111)
                  : const Color(0xFFEAEAEA),
              width: _isPriceManuallyEdited ? 1.5 : 1,
            ),
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
                  enabled: _isPriceManuallyEdited,
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
                  style: TextStyle(
                    fontSize: 14,
                    color: _isPriceManuallyEdited
                        ? const Color(0xFF111111)
                        : const Color(0xFF787774),
                  ),
                  onChanged: (_) {
                    // Mark as manually edited when user types
                    if (_isPriceManuallyEdited) {
                      // Keep manual mode
                    }
                  },
                ),
              ),
              if (!_isPriceManuallyEdited)
                const Icon(
                  Icons.lock_rounded,
                  size: 16,
                  color: Color(0xFF787774),
                ),
            ],
          ),
        ),
        if (!_isPriceManuallyEdited && _selectedItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Auto-calculated from ${_selectedItems.length} item${_selectedItems.length > 1 ? 's' : ''}: Rp ${totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF787774),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (_isPriceManuallyEdited && _selectedItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Manual override. Auto price: Rp ${totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF787774),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (_selectedItems.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Add items to auto-calculate price',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF787774),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

// Package Detail Model
class PackageDetailModel {
  final String id;
  final String packageItemId;
  final String itemId;
  final String? itemName;
  final int qty;
  final double unitPrice;

  PackageDetailModel({
    required this.id,
    required this.packageItemId,
    required this.itemId,
    this.itemName,
    required this.qty,
    required this.unitPrice,
  });

  factory PackageDetailModel.fromJson(Map<String, dynamic> json) {
    return PackageDetailModel(
      id: json['PackageDetailID'] ?? '',
      packageItemId: json['PackageItemID'] ?? '',
      itemId: json['ItemID'] ?? '',
      itemName: json['ItemName'],
      qty: json['Qty'] ?? 0,
      unitPrice: (json['UnitPrice'] ?? 0).toDouble(),
    );
  }
}

// Helper widget untuk confirm content
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
