import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/secure_storage.dart';
import '../reports/repositories/report_repository.dart';

class DashboardStats {
  final int totalOrders;
  final int orderGrowth;
  final double todayRevenue;
  final double revenueGrowth;
  final int activeItems;
  final int lowStockItems;
  final int totalEmployees;
  final int pendingOrders;
  final double monthlyRevenue;

  DashboardStats({
    this.totalOrders = 0,
    this.orderGrowth = 0,
    this.todayRevenue = 0,
    this.revenueGrowth = 0,
    this.activeItems = 0,
    this.lowStockItems = 0,
    this.totalEmployees = 0,
    this.pendingOrders = 0,
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

    final totalOrders = (ordersRes.data['total'] as num?)?.toInt() ?? 0;
    final totalItems = (itemsRes.data['total'] as num?)?.toInt() ?? 0;
    final totalUsers = (usersRes.data['total'] as num?)?.toInt() ?? 0;

    int todayOrders = 0;
    double todayRevenue = 0;
    double monthlyRevenue = 0;
    int orderGrowth = 0;
    double revenueGrowth = 0;
    int lowStockItems = 0;
    int pendingOrders = 0;

    try {
      final reportRepo = ReportRepository();
      final dashboardData = await reportRepo.getDashboardStats(branchId: branchId);
      todayOrders = (dashboardData['todayOrders'] as num?)?.toInt() ?? totalOrders;
      todayRevenue = (dashboardData['todayRevenue'] as num?)?.toDouble() ?? 0;
      monthlyRevenue = (dashboardData['monthlyRevenue'] as num?)?.toDouble() ?? 0;
      orderGrowth = (dashboardData['orderGrowth'] as num?)?.toInt() ?? 0;
      revenueGrowth = (dashboardData['revenueGrowth'] as num?)?.toDouble() ?? 0;
      lowStockItems = (dashboardData['lowStockItems'] as num?)?.toInt() ?? 0;
      pendingOrders = (dashboardData['pendingOrders'] as num?)?.toInt() ?? 0;
    } catch (_) {
    }

    return DashboardStats(
      totalOrders: todayOrders > 0 ? todayOrders : totalOrders,
      orderGrowth: orderGrowth,
      todayRevenue: todayRevenue,
      revenueGrowth: revenueGrowth,
      activeItems: totalItems,
      lowStockItems: lowStockItems,
      totalEmployees: totalUsers,
      pendingOrders: pendingOrders,
      monthlyRevenue: monthlyRevenue,
    );
  } catch (e) {
    return DashboardStats();
  }
});
