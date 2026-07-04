class DiscountModel {
  final String id;
  final String name;
  final String discountType;
  final double discountValue;
  final double? minPurchase;
  final double? maxDiscount;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;

  DiscountModel({
    required this.id,
    required this.name,
    required this.discountType,
    required this.discountValue,
    this.minPurchase,
    this.maxDiscount,
    this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['DiscountID'] as String? ?? json['id'] as String,
      name: json['DiscountName'] as String? ?? json['name'] as String,
      discountType: json['DiscountType'] as String? ?? json['discountType'] as String? ?? 'Percentage',
      discountValue: (json['DiscountValue'] as num?)?.toDouble() ?? (json['discountValue'] as num?)?.toDouble() ?? 0,
      minPurchase: (json['MinPurchase'] as num?)?.toDouble() ?? (json['minPurchase'] as num?)?.toDouble(),
      maxDiscount: (json['MaxDiscount'] as num?)?.toDouble() ?? (json['maxDiscount'] as num?)?.toDouble(),
      startDate: json['StartDate'] != null ? DateTime.parse(json['StartDate'] as String) : json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
      endDate: json['EndDate'] != null ? DateTime.parse(json['EndDate'] as String) : json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
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
      'DiscountName': name,
      'DiscountType': discountType,
      'DiscountValue': discountValue,
      'MinPurchase': minPurchase,
      'MaxDiscount': maxDiscount,
      'StartDate': startDate?.toIso8601String(),
      'EndDate': endDate?.toIso8601String(),
      'IsActive': isActive,
    };
  }

  DiscountModel copyWith({
    String? id,
    String? name,
    String? discountType,
    double? discountValue,
    double? minPurchase,
    double? maxDiscount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return DiscountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minPurchase: minPurchase ?? this.minPurchase,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
