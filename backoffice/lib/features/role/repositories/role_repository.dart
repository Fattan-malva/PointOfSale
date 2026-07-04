import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../models/role_model.dart';
import '../../../models/permission_model.dart';

final roleRepositoryProvider = Provider((ref) => RoleRepository());

class RoleRepository {
  final _api = ApiClient();

  Future<List<RoleModel>> getRoles() async {
    final res = await _api.get('/roles');
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => RoleModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RoleModel> createRole(Map<String, dynamic> data) async {
    final res = await _api.post('/roles', data: data);
    final roleData = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return RoleModel.fromJson(roleData);
  }

  Future<RoleModel> updateRole(String id, Map<String, dynamic> data) async {
    final res = await _api.put('/roles/$id', data: data);
    final roleData = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return RoleModel.fromJson(roleData);
  }

  Future<List<PermissionModel>> getPermissions({String? roleId}) async {
    final params = <String, dynamic>{};
    if (roleId != null) params['RoleID'] = roleId;

    final res = await _api.get('/permissions', queryParameters: params);
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => PermissionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> assignPermissions(String roleId, List<String> permissionIds) async {
    await _api.post('/roles/$roleId/permissions', data: {'PermissionIDs': permissionIds});
  }

  Future<List<PermissionModel>> getRolePermissions(String roleId) async {
    final res = await _api.get('/roles/$roleId/permissions');
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => PermissionModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
