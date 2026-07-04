class OrderModel {
  final String id;
  final String? orderNumber;
  final String? tableNumber;
  final String status;
  final String? branchId;
  final String? branchName;
  final String? cashierId;
  final String? cashierName;
  final double total;
  final String? paymentMethod;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    this.orderNumber,
    this.tableNumber,
    required this.status,
    this.branchId,
    this.branchName,
    this.cashierId,
    this.cashierName,
    this.total = 0,
    this.paymentMethod,
    required this.createdAt,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['OrderID'] as String? ?? json['id'] as String,
      orderNumber: json['OrderNumber'] as String? ?? json['orderNumber'] as String?,
      tableNumber: json['TableNumber'] as String? ?? json['tableNumber'] as String?,
      status: json['Status'] as String? ?? json['status'] as String? ?? 'pending',
      branchId: json['BranchID'] as String? ?? json['branchId'] as String?,
      branchName: json['BranchName'] as String? ?? json['branchName'] as String?,
      cashierId: json['CashierID'] as String? ?? json['cashierId'] as String?,
      cashierName: json['CashierName'] as String? ?? json['cashierName'] as String?,
      total: (json['Total'] as num?)?.toDouble() ?? (json['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['PaymentMethod'] as String? ?? json['paymentMethod'] as String?,
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      items: (json['Items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? tableNumber,
    String? status,
    String? branchId,
    String? branchName,
    String? cashierId,
    String? cashierName,
    double? total,
    String? paymentMethod,
    DateTime? createdAt,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}

class OrderItemModel {
  final String id;
  final String? itemId;
  final String? itemName;
  final int quantity;
  final double price;
  final double subtotal;

  OrderItemModel({
    required this.id,
    this.itemId,
    this.itemName,
    this.quantity = 1,
    this.price = 0,
    this.subtotal = 0,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['OrderItemID'] as String? ?? json['id'] as String,
      itemId: json['ItemID'] as String? ?? json['itemId'] as String?,
      itemName: json['ItemName'] as String? ?? json['itemName'] as String?,
      quantity: (json['Quantity'] as num?)?.toInt() ?? (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['Price'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0,
      subtotal: (json['Subtotal'] as num?)?.toDouble() ?? (json['subtotal'] as num?)?.toDouble() ?? 0,
    );
  }
}
