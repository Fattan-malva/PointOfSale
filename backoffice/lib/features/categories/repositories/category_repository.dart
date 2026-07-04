import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../models/category_model.dart';

final categoryRepositoryProvider = Provider((ref) => CategoryRepository());

class CategoryRepository {
  final _api = ApiClient();

  Future<List<CategoryModel>> getCategories({String? search, int limit = 100, int offset = 0}) async {
    final params = <String, dynamic>{'limit': limit.toString(), 'offset': offset.toString()};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final res = await _api.get('/categories', queryParameters: params);
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    final res = await _api.post('/categories', data: data);
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return CategoryModel.fromJson(result);
  }

  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> data) async {
    final res = await _api.put('/categories/$id', data: data);
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return CategoryModel.fromJson(result);
  }

  Future<void> deleteCategory(String id) async {
    await _api.delete('/categories/$id');
  }
}
