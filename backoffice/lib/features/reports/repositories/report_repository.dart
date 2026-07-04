import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final reportRepositoryProvider = Provider((ref) => ReportRepository());

class ReportRepository {
  final _api = ApiClient();

  Future<Map<String, dynamic>> getDashboardStats({String? branchId}) async {
    final params = <String, dynamic>{};
    if (branchId != null) params['BranchID'] = branchId;

    final res = await _api.get('/reports/dashboard', queryParameters: params);
    return res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSalesReport({String? branchId, String? dateFrom, String? dateTo}) async {
    final params = <String, dynamic>{};
    if (branchId != null) params['BranchID'] = branchId;
    if (dateFrom != null) params['DateFrom'] = dateFrom;
    if (dateTo != null) params['DateTo'] = dateTo;

    final res = await _api.get('/reports/sales', queryParameters: params);
    return res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getSalesByPayment({String? branchId, String? dateFrom, String? dateTo}) async {
    final params = <String, dynamic>{};
    if (branchId != null) params['BranchID'] = branchId;
    if (dateFrom != null) params['DateFrom'] = dateFrom;
    if (dateTo != null) params['DateTo'] = dateTo;

    final res = await _api.get('/reports/sales/by-payment', queryParameters: params);
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getSalesByCashier({String? branchId, String? dateFrom, String? dateTo}) async {
    final params = <String, dynamic>{};
    if (branchId != null) params['BranchID'] = branchId;
    if (dateFrom != null) params['DateFrom'] = dateFrom;
    if (dateTo != null) params['DateTo'] = dateTo;

    final res = await _api.get('/reports/sales/by-cashier', queryParameters: params);
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getTopItems({String? branchId, String? dateFrom, String? dateTo}) async {
    final params = <String, dynamic>{};
    if (branchId != null) params['BranchID'] = branchId;
    if (dateFrom != null) params['DateFrom'] = dateFrom;
    if (dateTo != null) params['DateTo'] = dateTo;

    final res = await _api.get('/reports/sales/top-items', queryParameters: params);
    final data = res.data['data'] as List<dynamic>? ?? res.data as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> getStockReport({String? branchId}) async {
    final params = <String, dynamic>{};
    if (branchId != null) params['BranchID'] = branchId;

    final res = await _api.get('/reports/stock', queryParameters: params);
    return res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
  }
}
