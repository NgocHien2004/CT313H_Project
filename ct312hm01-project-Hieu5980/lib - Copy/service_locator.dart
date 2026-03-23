import 'package:get_it/get_it.dart';
import 'services/api/auth_api.dart';
import 'services/api/user_api.dart';
import 'services/api/dishes_api.dart';
import 'services/api/categories_api.dart';
import 'services/api/orders_api.dart';
import 'services/api/order_items_api.dart';
import 'services/api/inventory_api.dart';
import 'services/api/inventory_logs_api.dart';
import 'services/api/reservations_api.dart';
import 'services/api/dish_ingredients_api.dart';
import 'services/notification_service.dart';

final GetIt sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<AuthAPI>(() => AuthAPI());
  sl.registerLazySingleton<UserAPI>(() => UserAPI());
  sl.registerLazySingleton<DishesAPI>(() => DishesAPI());
  sl.registerLazySingleton<CategoriesAPI>(() => CategoriesAPI());
  sl.registerLazySingleton<OrdersAPI>(() => OrdersAPI());
  sl.registerLazySingleton<OrderItemsAPI>(() => OrderItemsAPI());
  sl.registerLazySingleton<InventoryAPI>(() => InventoryAPI());
  sl.registerLazySingleton<InventoryLogsAPI>(() => InventoryLogsAPI());
  sl.registerLazySingleton<ReservationsAPI>(() => ReservationsAPI());
  sl.registerLazySingleton<DishIngredientsAPI>(() => DishIngredientsAPI());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
}
