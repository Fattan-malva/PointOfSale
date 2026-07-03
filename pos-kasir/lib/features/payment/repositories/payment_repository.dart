import '../../../core/network/api_client.dart';
import '../../../models/payment_model.dart';
import '../../../core/network/api_exception.dart';

class PaymentRepository {
  final _api = ApiClient();

  // Process a payment for an order
  Future<PaymentModel> processPayment(
    String orderId, {
    required String paymentMethodId,
    required double paymentAmount,
    String? referenceNumber,
  }) async {
    try {
      final response = await _api.post(
        '/payments',
        data: {
          'OrderID': orderId,
          'PaymentMethodID': paymentMethodId,
          'PaymentAmount': paymentAmount,
          if (referenceNumber != null) 'ReferenceNumber': referenceNumber,
        },
      );
      return PaymentModel.fromJson(response.data['data']);
    } on ApiException catch (e) {
      throw ApiException(message: 'Failed to process payment: ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Failed to process payment: $e');
    }
  }

  // Get list of available payment methods
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await _api.get('/payment-methods');
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => PaymentMethodModel.fromJson(json)).toList();
    } on ApiException catch (e) {
      throw ApiException(message: 'Failed to fetch payment methods: ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Failed to fetch payment methods: $e');
    }
  }
}
