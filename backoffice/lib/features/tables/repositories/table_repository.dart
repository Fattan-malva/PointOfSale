import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../models/table_model.dart';

final tableRepositoryProvider = Provider((ref) => TableRepository());

class TableRepository {
  final _api = ApiClient();

  Future<List<TableModel>> getTables({String? search, String? branchId, int limit = 100, int offset = 0}) async {
    final params = <String, dynamic>{'limit': limit.toString(), 'offset': offset.toString()};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (branchId != null) params['BranchID'] = branchId;
    final res = await _api.get('/tables', queryParameters: params);
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => TableModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TableModel> createTable(Map<String, dynamic> data) async {
    final res = await _api.post('/tables', data: data);
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return TableModel.fromJson(result);
  }

  Future<TableModel> updateTable(String id, Map<String, dynamic> data) async {
    final res = await _api.put('/tables/$id', data: data);
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return TableModel.fromJson(result);
  }

  Future<void> deleteTable(String id) async {
    await _api.delete('/tables/$id');
  }
}
