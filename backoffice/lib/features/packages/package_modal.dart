import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_modal.dart';
import '../../models/item_model.dart';
import '../../models/tax_model.dart';
import '../../models/discount_model.dart';
import '../../models/package_detail_model.dart';

class PackageModal {
  static Future<Map<String, dynamic>?> create(
    BuildContext context, {
    List<ItemModel> availableItems = const [],
    List<TaxModel> allTaxes = const [],
    List<DiscountModel> allDiscounts = const [],
  }) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final searchCtrl = TextEditingController();
    final loading = ValueNotifier(false);
    final selectedItems = <ItemModel>[];
    final itemQuantities = <String, int>{};

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
          allTaxes: allTaxes,
          allDiscounts: allDiscounts,
          selectedTaxIds: const {},
          selectedDiscountIds: const {},
          onSave: (result) async {
            loading.value = true;
            await Future.delayed(const Duration(milliseconds: 100));
            loading.value = false;
            if (context.mounted) {
              Navigator.pop(context, result);
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
    List<TaxModel> allTaxes = const [],
    List<DiscountModel> allDiscounts = const [],
  }) {
    final codeCtrl = TextEditingController(text: pkg.itemCode);
    final nameCtrl = TextEditingController(text: pkg.name);
    final priceCtrl = TextEditingController(text: pkg.price.toStringAsFixed(0));
    final searchCtrl = TextEditingController();
    final loading = ValueNotifier(false);
    final selectedItems = <ItemModel>[];
    final itemQuantities = <String, int>{};

    print('=== EDIT PACKAGE MODAL ===');
    print('Existing Details count: ${existingDetails.length}');
    for (var detail in existingDetails) {
      print(
          'Detail - ItemID: ${detail.itemId}, Qty: ${detail.qty}, UnitPrice: ${detail.unitPrice}');
    }

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
        print('Item found: ${item.name} (${item.id}) - Qty: ${detail.qty}');
      } else {
        print('Item not found: ${detail.itemId}');
        // Try case-insensitive match
        final altItem = availableItems.firstWhere(
          (e) => e.id.toLowerCase() == detail.itemId.toLowerCase(),
          orElse: () => ItemModel(
            id: '',
            itemCode: '',
            name: '',
            price: 0,
            isActive: false,
            createdAt: DateTime.now(),
          ),
        );
        if (altItem.id.isNotEmpty) {
          selectedItems.add(altItem);
          itemQuantities[altItem.id] = detail.qty;
          print('Item found with case-insensitive: ${altItem.name}');
        }
      }
    }

    print('Selected Items count: ${selectedItems.length}');

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
          allTaxes: allTaxes,
          allDiscounts: allDiscounts,
          selectedTaxIds: pkg.taxes.map((t) => t.id).toSet(),
          selectedDiscountIds: pkg.discounts.map((d) => d.id).toSet(),
          onSave: (result) async {
            loading.value = true;
            await Future.delayed(const Duration(milliseconds: 100));
            loading.value = false;
            if (context.mounted) {
              Navigator.pop(context, result);
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
  final List<TaxModel> allTaxes;
  final List<DiscountModel> allDiscounts;
  final Set<String> selectedTaxIds;
  final Set<String> selectedDiscountIds;
  final ValueChanged<Map<String, dynamic>> onSave;

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
    required this.allTaxes,
    required this.allDiscounts,
    required this.selectedTaxIds,
    required this.selectedDiscountIds,
    required this.onSave,
  });

  @override
  State<_PackageFormDialog> createState() => _PackageFormDialogState();
}

