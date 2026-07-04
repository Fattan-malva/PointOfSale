import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';

import '../../core/constants/app_typography.dart';
import '../auth/auth_provider.dart';
import 'dashboard_provider.dart';
import '../employee/employee_screen.dart';
import '../orders/orders_screen.dart';
import '../reports/reports_screen.dart';
import '../branch/branch_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../role/role_screen.dart';
import '../categories/category_screen.dart';
import '../items/item_screen.dart';
import '../packages/package_screen.dart';
import '../modifiers/modifier_screen.dart';
import '../tables/table_screen.dart';
import '../taxes/tax_screen.dart';
import '../discounts/discount_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('BackOffice'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: AppColors.accent,
              child: Text(
                (authState.user?.name ?? 'U').substring(0, 1).toUpperCase(),
                style: AppTypography.body.copyWith(color: Colors.white),
              ),
            ),
            onSelected: (v) {
              if (v == 'logout') {
                ref.read(authStateProvider.notifier).logout();
              } else if (v == 'profile') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              } else if (v == 'settings') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(authState),
      body: _buildBody(statsAsync),
    );
  }

  Widget _buildDrawer(AuthState authState) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(authState.user?.name ?? 'User'),
            accountEmail: Text(authState.user?.role ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.accent,
              child: Text(
                (authState.user?.name ?? 'U').substring(0, 1).toUpperCase(),
                style: AppTypography.h3.copyWith(color: Colors.white),
              ),
            ),
            decoration: const BoxDecoration(color: AppColors.accent),
          ),
          Expanded(
            child: ListView(
              children: [
                _drawerItem(Icons.dashboard, 'Dashboard', 0),
                _sectionHeader('MASTER DATA'),
                _drawerItem(Icons.category, 'Categories', 1),
                _drawerItem(Icons.inventory, 'Items', 2),
                _drawerItem(Icons.inventory_2, 'Packages', 3),
                _drawerItem(Icons.tune, 'Modifiers', 4),
                _drawerItem(Icons.table_restaurant, 'Tables', 5),
                _sectionHeader('PRICING'),
                _drawerItem(Icons.receipt_long, 'Tax', 6),
                _drawerItem(Icons.local_offer, 'Discounts', 7),
                _sectionHeader('OPERATIONS'),
                _drawerItem(Icons.people, 'Employees', 8),
                _drawerItem(Icons.receipt, 'Orders', 9),
                _drawerItem(Icons.store, 'Branches', 10),
                _sectionHeader('INSIGHTS'),
                _drawerItem(Icons.bar_chart, 'Reports', 11),
                _drawerItem(Icons.security, 'Roles', 12),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title,
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      selected: _selectedIndex == index,
      selectedTileColor: AppColors.accentSoft,
      selectedColor: AppColors.accent,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildBody(AsyncValue<DashboardStats> statsAsync) {
    switch (_selectedIndex) {
      case 0: return _buildDashboard(statsAsync);
      case 1: return const CategoryScreen();
      case 2: return const ItemScreen();
      case 3: return const PackageScreen();
      case 4: return const ModifierScreen();
      case 5: return const TableScreen();
      case 6: return const TaxScreen();
      case 7: return const DiscountScreen();
      case 8: return const EmployeeScreen();
      case 9: return const OrdersScreen();
      case 10: return const BranchScreen();
      case 11: return const ReportsScreen();
      case 12: return const RoleScreen();
      default: return _buildDashboard(statsAsync);
    }
  }

  Widget _buildDashboard(AsyncValue<DashboardStats> statsAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard Overview', style: AppTypography.h2),
          const SizedBox(height: 24),
          statsAsync.when(
            data: (s) => _buildStatsGrid(s),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          const SizedBox(height: 32),
          Text('Quick Actions', style: AppTypography.h3),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 32),
          Text('Recent Orders', style: AppTypography.h3),
          const SizedBox(height: 16),
          _buildRecentOrders(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatCard('Total Orders', stats.totalOrders.toString(), Icons.receipt_long, AppColors.accent),
        _StatCard('Revenue Today', 'Rp ${_fmt(stats.todayRevenue)}', Icons.attach_money, AppColors.success),
        _StatCard('Active Items', stats.activeItems.toString(), Icons.inventory, AppColors.info),
        _StatCard('Employees', stats.totalEmployees.toString(), Icons.people, AppColors.warning),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ActionChip(
          avatar: const Icon(Icons.add, size: 18),
          label: const Text('Add Item'),
          onPressed: () => setState(() => _selectedIndex = 2),
        ),
        ActionChip(
          avatar: const Icon(Icons.inventory_2, size: 18),
          label: const Text('Add Package'),
          onPressed: () => setState(() => _selectedIndex = 3),
        ),
        ActionChip(
          avatar: const Icon(Icons.person_add, size: 18),
          label: const Text('Add Employee'),
          onPressed: () => setState(() => _selectedIndex = 8),
        ),
        ActionChip(
          avatar: const Icon(Icons.receipt, size: 18),
          label: const Text('View Orders'),
          onPressed: () => setState(() => _selectedIndex = 9),
        ),
        ActionChip(
          avatar: const Icon(Icons.assessment, size: 18),
          label: const Text('Reports'),
          onPressed: () => setState(() => _selectedIndex = 11),
        ),
      ],
    );
  }

  Widget _buildRecentOrders() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Recent orders from API', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
      ),
    );
  }

  String _fmt(double a) => a.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

class NavigationItem {
  final IconData icon;
  final String label;
  NavigationItem(this.icon, this.label);
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(title, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
