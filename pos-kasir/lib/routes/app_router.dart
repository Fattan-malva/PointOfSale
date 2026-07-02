import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/menu/menu_screen.dart';
import '../features/order/order_screen.dart';
import '../features/order/order_history_screen.dart';
import '../features/payment/payment_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated
        ? AppRoutes.home
        : AppRoutes.login,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      // If not logged in and not on login page, go to login
      if (!isAuthenticated && !isLoggingIn) {
        return AppRoutes.login;
      }

      // If logged in and on login page, go to home
      if (isAuthenticated && isLoggingIn) {
        return AppRoutes.home;
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.menu,
        name: 'menu',
        builder: (context, state) => const MenuScreen(),
      ),
      GoRoute(
        path: AppRoutes.order,
        name: 'order',
        builder: (context, state) => const OrderScreen(),
      ),
      GoRoute(
        path: AppRoutes.payment,
        name: 'payment',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderHistory,
        name: 'orderHistory',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
    ],
  );
});

/// Route names
class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String menu = '/menu';
  static const String order = '/order';
  static const String payment = '/payment';
  static const String orderHistory = '/order-history';
  static const String splash = '/';
}