class _PackageFormDialogState extends State<_PackageFormDialog> {
  late List<ItemModel> _filteredItems;
  late List<ItemModel> _selectedItems;
  late Map<String, int> _itemQuantities;
  late Set<String> _taxIds;
  late Set<String> _discountIds;
  bool _isPriceManuallyEdited = false;
  final _quantityControllers = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.availableItems);
    _selectedItems = List.from(widget.selectedItems);
    _itemQuantities = Map.from(widget.itemQuantities);
    _taxIds = Set.from(widget.selectedTaxIds);
    _discountIds = Set.from(widget.selectedDiscountIds);

    print('=== PACKAGE FORM DIALOG INIT ===');
    print('Mode: ${widget.mode}');
    print('Selected Items: ${_selectedItems.length}');

    // Initialize quantity controllers for selected items
    for (var item in _selectedItems) {
      _quantityControllers[item.id] = TextEditingController(
        text: (_itemQuantities[item.id] ?? 1).toString(),
      );
      print('Item: ${item.name} - Qty: ${_itemQuantities[item.id] ?? 1}');
    }

    // In edit mode, check if price is manually edited
    if (widget.mode == _DialogMode.edit) {
      final existing = double.tryParse(widget.priceCtrl.text) ?? 0;
      _isPriceManuallyEdited = (existing - _calculateSubtotal()).abs() > 0.01;
    }

    _updatePrice();
  }

  @override
  void dispose() {
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double _calculateSubtotal() {
    double total = 0;
    for (var item in _selectedItems) {
      final qty = _itemQuantities[item.id] ?? 1;
      total += item.price * qty;
    }
    return total;
  }

  double _packagePrice() => double.tryParse(widget.priceCtrl.text) ?? 0;

  _Breakdown _breakdown() {
    final double subtotalPrice = _calculateSubtotal();
    final double packagePrice = _packagePrice();

    double discountAmount = 0;
    for (final d
        in widget.allDiscounts.where((d) => _discountIds.contains(d.id))) {
      double value;
      if (d.discountType == 'Percentage') {
        value = packagePrice * d.discountValue / 100;
        if (d.maxDiscount != null && value > d.maxDiscount!) {
          value = d.maxDiscount!;
        }
      } else {
        value = d.discountValue;
      }
      discountAmount += value;
    }
    if (discountAmount > packagePrice) discountAmount = packagePrice;

    final double taxable = packagePrice - discountAmount;
    double taxAmount = 0;
    for (final t in widget.allTaxes.where((t) => _taxIds.contains(t.id))) {
      taxAmount += taxable * t.rate / 100;
    }

    final double finalPrice = packagePrice - discountAmount + taxAmount;

    return _Breakdown(
      subtotalPrice: subtotalPrice,
      packagePrice: packagePrice,
      discountAmount: discountAmount,
      taxAmount: taxAmount,
      finalPrice: finalPrice,
    );
  }

  void _updatePrice() {
    if (!_isPriceManuallyEdited) {
      final total = _calculateSubtotal();
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

  void _handleSave() {
    final code = widget.codeCtrl.text.trim();
    final name = widget.nameCtrl.text.trim();
    final price = double.tryParse(widget.priceCtrl.text);

    if (code.isEmpty || name.isEmpty || price == null || price <= 0) {
      return;
    }

    final b = _breakdown();

    final packageData = <String, dynamic>{
      'ItemCode': code,
      'ItemName': name,
      'Price': price,
      'ItemType': 'Package',
      'IsActive': true,
      'SubtotalPrice': b.subtotalPrice,
      'DiscountAmount': b.discountAmount,
      'TaxAmount': b.taxAmount,
      'FinalPrice': b.finalPrice,
    };

    final details = _selectedItems.map((item) {
      return {
        'ItemID': item.id,
        'Qty': _itemQuantities[item.id] ?? 1,
        'UnitPrice': item.price,
      };
    }).toList();

    widget.onSave({
      'package': packageData,
      'Items': details,
      'details': details,
      'taxIds': _taxIds.toList(),
      'discountIds': _discountIds.toList(),
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
            Expanded(
              flex: 1,
              child: _buildLeftPanel(),
            ),
            const VerticalDivider(
                width: 1, thickness: 1, color: Color(0xFFEAEAEA)),
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
          Expanded(
            child: SingleChildScrollView(
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
                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFEAEAEA)),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
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
                  _selectedItems.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
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
                          ),
                        )
                      : Column(
                          children: [
                            for (final item in _selectedItems)
                              _buildSelectedItemCard(item),
                          ],
                        ),
                  if (widget.allTaxes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildCheckboxGroup(
                      label: 'Taxes',
                      items: widget.allTaxes
                          .map(
                              (t) => _CheckItem(t.id, '${t.name} (${t.rate}%)'))
                          .toList(),
                      selected: _taxIds,
                    ),
                  ],
                  if (widget.allDiscounts.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildCheckboxGroup(
                      label: 'Discounts',
                      items: widget.allDiscounts
                          .map((d) => _CheckItem(
                                d.id,
                                d.discountType == 'Percentage'
                                    ? '${d.name} (${d.discountValue}%)'
                                    : '${d.name} (Rp ${d.discountValue.toStringAsFixed(0)})',
                              ))
                          .toList(),
                      selected: _discountIds,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildPriceSummary(),
                ],
              ),
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
                    onPressed: isLoading ? null : _handleSave,
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
    final subtotal = _calculateSubtotal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PACKAGE PRICE',
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
                  onChanged: (_) {
                    setState(() => _isPriceManuallyEdited = true);
                  },
                ),
              ),
              if (_isPriceManuallyEdited)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPriceManuallyEdited = false;
                      widget.priceCtrl.text =
                          _calculateSubtotal().toStringAsFixed(0);
                    });
                  },
                  child: const Tooltip(
                    message: 'Reset ke harga otomatis',
                    child: Icon(Icons.refresh_rounded,
                        size: 16, color: Color(0xFF787774)),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _selectedItems.isEmpty
                ? 'Otomatis terhitung dari subtotal item yang dipilih'
                : _isPriceManuallyEdited
                    ? 'Harga manual. Subtotal item: Rp ${subtotal.toStringAsFixed(0)}'
                    : 'Otomatis dari ${_selectedItems.length} item: Rp ${subtotal.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF787774),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxGroup({
    required String label,
    required List<_CheckItem> items,
    required Set<String> selected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.06,
                color: Color(0xFF787774))),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: items.map((item) {
            final checked = selected.contains(item.id);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (checked) {
                    selected.remove(item.id);
                  } else {
                    selected.add(item.id);
                  }
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: checked ? const Color(0xFFF7F6F3) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: checked
                        ? const Color(0xFF111111)
                        : const Color(0xFFEAEAEA),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      checked
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 16,
                      color: const Color(0xFF111111),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: checked ? FontWeight.w500 : FontWeight.w400,
                        color: checked
                            ? const Color(0xFF111111)
                            : const Color(0xFF5C5C63),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    final b = _breakdown();
    String rp(double v) => 'Rp ${v.toStringAsFixed(0)}';

    Widget row(String label, String value, {bool bold = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: bold ? 14 : 13,
                    fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                    color: const Color(0xFF5C5C63))),
            Text(value,
                style: TextStyle(
                    fontSize: bold ? 14 : 13,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                    color: const Color(0xFF111111))),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PRICE SUMMARY',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.06,
                color: Color(0xFF787774))),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F6F3),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Column(
            children: [
              row('Items Subtotal', rp(b.subtotalPrice)),
              row('Package Price', rp(b.packagePrice)),
              row('Discount', '- ${rp(b.discountAmount)}'),
              row('Tax', '+ ${rp(b.taxAmount)}'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, color: Color(0xFFEAEAEA)),
              ),
              row('Final Price', rp(b.finalPrice), bold: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckItem {
  final String id;
  final String label;
  const _CheckItem(this.id, this.label);
}

class _Breakdown {
  final double subtotalPrice;
  final double packagePrice;
  final double discountAmount;
  final double taxAmount;
  final double finalPrice;

  const _Breakdown({
    required this.subtotalPrice,
    required this.packagePrice,
    required this.discountAmount,
    required this.taxAmount,
    required this.finalPrice,
  });
}

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
