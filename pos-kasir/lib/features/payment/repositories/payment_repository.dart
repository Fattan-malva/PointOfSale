import '../../../core/network/api_client.dart';
import '../../../models/payment_model.dart';

class PaymentRepository {
  final _api = ApiClient();

  Future<PaymentModel> processPayment(
    String orderId, {
    required String paymentMethodId,
    required double paymentAmount,
    String? referenceNumber,
  }) async {
    final response = await _api.post(
      '/transaction/orders/$orderId/payments',
      data: {
        'PaymentMethodID': paymentMethodId,
        'PaymentAmount': paymentAmount,
        if (referenceNumber != null) 'ReferenceNumber': referenceNumber,
      },
    );
    return PaymentModel.fromJson(response.data['data']);
  }

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final response = await _api.get('/master/payment-methods');
    final data = response.data['data'] as List<dynamic>;
    return data.map((json) => PaymentMethodModel.fromJson(json)).toList();
  }
}
