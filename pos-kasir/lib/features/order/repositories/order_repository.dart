import '../../../core/network/api_client.dart';
import '../../../models/order_model.dart';
import '../../../core/network/api_exception.dart';

class OrderRepository {
  final _api = ApiClient();

  Future<List<OrderModel>> getOrders({
    String? branchId,
    String? status,
    String? paymentStatus,
    String? orderType,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final response = await _api.get(
        '/orders',
        queryParameters: {
          if (branchId != null) 'BranchID': branchId,
          if (status != null) 'Status': status,
          if (paymentStatus != null) 'PaymentStatus': paymentStatus,
          if (orderType != null) 'OrderType': orderType,
          if (dateFrom != null) 'DateFrom': dateFrom,
          if (dateTo != null) 'DateTo': dateTo,
        },
      );
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } on ApiException catch (e) {
      throw ApiException(message: 'Failed to fetch orders: ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Failed to fetch orders: $e');
    }
  }

  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await _api.get('/orders/$id');
      return OrderModel.fromJson(response.data['data']);
    } on ApiException catch (e) {
      throw ApiException(message: 'Failed to fetch order: ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Failed to fetch order: $e');
    }
  }

  Future<OrderModel> createOrder({
    required String branchId,
    required String userId,
    String? customerId,
    String? tableId,
    required String orderType,
    String? note,
  }) async {
    try {
      final response = await _api.post(
        '/orders',
        data: {
          'BranchID': branchId,
          'UserID': userId,
          if (customerId != null) 'CustomerID': customerId,
          if (tableId != null) 'TableID': tableId,
          'OrderType': orderType,
          if (note != null) 'Note': note,
        },
      );
      return OrderModel.fromJson(response.data['data']);
    } on ApiException catch (e) {
      throw ApiException(message: 'Failed to create order: ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Failed to create order: $e');
    }
  }

  Future<OrderModel> updateOrder(
    String id, {
    String? note,
    String? orderType,
  }) async {
    try {
      final response = await _api.put(
        '/orders/$id',
        data: {
          if (note != null) 'Note': note,
          if (orderType != null) 'OrderType': orderType,
        },
      );
      return OrderModel.fromJson(response.data['data']);
    } on ApiException catch (e) {
      throw ApiException(message: 'Failed to update order: ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Failed to update order: $e');
    }
  }

  Future<OrderModel> confirmOrder(String id) async {
    try {
      final response = await _api.post('/orders/$id/confirm');
      return OrderModel.fromJson(response.data['data']);
    } on ApiException catch (e) {
      throw ApiException(message: 'Failed to confirm order: ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Failed to confirm order: $e');
    }
  }

  Future<OrderModel> completeOrder(String id) async {
    try {
      final response = await _api.post('/orders/$id/complete');
      return OrderModel.fromJson(response.data['data']);
    } on ApiException catch (e) {
      throw ApiException(message: 'Failed to complete order: ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Failed to complete order: $e');
    }
  }

  Future<void> cancelOrder(String id) async {
    try {
      await _api.delete('/orders/$id');
    } on ApiException catch (e) {
      throw ApiException(message: 'Failed to cancel order: ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Failed to cancel order: $e');
    }
  }

  // NOTE: Sub‑resource endpoints (items, modifiers, discounts) are not defined in the current backend API.
  // They should be implemented in the backend first, then the repository methods can be added here.
}
