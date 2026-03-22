import 'package:flutter/material.dart';
import 'route_names.dart';
import '../ui/auth/login_screen.dart';
import '../ui/auth/register_screen.dart';
import '../ui/dashboard_screen.dart';
import '../ui/dishes/dishes_screen.dart';
import '../ui/categories/categories_screen.dart';
import '../ui/orders/orders_screen.dart';
import '../ui/inventory/inventory_screen.dart';
import '../ui/reservations/reservations_screen.dart';
import '../ui/users/users_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
    RouteNames.login: (_) => const LoginScreen(),
    RouteNames.register: (_) => const RegisterScreen(),
    RouteNames.dashboard: (_) => const DashboardScreen(),
    RouteNames.dishes: (_) => const DishesScreen(),
    RouteNames.categories: (_) => const CategoriesScreen(),
    RouteNames.orders: (_) => const OrdersScreen(),
    RouteNames.inventory: (_) => const InventoryScreen(),
    RouteNames.reservations: (_) => const ReservationsScreen(),
    RouteNames.users: (_) => const UsersScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (ctx) => const DashboardScreen(),
    );
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => const LoginScreen());
  }

  static void navigate(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndReplace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndClearStack(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}
