class ItemModel {
  final String id;
  final String itemCode;
  final String name;
  final String? description;
  final double price;
  final double? costPrice;
  final String? categoryId;
  final String? categoryName;
  final String itemType;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;

  ItemModel({
    required this.id,
    required this.itemCode,
    required this.name,
    this.description,
    required this.price,
    this.costPrice,
    this.categoryId,
    this.categoryName,
    this.itemType = 'Product',
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['ItemID'] as String? ?? json['id'] as String,
      itemCode: json['ItemCode'] as String? ?? json['itemCode'] as String? ?? '',
      name: json['ItemName'] as String? ?? json['name'] as String,
      description: json['Description'] as String? ?? json['description'] as String?,
      price: (json['Price'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0,
      costPrice: (json['CostPrice'] as num?)?.toDouble() ?? (json['costPrice'] as num?)?.toDouble(),
      categoryId: json['CategoryID'] as String? ?? json['categoryId'] as String?,
      categoryName: json['CategoryName'] as String? ?? json['categoryName'] as String?,
      itemType: json['ItemType'] as String? ?? json['itemType'] as String? ?? 'Product',
      imageUrl: json['ImageURL'] as String? ?? json['imageUrl'] as String?,
      isActive: json['IsActive'] as bool? ?? json['isActive'] as bool? ?? true,
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ItemCode': itemCode,
      'ItemName': name,
      'Description': description,
      'Price': price,
      'CostPrice': costPrice,
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
    String? categoryId,
    String? categoryName,
    String? itemType,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      itemCode: itemCode ?? this.itemCode,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      itemType: itemType ?? this.itemType,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
