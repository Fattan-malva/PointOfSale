import '../core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/item_model.dart';

class MenuRepository {
  final _api = ApiClient();

  Future<List<CategoryModel>> getCategories() async {
    final response = await _api.get('/master/categories');
    final data = response.data['data'] as List<dynamic>;
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }

  Future<CategoryModel> getCategoryById(String id) async {
    final response = await _api.get('/master/categories/$id');
    return CategoryModel.fromJson(response.data['data']);
  }

  Future<List<ItemModel>> getItems({String? categoryId}) async {
    final response = await _api.get(
      '/master/items',
      queryParameters: {if (categoryId != null) 'CategoryID': categoryId},
    );
    final data = response.data['data'] as List<dynamic>;
    return data.map((json) => ItemModel.fromJson(json)).toList();
  }

  Future<ItemModel> getItemById(String id) async {
    final response = await _api.get('/master/items/$id');
    return ItemModel.fromJson(response.data['data']);
  }
}
