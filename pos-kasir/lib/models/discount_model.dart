class DiscountModel {
  final String id;
  final String discountName;
  final String discountType;
  final double discountValue;
  final double? minPurchase;
  final double? maxDiscount;
  final bool isActive;

  DiscountModel({
    required this.id,
    required this.discountName,
    required this.discountType,
    required this.discountValue,
    this.minPurchase,
    this.maxDiscount,
    this.isActive = true,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['DiscountID'] ?? json['id'] ?? '',
      discountName: json['DiscountName'] ?? '',
      discountType: json['DiscountType'] ?? 'Nominal',
      discountValue: (json['DiscountValue'] ?? 0).toDouble(),
      minPurchase: json['MinPurchase']?.toDouble(),
      maxDiscount: json['MaxDiscount']?.toDouble(),
      isActive: json['IsActive'] ?? true,
    );
  }

  double calculateDiscount(double subtotal) {
    if (discountType == 'Percentage') {
      double discount = subtotal * (discountValue / 100);
      if (maxDiscount != null && discount > maxDiscount!) {
        discount = maxDiscount!;
      }
      return discount;
    }
    return discountValue;
  }
}
