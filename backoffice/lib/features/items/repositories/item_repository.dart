import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../models/item_model.dart';
import '../../../models/modifier_model.dart';

final itemRepositoryProvider = Provider((ref) => ItemRepository());

class ItemRepository {
  final _api = ApiClient();

  Future<List<ItemModel>> getItems({String? search, String? categoryId, String? itemType, int limit = 100, int offset = 0}) async {
    final params = <String, dynamic>{'limit': limit.toString(), 'offset': offset.toString()};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (categoryId != null) params['CategoryID'] = categoryId;
    if (itemType != null) params['ItemType'] = itemType;
    final res = await _api.get('/items', queryParameters: params);
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => ItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ItemModel> getItem(String id) async {
    final res = await _api.get('/items/$id');
    final data = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return ItemModel.fromJson(data);
  }

  Future<ItemModel> createItem(Map<String, dynamic> data) async {
    final res = await _api.post('/items', data: data);
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return ItemModel.fromJson(result);
  }

  Future<ItemModel> updateItem(String id, Map<String, dynamic> data) async {
    final res = await _api.put('/items/$id', data: data);
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return ItemModel.fromJson(result);
  }

  Future<void> deleteItem(String id) async {
    await _api.delete('/items/$id');
  }

  Future<List<ModifierModel>> getItemModifiers(String itemId) async {
    final res = await _api.get('/items/$itemId/modifiers');
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => ModifierModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> assignModifier(String itemId, String modifierId) async {
    await _api.post('/items/$itemId/modifiers/$modifierId');
  }

  Future<void> removeModifier(String itemId, String modifierId) async {
    await _api.delete('/items/$itemId/modifiers/$modifierId');
  }

  Future<List<Map<String, dynamic>>> getItemTaxes(String itemId) async {
    final res = await _api.get('/items/$itemId/taxes');
    final data = res.data['data'] as List<dynamic>? ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> assignTaxToItem(String itemId, String taxId) async {
    await _api.post('/items/$itemId/taxes/$taxId');
  }

  Future<void> removeTaxFromItem(String itemId, String taxId) async {
    await _api.delete('/items/$itemId/taxes/$taxId');
  }

  Future<List<Map<String, dynamic>>> getItemDiscounts(String itemId) async {
    final res = await _api.get('/items/$itemId/discounts');
    final data = res.data['data'] as List<dynamic>? ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> assignDiscountToItem(String itemId, String discountId) async {
    await _api.post('/items/$itemId/discounts/$discountId');
  }

  Future<void> removeDiscountFromItem(String itemId, String discountId) async {
    await _api.delete('/items/$itemId/discounts/$discountId');
  }

  Future<List<Map<String, dynamic>>> getItemBranches(String itemId) async {
    final res = await _api.get('/items/$itemId/branches');
    final data = res.data['data'] as List<dynamic>? ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> assignBranchToItem(String itemId, String branchId) async {
    await _api.post('/items/$itemId/branches/$branchId');
  }

  Future<void> removeBranchFromItem(String itemId, String branchId) async {
    await _api.delete('/items/$itemId/branches/$branchId');
  }
}
