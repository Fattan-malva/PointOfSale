class ModifierModel {
  final String id;
  final String name;
  final bool isRequired;
  final int? maxSelect;
  final bool isActive;
  final DateTime createdAt;
  final List<ModifierOptionModel> options;

  ModifierModel({
    required this.id,
    required this.name,
    this.isRequired = false,
    this.maxSelect,
    this.isActive = true,
    required this.createdAt,
    this.options = const [],
  });

  factory ModifierModel.fromJson(Map<String, dynamic> json) {
    return ModifierModel(
      id: json['ModifierID'] as String? ?? json['id'] as String,
      name: json['ModifierName'] as String? ?? json['name'] as String,
      isRequired: json['IsRequired'] as bool? ?? json['isRequired'] as bool? ?? false,
      maxSelect: (json['MaxSelect'] as num?)?.toInt() ?? (json['maxSelect'] as num?)?.toInt(),
      isActive: json['IsActive'] as bool? ?? json['isActive'] as bool? ?? true,
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      options: (json['Options'] as List<dynamic>?)
              ?.map((e) => ModifierOptionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ModifierName': name,
      'IsRequired': isRequired,
      'MaxSelect': maxSelect,
      'IsActive': isActive,
    };
  }

  ModifierModel copyWith({
    String? id,
    String? name,
    bool? isRequired,
    int? maxSelect,
    bool? isActive,
    DateTime? createdAt,
    List<ModifierOptionModel>? options,
  }) {
    return ModifierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isRequired: isRequired ?? this.isRequired,
      maxSelect: maxSelect ?? this.maxSelect,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      options: options ?? this.options,
    );
  }
}

class ModifierOptionModel {
  final String id;
  final String modifierId;
  final String name;
  final double? additionalPrice;
  final int? sortOrder;
  final bool isActive;

  ModifierOptionModel({
    required this.id,
    required this.modifierId,
    required this.name,
    this.additionalPrice,
    this.sortOrder,
    this.isActive = true,
  });

  factory ModifierOptionModel.fromJson(Map<String, dynamic> json) {
    return ModifierOptionModel(
      id: (json['ModifierOptionID'] as String?) ?? (json['id'] as String?) ?? '',
      modifierId: (json['ModifierID'] as String?) ?? (json['modifierId'] as String?) ?? '',
      name: json['OptionName'] as String? ?? json['name'] as String,
      additionalPrice: (json['AdditionalPrice'] as num?)?.toDouble() ?? (json['additionalPrice'] as num?)?.toDouble(),
      sortOrder: (json['SortOrder'] as num?)?.toInt() ?? (json['sortOrder'] as num?)?.toInt(),
      isActive: json['IsActive'] as bool? ?? json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ModifierID': modifierId,
      'OptionName': name,
      'AdditionalPrice': additionalPrice,
      'SortOrder': sortOrder,
      'IsActive': isActive,
    };
  }
}

class PackageDetailModel {
  final String id;
  final String packageItemId;
  final String itemId;
  final String? itemName;
  final int qty;

  PackageDetailModel({
    required this.id,
    required this.packageItemId,
    required this.itemId,
    this.itemName,
    required this.qty,
  });

  factory PackageDetailModel.fromJson(Map<String, dynamic> json) {
    return PackageDetailModel(
      id: (json['PackageItemID'] as String?) ?? (json['PackageDetailID'] as String?) ?? (json['id'] as String?) ?? '',
      packageItemId: (json['PackageItemID'] as String?) ?? (json['packageItemId'] as String?) ?? '',
      itemId: (json['ItemID'] as String?) ?? (json['itemId'] as String?) ?? '',
      itemName: json['ItemName'] as String? ?? json['itemName'] as String?,
      qty: (json['Qty'] as num?)?.toInt() ?? (json['qty'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ItemID': itemId,
      'Qty': qty,
    };
  }
}
