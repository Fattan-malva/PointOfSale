// package_detail_model.dart
class PackageDetailModel {
  final String id;
  final String packageItemId;
  final String itemId;
  final String? itemName;
  final int qty;
  final double unitPrice;
  final double subtotal;

  PackageDetailModel({
    required this.id,
    required this.packageItemId,
    required this.itemId,
    this.itemName,
    required this.qty,
    required this.unitPrice,
  }) : subtotal = qty * unitPrice;

  factory PackageDetailModel.fromJson(Map<String, dynamic> json) {
    // Support multiple key formats from backend
    final id = json['PackageDetailID'] ?? json['id'] ?? '';
    final packageItemId = json['PackageItemID'] ?? json['packageItemId'] ?? '';
    final itemId = json['ItemID'] ?? json['itemId'] ?? json['ItemId'] ?? '';
    final itemName = json['ItemName'] ?? json['itemName'];
    final qty = (json['Qty'] ?? json['qty'] ?? json['Quantity'] ?? 0).toInt();
    final unitPrice = (json['UnitPrice'] ?? json['unitPrice'] ?? 0).toDouble();

    return PackageDetailModel(
      id: id,
      packageItemId: packageItemId,
      itemId: itemId,
      itemName: itemName,
      qty: qty,
      unitPrice: unitPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PackageDetailID': id,
      'PackageItemID': packageItemId,
      'ItemID': itemId,
      'ItemName': itemName,
      'Qty': qty,
      'UnitPrice': unitPrice,
    };
  }

  PackageDetailModel copyWith({
    String? id,
    String? packageItemId,
    String? itemId,
    String? itemName,
    int? qty,
    double? unitPrice,
  }) {
    return PackageDetailModel(
      id: id ?? this.id,
      packageItemId: packageItemId ?? this.packageItemId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
