import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../models/discount_model.dart';

final discountRepositoryProvider = Provider((ref) => DiscountRepository());

class DiscountRepository {
  final _api = ApiClient();

  Future<List<DiscountModel>> getDiscounts({String? search, int limit = 100, int offset = 0}) async {
    final params = <String, dynamic>{'limit': limit.toString(), 'offset': offset.toString()};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final res = await _api.get('/discounts', queryParameters: params);
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => DiscountModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DiscountModel> createDiscount(Map<String, dynamic> data) async {
    final res = await _api.post('/discounts', data: data);
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return DiscountModel.fromJson(result);
  }

  Future<DiscountModel> updateDiscount(String id, Map<String, dynamic> data) async {
    final res = await _api.put('/discounts/$id', data: data);
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return DiscountModel.fromJson(result);
  }

  Future<void> deleteDiscount(String id) async {
    await _api.delete('/discounts/$id');
  }
}
