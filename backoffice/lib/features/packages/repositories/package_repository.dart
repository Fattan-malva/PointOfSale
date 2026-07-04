import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../models/item_model.dart';
import '../../../models/modifier_model.dart';

final packageRepositoryProvider = Provider((ref) => PackageRepository());

class PackageRepository {
  final _api = ApiClient();

  Future<List<ItemModel>> getPackages({String? search, int limit = 100, int offset = 0}) async {
    final params = <String, dynamic>{'limit': limit.toString(), 'offset': offset.toString(), 'ItemType': 'Package'};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final res = await _api.get('/items', queryParameters: params);
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => ItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ItemModel> getPackage(String id) async {
    final res = await _api.get('/items/$id');
    final data = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return ItemModel.fromJson(data);
  }

  Future<ItemModel> createPackage(Map<String, dynamic> data) async {
    data['ItemType'] = 'Package';
    final res = await _api.post('/items', data: data);
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return ItemModel.fromJson(result);
  }

  Future<ItemModel> updatePackage(String id, Map<String, dynamic> data) async {
    final res = await _api.put('/items/$id', data: data);
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return ItemModel.fromJson(result);
  }

  Future<void> deletePackage(String id) async {
    await _api.delete('/items/$id');
  }

  Future<List<PackageDetailModel>> getPackageDetails(String packageItemId) async {
    final res = await _api.get('/items/$packageItemId/packages');
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => PackageDetailModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PackageDetailModel> addPackageDetail(String packageItemId, String itemId, int qty) async {
    final res = await _api.post('/items/$packageItemId/packages', data: {'ItemID': itemId, 'Qty': qty});
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return PackageDetailModel.fromJson(result);
  }

  Future<void> removePackageDetail(String packageItemId, String detailId) async {
    await _api.delete('/items/$packageItemId/packages/$detailId');
  }
}
