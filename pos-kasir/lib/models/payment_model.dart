class PaymentModel {
  final String id;
  final String orderId;
  final String paymentMethodId;
  final String? paymentMethodName;
  final double paymentAmount;
  final String? referenceNumber;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.paymentMethodId,
    this.paymentMethodName,
    required this.paymentAmount,
    this.referenceNumber,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['PaymentID'] ?? json['id'] ?? '',
      orderId: json['OrderID'] ?? '',
      paymentMethodId: json['PaymentMethodID'] ?? '',
      paymentMethodName: json['PaymentMethodName'],
      paymentAmount: (json['PaymentAmount'] ?? 0).toDouble(),
      referenceNumber: json['ReferenceNumber'],
      createdAt: DateTime.parse(
        json['CreatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class PaymentMethodModel {
  final String id;
  final String methodName;
  final String? description;
  final bool isActive;

  PaymentMethodModel({
    required this.id,
    required this.methodName,
    this.description,
    this.isActive = true,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['PaymentMethodID'] ?? json['id'] ?? '',
      methodName: json['MethodName'] ?? '',
      description: json['Description'],
      isActive: json['IsActive'] ?? true,
    );
  }
}
