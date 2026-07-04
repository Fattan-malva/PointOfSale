import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../models/modifier_model.dart';

final modifierRepositoryProvider = Provider((ref) => ModifierRepository());

class ModifierRepository {
  final _api = ApiClient();

  Future<List<ModifierModel>> getModifiers({String? search, int limit = 100, int offset = 0}) async {
    final params = <String, dynamic>{'limit': limit.toString(), 'offset': offset.toString()};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final res = await _api.get('/modifiers', queryParameters: params);
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => ModifierModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ModifierModel> createModifier(Map<String, dynamic> data) async {
    final res = await _api.post('/modifiers', data: data);
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return ModifierModel.fromJson(result);
  }

  Future<ModifierModel> updateModifier(String id, Map<String, dynamic> data) async {
    final res = await _api.put('/modifiers/$id', data: data);
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return ModifierModel.fromJson(result);
  }

  Future<void> deleteModifier(String id) async {
    await _api.delete('/modifiers/$id');
  }

  Future<List<ModifierOptionModel>> getModifierOptions(String modifierId) async {
    final res = await _api.get('/modifiers/$modifierId/options');
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => ModifierOptionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ModifierOptionModel> createOption(String modifierId, Map<String, dynamic> data) async {
    final res = await _api.post('/modifiers/$modifierId/options', data: data);
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return ModifierOptionModel.fromJson(result);
  }

  Future<ModifierOptionModel> updateOption(String optionId, Map<String, dynamic> data) async {
    final res = await _api.put('/modifier-options/$optionId', data: data);
    final result = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return ModifierOptionModel.fromJson(result);
  }

  Future<void> deleteOption(String optionId) async {
    await _api.delete('/modifier-options/$optionId');
  }
}
