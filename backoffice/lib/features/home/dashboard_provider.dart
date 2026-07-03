import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';


class DashboardStats {
  final int totalOrders;
  final double todayRevenue;
  final int activeItems;
  final int totalEmployees;

  DashboardStats({
    this.totalOrders = 0,
    this.todayRevenue = 0,
    this.activeItems = 0,
    this.totalEmployees = 0,
  });
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  try {
    final api = ApiClient();
    final ordersRes = await api.get('/orders', queryParameters: {'limit': '1'});
    final itemsRes = await api.get('/items', queryParameters: {'limit': '1'});
    final usersRes = await api.get('/users', queryParameters: {'limit': '1'});

    final totalOrders = (ordersRes.data['total'] as num?)?.toInt() ?? 0;
    final totalItems = (itemsRes.data['total'] as num?)?.toInt() ?? 0;
    final totalUsers = (usersRes.data['total'] as num?)?.toInt() ?? 0;

    return DashboardStats(
      totalOrders: totalOrders,
      todayRevenue: 0,
      activeItems: totalItems,
      totalEmployees: totalUsers,
    );
  } catch (e) {
    return DashboardStats();
  }
});
