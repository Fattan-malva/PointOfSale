class ItemModel {
  final String id;
  final String itemCode;
  final String name;
  final String? description;
  final double price;
  final double? costPrice;

  // 1. Subtotal Price - Harga dari semua item sebelum diskon & tax
  //    = SUM(Qty x UnitPrice)
  final double subtotalPrice;

  // 2. Discount Amount - Potongan harga
  final double discountAmount;

  // 3. Tax Amount - Pajak yang berlaku
  final double taxAmount;

  // 4. Final Price - Harga akhir yang dibayar
  //    = Subtotal Price - Discount + Tax
  final double finalPrice;

  final String? categoryId;
  final String? categoryName;
  final String itemType;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final List<ItemTaxInfo> taxes;
  final List<ItemDiscountInfo> discounts;
  final List<ItemBranchInfo> branches;

  ItemModel({
    required this.id,
    required this.itemCode,
    required this.name,
    this.description,
    required this.price,
    this.costPrice,
    this.subtotalPrice = 0,
    this.discountAmount = 0,
    this.taxAmount = 0,
    this.finalPrice = 0,
    this.categoryId,
    this.categoryName,
    this.itemType = 'Product',
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    this.taxes = const [],
    this.discounts = const [],
    this.branches = const [],
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['ItemID'] as String? ?? json['id'] as String,
      itemCode:
          json['ItemCode'] as String? ?? json['itemCode'] as String? ?? '',
      name: json['ItemName'] as String? ?? json['name'] as String,
      description:
          json['Description'] as String? ?? json['description'] as String?,
      price: (json['Price'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          0,
      costPrice: (json['CostPrice'] as num?)?.toDouble() ??
          (json['costPrice'] as num?)?.toDouble(),
      subtotalPrice: (json['SubtotalPrice'] as num?)?.toDouble() ??
          (json['subtotalPrice'] as num?)?.toDouble() ??
          0,
      discountAmount: (json['DiscountAmount'] as num?)?.toDouble() ??
          (json['discountAmount'] as num?)?.toDouble() ??
          0,
      taxAmount: (json['TaxAmount'] as num?)?.toDouble() ??
          (json['taxAmount'] as num?)?.toDouble() ??
          0,
      finalPrice: (json['FinalPrice'] as num?)?.toDouble() ??
          (json['finalPrice'] as num?)?.toDouble() ??
          0,
      categoryId:
          json['CategoryID'] as String? ?? json['categoryId'] as String?,
      categoryName:
          json['CategoryName'] as String? ?? json['categoryName'] as String?,
      itemType: json['ItemType'] as String? ??
          json['itemType'] as String? ??
          'Product',
      imageUrl: json['ImageURL'] as String? ?? json['imageUrl'] as String?,
      isActive: json['IsActive'] as bool? ?? json['isActive'] as bool? ?? true,
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      taxes: (json['Taxes'] as List<dynamic>?)
              ?.map((e) => ItemTaxInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      discounts: (json['Discounts'] as List<dynamic>?)
              ?.map((e) => ItemDiscountInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      branches: (json['Branches'] as List<dynamic>?)
              ?.map((e) => ItemBranchInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  List<String> get taxIds => taxes.map((t) => t.id).toList();
  List<String> get discountIds => discounts.map((d) => d.id).toList();
  List<String> get branchIds => branches.map((b) => b.branchId).toList();

  Map<String, dynamic> toJson() {
    return {
      'ItemCode': itemCode,
      'ItemName': name,
      'Description': description,
      'Price': price,
      'CostPrice': costPrice,
      'SubtotalPrice': subtotalPrice,
      'DiscountAmount': discountAmount,
      'TaxAmount': taxAmount,
      'FinalPrice': finalPrice,
      'CategoryID': categoryId,
      'ItemType': itemType,
      'ImageURL': imageUrl,
      'IsActive': isActive,
    };
  }

  ItemModel copyWith({
    String? id,
    String? itemCode,
    String? name,
    String? description,
    double? price,
    double? costPrice,
    double? subtotalPrice,
    double? discountAmount,
    double? taxAmount,
    double? finalPrice,
    String? categoryId,
    String? categoryName,
    String? itemType,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    List<ItemTaxInfo>? taxes,
    List<ItemDiscountInfo>? discounts,
    List<ItemBranchInfo>? branches,
  }) {
    return ItemModel(
      id: id ?? this.id,
      itemCode: itemCode ?? this.itemCode,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      subtotalPrice: subtotalPrice ?? this.subtotalPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      finalPrice: finalPrice ?? this.finalPrice,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      itemType: itemType ?? this.itemType,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      taxes: taxes ?? this.taxes,
      discounts: discounts ?? this.discounts,
      branches: branches ?? this.branches,
    );
  }
}

class ItemTaxInfo {
  final String id;
  final String name;
  final double rate;

  ItemTaxInfo({
    required this.id,
    required this.name,
    required this.rate,
  });

  factory ItemTaxInfo.fromJson(Map<String, dynamic> json) {
    return ItemTaxInfo(
      id: (json['TaxID'] as String?) ?? '',
      name: (json['TaxName'] as String?) ?? '',
      rate: (json['TaxRate'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ItemBranchInfo {
  final String branchId;
  final String branchCode;
  final String branchName;
  final bool isActive;
  final bool isAvailable;

  ItemBranchInfo({
    required this.branchId,
    required this.branchCode,
    required this.branchName,
    required this.isActive,
    required this.isAvailable,
  });

  factory ItemBranchInfo.fromJson(Map<String, dynamic> json) {
    return ItemBranchInfo(
      branchId: json['BranchID'] as String,
      branchCode: json['BranchCode'] as String,
      branchName: json['BranchName'] as String,
      isActive: (json['IsActive'] as bool?) ?? false,
      isAvailable: (json['IsAvailable'] as bool?) ?? true,
    );
  }
}

class ItemDiscountInfo {
  final String id;
  final String name;
  final String discountType;
  final double discountValue;

  ItemDiscountInfo({
    required this.id,
    required this.name,
    required this.discountType,
    required this.discountValue,
  });

  factory ItemDiscountInfo.fromJson(Map<String, dynamic> json) {
    return ItemDiscountInfo(
      id: (json['DiscountID'] as String?) ?? '',
      name: (json['DiscountName'] as String?) ?? '',
      discountType: (json['DiscountType'] as String?) ?? 'Percentage',
      discountValue: (json['DiscountValue'] as num?)?.toDouble() ?? 0,
    );
  }
}
