import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/secure_storage.dart';
import '../reports/repositories/report_repository.dart';

class DashboardStats {
  final int totalOrders;
  final double todayRevenue;
  final int activeItems;
  final int totalEmployees;
  final double monthlyRevenue;

  DashboardStats({
    this.totalOrders = 0,
    this.todayRevenue = 0,
    this.activeItems = 0,
    this.totalEmployees = 0,
    this.monthlyRevenue = 0,
  });
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  try {
    final api = ApiClient();
    final storage = SecureStorageService();
    final branchId = await storage.getBranchId();

    final branchParam = branchId != null ? {'BranchID': branchId} : <String, dynamic>{};

    final ordersRes = await api.get('/orders', queryParameters: {'limit': '1', ...branchParam});
    final itemsRes = await api.get('/items', queryParameters: {'limit': '1', ...branchParam});
    final usersRes = await api.get('/users', queryParameters: {'limit': '1', ...branchParam});

    int todayOrders = 0;
    double todayRevenue = 0;
    try {
      final reportRepo = ReportRepository();
      final dashboardData = await reportRepo.getDashboardStats(branchId: branchId);
      todayOrders = (dashboardData['todayOrders'] as num?)?.toInt() ?? (ordersRes.data['total'] as num?)?.toInt() ?? 0;
      todayRevenue = (dashboardData['todayRevenue'] as num?)?.toDouble() ?? 0;
    } catch (_) {
      todayOrders = (ordersRes.data['total'] as num?)?.toInt() ?? 0;
    }

    final totalItems = (itemsRes.data['total'] as num?)?.toInt() ?? 0;
    final totalUsers = (usersRes.data['total'] as num?)?.toInt() ?? 0;

    return DashboardStats(
      totalOrders: todayOrders,
      todayRevenue: todayRevenue,
      activeItems: totalItems,
      totalEmployees: totalUsers,
    );
  } catch (e) {
    return DashboardStats();
  }
});
