import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../models/order_model.dart';

final orderRepositoryProvider = Provider((ref) => OrderRepository());

class OrderRepository {
  final _api = ApiClient();

  Future<List<OrderModel>> getOrders({String? branchId, String? status, int page = 1, int limit = 20}) async {
    final params = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (branchId != null) params['BranchID'] = branchId;
    if (status != null && status.isNotEmpty && status != 'all') params['Status'] = status;

    final res = await _api.get('/orders', queryParameters: params);
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderModel> getOrder(String id) async {
    final res = await _api.get('/orders/$id');
    final data = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return OrderModel.fromJson(data);
  }

  Future<void> confirmOrder(String id) async {
    await _api.post('/orders/$id/confirm');
  }

  Future<void> completeOrder(String id) async {
    await _api.post('/orders/$id/complete');
  }

  Future<void> cancelOrder(String id) async {
    await _api.post('/orders/$id/cancel');
  }
}
