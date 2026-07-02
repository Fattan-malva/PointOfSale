import '../core/network/api_client.dart';
import '../models/table_model.dart';

class TableRepository {
  final _api = ApiClient();

  Future<List<TableModel>> getTables() async {
    final response = await _api.get('/master/tables');
    final data = response.data['data'] as List<dynamic>;
    return data.map((json) => TableModel.fromJson(json)).toList();
  }

  Future<TableModel> getTableById(String id) async {
    final response = await _api.get('/master/tables/$id');
    return TableModel.fromJson(response.data['data']);
  }
}
