import '../../../core/network/api_client.dart';
import '../../../models/category_model.dart';
import '../../../models/item_model.dart';
import '../../../core/network/api_exception.dart';

class MenuRepository {
  final _api = ApiClient();

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _api.get('/categories');
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } on ApiException catch (e) {
      throw ApiException(message: 'Failed to fetch categories: ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Failed to fetch categories: $e');
    }
  }

  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final response = await _api.get('/categories/$id');
      return CategoryModel.fromJson(response.data['data']);
    } on ApiException catch (e) {
      throw ApiException(message: 'Failed to fetch category: ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Failed to fetch category: $e');
    }
  }

  Future<List<ItemModel>> getItems({String? categoryId}) async {
    try {
      final response = await _api.get(
        '/items',
        queryParameters: {if (categoryId != null) 'categoryId': categoryId},
      );
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => ItemModel.fromJson(json)).toList();
    } on ApiException catch (e) {
      throw ApiException(message: 'Failed to fetch items: ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Failed to fetch items: $e');
    }
  }

  Future<ItemModel> getItemById(String id) async {
    try {
      final response = await _api.get('/items/$id');
      return ItemModel.fromJson(response.data['data']);
    } on ApiException catch (e) {
      throw ApiException(message: 'Failed to fetch item: ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Failed to fetch item: $e');
    }
  }
}
