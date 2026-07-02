class OrderModel {
  final String id;
  final String branchId;
  final String userId;
  final String? customerId;
  final String? tableId;
  final String orderType;
  final String status;
  final String paymentStatus;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String? note;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final List<OrderDetailModel> details;
  final List<OrderDiscountModel> discounts;

  OrderModel({
    required this.id,
    required this.branchId,
    required this.userId,
    this.customerId,
    this.tableId,
    required this.orderType,
    required this.status,
    required this.paymentStatus,
    this.subtotal = 0,
    this.taxAmount = 0,
    this.discountAmount = 0,
    this.totalAmount = 0,
    this.note,
    required this.createdAt,
    this.confirmedAt,
    this.completedAt,
    this.details = const [],
    this.discounts = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['OrderID'] ?? json['id'] ?? '',
      branchId: json['BranchID'] ?? '',
      userId: json['UserID'] ?? '',
      customerId: json['CustomerID'],
      tableId: json['TableID'],
      orderType: json['OrderType'] ?? 'DineIn',
      status: json['Status'] ?? 'Draft',
      paymentStatus: json['PaymentStatus'] ?? 'Unpaid',
      subtotal: (json['Subtotal'] ?? 0).toDouble(),
      taxAmount: (json['TaxAmount'] ?? 0).toDouble(),
      discountAmount: (json['DiscountAmount'] ?? 0).toDouble(),
      totalAmount: (json['TotalAmount'] ?? 0).toDouble(),
      note: json['Note'],
      createdAt: DateTime.parse(
        json['CreatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      confirmedAt: json['ConfirmedAt'] != null
          ? DateTime.parse(json['ConfirmedAt'])
          : null,
      completedAt: json['CompletedAt'] != null
          ? DateTime.parse(json['CompletedAt'])
          : null,
      details:
          (json['Details'] as List<dynamic>?)
              ?.map((d) => OrderDetailModel.fromJson(d))
              .toList() ??
          [],
      discounts:
          (json['Discounts'] as List<dynamic>?)
              ?.map((d) => OrderDiscountModel.fromJson(d))
              .toList() ??
          [],
    );
  }

  int get itemCount => details.fold(0, (sum, d) => sum + d.qty);
}

class OrderDetailModel {
  final String id;
  final String orderId;
  final String itemId;
  final String itemName;
  final String? itemCode;
  final int qty;
  final double price;
  final double subtotal;
  final String? note;
  final List<OrderModifierModel> modifiers;

  OrderDetailModel({
    required this.id,
    required this.orderId,
    required this.itemId,
    required this.itemName,
    this.itemCode,
    required this.qty,
    required this.price,
    required this.subtotal,
    this.note,
    this.modifiers = const [],
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['OrderDetailID'] ?? json['id'] ?? '',
      orderId: json['OrderID'] ?? '',
      itemId: json['ItemID'] ?? '',
      itemName: json['ItemName'] ?? '',
      itemCode: json['ItemCode'],
      qty: json['Qty'] ?? 0,
      price: (json['Price'] ?? 0).toDouble(),
      subtotal: (json['Subtotal'] ?? 0).toDouble(),
      note: json['Note'],
      modifiers:
          (json['Modifiers'] as List<dynamic>?)
              ?.map((m) => OrderModifierModel.fromJson(m))
              .toList() ??
          [],
    );
  }
}

class OrderModifierModel {
  final String id;
  final String orderDetailId;
  final String? modifierId;
  final String? modifierOptionId;
  final String optionName;
  final double additionalPrice;

  OrderModifierModel({
    required this.id,
    required this.orderDetailId,
    this.modifierId,
    this.modifierOptionId,
    required this.optionName,
    this.additionalPrice = 0,
  });

  factory OrderModifierModel.fromJson(Map<String, dynamic> json) {
    return OrderModifierModel(
      id: json['OrderModifierID'] ?? json['id'] ?? '',
      orderDetailId: json['OrderDetailID'] ?? '',
      modifierId: json['ModifierID'],
      modifierOptionId: json['ModifierOptionID'],
      optionName: json['OptionName'] ?? '',
      additionalPrice: (json['AdditionalPrice'] ?? 0).toDouble(),
    );
  }
}

class OrderDiscountModel {
  final String id;
  final String orderId;
  final String? discountId;
  final String discountName;
  final String discountType;
  final double discountValue;
  final double discountAmount;

  OrderDiscountModel({
    required this.id,
    required this.orderId,
    this.discountId,
    required this.discountName,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
  });

  factory OrderDiscountModel.fromJson(Map<String, dynamic> json) {
    return OrderDiscountModel(
      id: json['OrderDiscountID'] ?? json['id'] ?? '',
      orderId: json['OrderID'] ?? '',
      discountId: json['DiscountID'],
      discountName: json['DiscountName'] ?? '',
      discountType: json['DiscountType'] ?? 'Nominal',
      discountValue: (json['DiscountValue'] ?? 0).toDouble(),
      discountAmount: (json['DiscountAmount'] ?? 0).toDouble(),
    );
  }
}
