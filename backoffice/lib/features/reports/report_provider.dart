import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories/report_repository.dart';

final salesReportProvider = FutureProvider.family<Map<String, dynamic>, Map<String, String?>>((ref, params) async {
  final repo = ref.watch(reportRepositoryProvider);
  return await repo.getSalesReport(
    branchId: params['branchId'],
    dateFrom: params['dateFrom'],
    dateTo: params['dateTo'],
  );
});

final salesByPaymentProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, String?>>((ref, params) async {
  final repo = ref.watch(reportRepositoryProvider);
  return await repo.getSalesByPayment(
    branchId: params['branchId'],
    dateFrom: params['dateFrom'],
    dateTo: params['dateTo'],
  );
});

final salesByCashierProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, String?>>((ref, params) async {
  final repo = ref.watch(reportRepositoryProvider);
  return await repo.getSalesByCashier(
    branchId: params['branchId'],
    dateFrom: params['dateFrom'],
    dateTo: params['dateTo'],
  );
});

final topItemsProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, String?>>((ref, params) async {
  final repo = ref.watch(reportRepositoryProvider);
  return await repo.getTopItems(
    branchId: params['branchId'],
    dateFrom: params['dateFrom'],
    dateTo: params['dateTo'],
  );
});

final stockReportProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(reportRepositoryProvider);
  return await repo.getStockReport();
});
