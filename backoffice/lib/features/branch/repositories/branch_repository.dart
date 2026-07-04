import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../models/branch_model.dart';

final branchRepositoryProvider = Provider((ref) => BranchRepository());

class BranchRepository {
  final _api = ApiClient();

  Future<List<BranchModel>> getBranches({String? search, int page = 1, int limit = 20}) async {
    final params = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) params['search'] = search;

    final res = await _api.get('/branches', queryParameters: params);
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => BranchModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BranchModel> getBranch(String id) async {
    final res = await _api.get('/branches/$id');
    final data = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return BranchModel.fromJson(data);
  }

  Future<BranchModel> createBranch(Map<String, dynamic> data) async {
    final res = await _api.post('/branches', data: data);
    final branchData = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return BranchModel.fromJson(branchData);
  }

  Future<BranchModel> updateBranch(String id, Map<String, dynamic> data) async {
    final res = await _api.put('/branches/$id', data: data);
    final branchData = res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
    return BranchModel.fromJson(branchData);
  }

  Future<void> deleteBranch(String id) async {
    await _api.delete('/branches/$id');
  }
}
