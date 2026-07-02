import '../core/network/api_client.dart';
import '../models/order_model.dart';

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
    final response = await _api.get(
      '/transaction/orders',
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
  }

  Future<OrderModel> getOrderById(String id) async {
    final response = await _api.get('/transaction/orders/$id');
    return OrderModel.fromJson(response.data['data']);
  }

  Future<OrderModel> createOrder({
    required String branchId,
    required String userId,
    String? customerId,
    String? tableId,
    required String orderType,
    String? note,
  }) async {
    final response = await _api.post(
      '/transaction/orders',
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
  }

  Future<OrderModel> updateOrder(
    String id, {
    String? note,
    String? orderType,
  }) async {
    final response = await _api.put(
      '/transaction/orders/$id',
      data: {
        if (note != null) 'Note': note,
        if (orderType != null) 'OrderType': orderType,
      },
    );
    return OrderModel.fromJson(response.data['data']);
  }

  Future<OrderModel> confirmOrder(String id) async {
    final response = await _api.post('/transaction/orders/$id/confirm');
    return OrderModel.fromJson(response.data['data']);
  }

  Future<OrderModel> completeOrder(String id) async {
    final response = await _api.post('/transaction/orders/$id/complete');
    return OrderModel.fromJson(response.data['data']);
  }

  Future<OrderModel> cancelOrder(String id) async {
    final response = await _api.post('/transaction/orders/$id/cancel');
    return OrderModel.fromJson(response.data['data']);
  }

  Future<OrderDetailModel> addItemToOrder(
    String orderId, {
    required String itemId,
    required double qty,
    String? note,
  }) async {
    final response = await _api.post(
      '/transaction/orders/$orderId/items',
      data: {'ItemID': itemId, 'Qty': qty, if (note != null) 'Note': note},
    );
    return OrderDetailModel.fromJson(response.data['data']);
  }

  Future<OrderDetailModel> updateOrderItem(
    String orderId,
    String detailId, {
    double? qty,
    String? note,
    double? price,
  }) async {
    final response = await _api.put(
      '/transaction/orders/$orderId/items/$detailId',
      data: {
        if (qty != null) 'Qty': qty,
        if (note != null) 'Note': note,
        if (price != null) 'Price': price,
      },
    );
    return OrderDetailModel.fromJson(response.data['data']);
  }

  Future<void> removeOrderItem(String orderId, String detailId) async {
    await _api.delete('/transaction/orders/$orderId/items/$detailId');
  }

  Future<OrderModifierModel> addModifierToItem(
    String orderId,
    String detailId, {
    String? modifierId,
    String? modifierOptionId,
    required String optionName,
    double additionalPrice = 0,
  }) async {
    final response = await _api.post(
      '/transaction/orders/$orderId/items/$detailId/modifiers',
      data: {
        if (modifierId != null) 'ModifierID': modifierId,
        if (modifierOptionId != null) 'ModifierOptionID': modifierOptionId,
        'OptionName': optionName,
        'AdditionalPrice': additionalPrice,
      },
    );
    return OrderModifierModel.fromJson(response.data['data']);
  }

  Future<void> removeModifierFromItem(
    String orderId,
    String detailId,
    String modifierId,
  ) async {
    await _api.delete(
      '/transaction/orders/$orderId/items/$detailId/modifiers/$modifierId',
    );
  }

  Future<OrderDiscountModel> applyDiscount(
    String orderId, {
    String? discountId,
    required String discountName,
    required String discountType,
    required double discountValue,
    required double discountAmount,
  }) async {
    final response = await _api.post(
      '/transaction/orders/$orderId/discounts',
      data: {
        if (discountId != null) 'DiscountID': discountId,
        'DiscountName': discountName,
        'DiscountType': discountType,
        'DiscountValue': discountValue,
        'DiscountAmount': discountAmount,
      },
    );
    return OrderDiscountModel.fromJson(response.data['data']);
  }

  Future<void> removeDiscount(String orderId, String discountId) async {
    await _api.delete('/transaction/orders/$orderId/discounts/$discountId');
  }
}
