import '../../../core/network/api_client.dart';
import '../../../models/table_model.dart';
import '../../../core/network/api_exception.dart';

class TableRepository {
  final _api = ApiClient();

  Future<List<TableModel>> getTables() async {
    try {
      final response = await _api.get('/tables');
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => TableModel.fromJson(json)).toList();
    } on ApiException catch (e) {
      throw ApiException(message: 'Failed to fetch tables: ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Failed to fetch tables: $e');
    }
  }

  Future<TableModel> getTableById(String id) async {
    try {
      final response = await _api.get('/tables/$id');
      return TableModel.fromJson(response.data['data']);
    } on ApiException catch (e) {
      throw ApiException(message: 'Failed to fetch table details: ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Failed to fetch table details: $e');
    }
  }
}
