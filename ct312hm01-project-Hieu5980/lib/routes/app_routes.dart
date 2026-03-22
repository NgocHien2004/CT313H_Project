import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

CustomTransitionPage<void> _slidePage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

CustomTransitionPage<void> _fadePage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _slideUpPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.login,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: RouteNames.login,
      pageBuilder: (context, state) => _fadePage(const LoginScreen(), state),
    ),
    GoRoute(
      path: RouteNames.register,
      pageBuilder: (context, state) =>
          _slidePage(const RegisterScreen(), state),
    ),
    GoRoute(
      path: RouteNames.dashboard,
      pageBuilder: (context, state) =>
          _slideUpPage(const DashboardScreen(), state),
    ),
    GoRoute(
      path: RouteNames.dishes,
      pageBuilder: (context, state) => _slidePage(const DishesScreen(), state),
    ),
    GoRoute(
      path: RouteNames.categories,
      pageBuilder: (context, state) =>
          _slidePage(const CategoriesScreen(), state),
    ),
    GoRoute(
      path: RouteNames.orders,
      pageBuilder: (context, state) => _slidePage(const OrdersScreen(), state),
    ),
    GoRoute(
      path: RouteNames.inventory,
      pageBuilder: (context, state) =>
          _slidePage(const InventoryScreen(), state),
    ),
    GoRoute(
      path: RouteNames.reservations,
      pageBuilder: (context, state) =>
          _slidePage(const ReservationsScreen(), state),
    ),
    GoRoute(
      path: RouteNames.users,
      pageBuilder: (context, state) => _slidePage(const UsersScreen(), state),
    ),
  ],
  errorPageBuilder: (context, state) => _fadePage(const LoginScreen(), state),
);

class AppRoutes {
  static void navigate(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    context.push(routeName, extra: arguments);
  }

  static void navigateAndReplace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    context.pushReplacement(routeName, extra: arguments);
  }

  static void navigateAndClearStack(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    context.go(routeName, extra: arguments);
  }

  static Future<T?> pushWithSlide<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => page,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  static Future<T?> pushWithSlideUp<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => page,
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
