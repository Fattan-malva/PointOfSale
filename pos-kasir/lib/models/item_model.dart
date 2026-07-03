import 'modifier_model.dart';

class ItemModel {
  final String id;
  final String? categoryId;
  final String itemCode;
  final String itemName;
  final String? description;
  final double price;
  final double? costPrice;
  final String itemType;
  final bool isActive;
  final String? categoryName;
  final List<ItemMediaModel> media;

  ItemModel({
    required this.id,
    this.categoryId,
    required this.itemCode,
    required this.itemName,
    this.description,
    required this.price,
    this.costPrice,
    this.itemType = 'Product',
    this.isActive = true,
    this.categoryName,
    this.media = const [],
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['ItemID'] ?? json['id'] ?? '',
      categoryId: json['CategoryID'],
      itemCode: json['ItemCode'] ?? '',
      itemName: json['ItemName'] ?? '',
      description: json['Description'],
      price: (json['Price'] ?? 0).toDouble(),
      costPrice: json['CostPrice']?.toDouble(),
      itemType: json['ItemType'] ?? 'Product',
      isActive: json['IsActive'] ?? true,
      categoryName: json['CategoryName'],
      media:
          (json['Media'] as List<dynamic>?)
              ?.map((m) => ItemMediaModel.fromJson(m))
              .toList() ??
          [],
    );
  }

  List<ModifierModel> get modifiers => [];

  String? get imageUrl {
    if (media.isNotEmpty) {
      return media.first.url;
    }
    return null;
  }
}

class ItemMediaModel {
  final String id;
  final String url;
  final int sortOrder;

  ItemMediaModel({required this.id, required this.url, this.sortOrder = 0});

  factory ItemMediaModel.fromJson(Map<String, dynamic> json) {
    return ItemMediaModel(
      id: json['MediaID'] ?? json['id'] ?? '',
      url: json['Url'] ?? json['url'] ?? '',
      sortOrder: json['SortOrder'] ?? 0,
    );
  }
}
