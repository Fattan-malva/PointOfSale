import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../models/employee_model.dart';
import '../../../models/role_model.dart';
import '../../../models/branch_model.dart';

final employeeRepositoryProvider = Provider((ref) => EmployeeRepository());

class EmployeeRepository {
  final _api = ApiClient();

  Future<List<EmployeeModel>> getEmployees({String? search, int page = 1, int limit = 20}) async {
    final params = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) params['search'] = search;

    final res = await _api.get('/users', queryParameters: params);
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<EmployeeModel> getEmployee(String id) async {
    final res = await _api.get('/users/$id');
    final data = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return EmployeeModel.fromJson(data);
  }

  Future<EmployeeModel> createEmployee(Map<String, dynamic> data) async {
    final res = await _api.post('/users', data: data);
    final employeeData = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return EmployeeModel.fromJson(employeeData);
  }

  Future<EmployeeModel> updateEmployee(String id, Map<String, dynamic> data) async {
    final res = await _api.put('/users/$id', data: data);
    final employeeData = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return EmployeeModel.fromJson(employeeData);
  }

  Future<void> deleteEmployee(String id) async {
    await _api.delete('/users/$id');
  }

  Future<List<RoleModel>> getRoles() async {
    final res = await _api.get('/roles');
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => RoleModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<BranchModel>> getBranches() async {
    final res = await _api.get('/branches');
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => BranchModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
