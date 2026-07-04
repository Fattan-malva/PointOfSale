import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';

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

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.warmBone,
      appBar: _buildAppBar(authState),
      drawer: _buildDrawer(authState),
      body: _buildBody(statsAsync),
    );
  }

  PreferredSizeWidget _buildAppBar(AuthState authState) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: SizedBox(
          height: 1,
          child: ColoredBox(color: Color(0xFFEAEAEA)),
        ),
      ),
      title: const Text(
        'BackOffice',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.03,
          color: Color(0xFF111111),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 20),
          onPressed: () {},
        ),
        _buildUserAvatar(authState),
      ],
    );
  }

  Widget _buildUserAvatar(AuthState authState) {
    final initial = (authState.user?.name ?? 'U').substring(0, 1).toUpperCase();
    return PopupMenuButton<String>(
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFEAEAEA)),
      ),
      onSelected: (v) {
        if (v == 'logout') {
          ref.read(authStateProvider.notifier).logout();
        } else if (v == 'profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        } else if (v == 'settings') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'profile', child: Text('Profile')),
        const PopupMenuItem(value: 'settings', child: Text('Settings')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFEAEAEA), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111111),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(AuthState authState) {
    final userName = authState.user?.name ?? 'User';
    final userRole = authState.user?.role ?? '';
    final initial = userName.substring(0, 1).toUpperCase();

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEAEAEA), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFEAEAEA), width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                      Text(
                        userRole.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.06,
                          color: Color(0xFF787774),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(Icons.dashboard_rounded, 'Dashboard', 0),
                  _sectionHeader('Master Data'),
                  _drawerItem(Icons.category_rounded, 'Categories', 1),
                  _drawerItem(Icons.inventory_2_rounded, 'Items', 2),
                  _drawerItem(Icons.inventory_rounded, 'Packages', 3),
                  _drawerItem(Icons.tune_rounded, 'Modifiers', 4),
                  _drawerItem(Icons.table_restaurant_rounded, 'Tables', 5),
                  _sectionHeader('Pricing'),
                  _drawerItem(Icons.receipt_long_rounded, 'Tax', 6),
                  _drawerItem(Icons.local_offer_rounded, 'Discounts', 7),
                  _sectionHeader('Operations'),
                  _drawerItem(Icons.people_alt_rounded, 'Employees', 8),
                  _drawerItem(Icons.receipt_rounded, 'Orders', 9),
                  _drawerItem(Icons.store_rounded, 'Branches', 10),
                  _sectionHeader('Insights'),
                  _drawerItem(Icons.bar_chart_rounded, 'Reports', 11),
                  _drawerItem(Icons.security_rounded, 'Roles', 12),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFEAEAEA), width: 1),
                ),
              ),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.logout_rounded,
                    size: 20, color: Color(0xFF5C5C63)),
                title: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 14, color: Color(0xFF5C5C63)),
                ),
                onTap: () => ref.read(authStateProvider.notifier).logout(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.08,
          color: Color(0xFF787774),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: isSelected ? AppColors.accentSoft : Colors.transparent,
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Icon(icon, size: 18,
          color: isSelected ? AppColors.accent : const Color(0xFF5C5C63),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.accent : const Color(0xFF111111),
          ),
        ),
        onTap: () {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildBody(AsyncValue<DashboardStats> statsAsync) {
    if (_selectedIndex == 0) {
      if (_animationController.status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
      return _buildDashboard(statsAsync);
    }
    switch (_selectedIndex) {
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
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildDashboard(AsyncValue<DashboardStats> statsAsync) {
    return statsAsync.when(
      data: (s) => _buildDashboardContent(s),
      loading: () => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (e, _) => Center(
        child: Text('Error: $e',
            style: const TextStyle(color: Color(0xFF5C5C63))),
      ),
    );
  }

  Widget _buildDashboardContent(DashboardStats s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnimatedEntry(
            controller: _animationController,
            index: 0,
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(-0.3, -0.3),
                          radius: 0.6,
                          colors: [
                            Color(0x08E1F3FE),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.04,
                    height: 1.1,
                    color: Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _AnimatedEntry(
            controller: _animationController,
            index: 0,
            child: const Text(
              'Overview of your business today',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF787774),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildBentoStats(s),
          const SizedBox(height: 40),
          _AnimatedEntry(
            controller: _animationController,
            index: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.02,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuickActions(),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _AnimatedEntry(
            controller: _animationController,
            index: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.02,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 16),
                _buildRecentOrders(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoStats(DashboardStats s) {
    return Column(
      children: [
        _AnimatedEntry(
          controller: _animationController,
          index: 1,
          child: _BentoStatCard(
            icon: Icons.trending_up_rounded,
            value: 'Rp ${_fmt(s.todayRevenue)}',
            label: 'Revenue Today',
            pastelBg: AppColors.pastelBlue,
            pastelFg: AppColors.pastelBlueText,
            growth: s.revenueGrowth > 0
                ? '+${s.revenueGrowth.toStringAsFixed(0)}%' : null,
            large: true,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AnimatedEntry(
                controller: _animationController,
                index: 2,
                child: _BentoStatCard(
                  icon: Icons.receipt_long_rounded,
                  value: s.totalOrders.toString(),
                  label: 'Orders Today',
                  pastelBg: AppColors.pastelRed,
                  pastelFg: AppColors.pastelRedText,
                  growth: s.orderGrowth > 0
                      ? '+${s.orderGrowth}' : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AnimatedEntry(
                controller: _animationController,
                index: 3,
                child: _BentoStatCard(
                  icon: Icons.inventory_2_rounded,
                  value: s.activeItems.toString(),
                  label: 'Active Items',
                  pastelBg: AppColors.pastelGreen,
                  pastelFg: AppColors.pastelGreenText,
                  subtitle: '${s.lowStockItems} low stock',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AnimatedEntry(
                controller: _animationController,
                index: 4,
                child: _BentoStatCard(
                  icon: Icons.people_alt_rounded,
                  value: s.totalEmployees.toString(),
                  label: 'Employees',
                  pastelBg: AppColors.pastelYellow,
                  pastelFg: AppColors.pastelYellowText,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      (Icons.add_rounded, 'New Item', 2),
      (Icons.inventory_2_rounded, 'New Package', 3),
      (Icons.person_add_rounded, 'New Employee', 8),
      (Icons.receipt_rounded, 'View Orders', 9),
      (Icons.assessment_rounded, 'Reports', 11),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: actions.map((a) {
        final icon = a.$1;
        final label = a.$2;
        final index = a.$3;
        return _MiniAction(
          icon: icon,
          label: label,
          onTap: () => setState(() => _selectedIndex = index),
        );
      }).toList(),
    );
  }

  Widget _buildRecentOrders() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEAEAEA)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              _orderHeader('Order ID', flex: 2),
              _orderHeader('Customer', flex: 3),
              _orderHeader('Total', flex: 2),
              _orderHeader('Status', flex: 2),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFEAEAEA)),
          Text(
            'No recent orders',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF787774).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderHeader(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.06,
          color: Color(0xFF787774),
        ),
      ),
    );
  }

  String _fmt(double a) {
    return a.toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.');
  }
}

class _BentoStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color pastelBg;
  final Color pastelFg;
  final String? growth;
  final String? subtitle;
  final bool large;

  const _BentoStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.pastelBg,
    required this.pastelFg,
    this.growth,
    this.subtitle,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: large ? 44 : 36,
          height: large ? 44 : 36,
          decoration: BoxDecoration(
            color: pastelBg,
            borderRadius: BorderRadius.circular(large ? 10 : 8),
          ),
          child: Icon(icon, size: large ? 22 : 18, color: pastelFg),
        ),
        SizedBox(height: large ? 20 : 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: large ? 28 : 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.03,
                  height: 1.1,
                  color: const Color(0xFF111111),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (growth != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: pastelBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  growth!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: pastelFg,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.06,
            color: Color(0xFF787774),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF787774).withOpacity(0.7),
            ),
          ),
        ],
      ],
    );

    return Container(
      padding: EdgeInsets.all(large ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEAEAEA)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: content,
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MiniAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEAEAEA)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF5C5C63)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111111),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedEntry extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;

  const _AnimatedEntry({
    required this.controller,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double start = index * 0.08;
    final double end = (start + 0.3).clamp(0.0, 1.0);
    final curve = const Cubic(0.16, 1.0, 0.3, 1.0);

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: curve),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(start, end, curve: curve),
          ),
        ),
        child: child,
      ),
    );
  }
}
