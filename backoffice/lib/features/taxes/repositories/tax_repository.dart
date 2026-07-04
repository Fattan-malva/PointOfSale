import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../models/tax_model.dart';

final taxRepositoryProvider = Provider((ref) => TaxRepository());

class TaxRepository {
  final _api = ApiClient();

  Future<List<TaxModel>> getTaxes({String? search, int limit = 100, int offset = 0}) async {
    final params = <String, dynamic>{'limit': limit.toString(), 'offset': offset.toString()};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final res = await _api.get('/taxes', queryParameters: params);
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => TaxModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TaxModel> createTax(Map<String, dynamic> data) async {
    final res = await _api.post('/taxes', data: data);
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return TaxModel.fromJson(result);
  }

  Future<TaxModel> updateTax(String id, Map<String, dynamic> data) async {
    final res = await _api.put('/taxes/$id', data: data);
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return TaxModel.fromJson(result);
  }

  Future<void> deleteTax(String id) async {
    await _api.delete('/taxes/$id');
  }
}
