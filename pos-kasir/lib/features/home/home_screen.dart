import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../auth/auth_provider.dart';
import '../menu/menu_screen.dart';
import '../order/order_screen.dart';
import '../order/order_history_screen.dart';
import '../order/order_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [MenuScreen(), OrderScreen(), OrderHistoryScreen()];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final orderState = ref.watch(currentOrderProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('POS Kasir'),
        elevation: 0,
        actions: [
          // Order count badge
          if (orderState.hasOrder)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.space2),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space3,
                    vertical: AppSpacing.space1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    '${orderState.itemCount} item',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          // User name
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space3),
            child: Center(
              child: Text(
                authState.user?.name ?? 'User',
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            selectedIcon: Icon(Icons.restaurant_menu, color: AppColors.accent),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: orderState.itemCount > 0,
              label: Text('${orderState.itemCount}'),
              child: const Icon(Icons.shopping_cart),
            ),
            selectedIcon: const Icon(
              Icons.shopping_cart,
              color: AppColors.accent,
            ),
            label: 'Keranjang',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history, color: AppColors.accent),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Anda akan keluar dari aplikasi'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              Navigator.pop(context);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
