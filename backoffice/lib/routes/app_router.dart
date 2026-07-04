import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/branch/branch_screen.dart';
import '../features/role/role_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/reports/screens/daily_sales_screen.dart';
import '../features/reports/screens/monthly_report_screen.dart';
import '../features/reports/screens/inventory_summary_screen.dart';
import '../features/reports/screens/revenue_analytics_screen.dart';
import '../features/reports/screens/category_analysis_screen.dart';
import '../features/reports/screens/employee_performance_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated
        ? AppRoutes.home
        : AppRoutes.login,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      if (!isAuthenticated && !isLoggingIn) {
        return AppRoutes.login;
      }

      if (isAuthenticated && isLoggingIn) {
        return AppRoutes.home;
      }

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
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.branches,
        name: 'branches',
        builder: (context, state) => const BranchScreen(),
      ),
      GoRoute(
        path: AppRoutes.roles,
        name: 'roles',
        builder: (context, state) => const RoleScreen(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/reports/daily-sales',
        name: 'daily-sales',
        builder: (context, state) => const DailySalesScreen(),
      ),
      GoRoute(
        path: '/reports/monthly',
        name: 'monthly-report',
        builder: (context, state) => const MonthlyReportScreen(),
      ),
      GoRoute(
        path: '/reports/inventory-summary',
        name: 'inventory-summary',
        builder: (context, state) => const InventorySummaryScreen(),
      ),
      GoRoute(
        path: '/reports/revenue',
        name: 'revenue-analytics',
        builder: (context, state) => const RevenueAnalyticsScreen(),
      ),
      GoRoute(
        path: '/reports/category-analysis',
        name: 'category-analysis',
        builder: (context, state) => const CategoryAnalysisScreen(),
      ),
      GoRoute(
        path: '/reports/employee-performance',
        name: 'employee-performance',
        builder: (context, state) => const EmployeePerformanceScreen(),
      ),
    ],
  );
});

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String branches = '/branches';
  static const String roles = '/roles';
  static const String reports = '/reports';
  static const String splash = '/';
}
