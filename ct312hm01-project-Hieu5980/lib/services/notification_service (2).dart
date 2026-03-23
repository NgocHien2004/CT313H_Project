import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/inventory.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  final Set<String> _notifiedIds = {};

  Future<void> init() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  Future<void> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'low_stock_channel',
      'Cảnh báo tồn kho',
      channelDescription: 'Thông báo khi nguyên liệu sắp hết',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _plugin.show(id, title, body, details);
  }

  Future<void> checkAndNotifyLowStock({
    required List<Inventory> inventoryList,
    required bool isAdmin,
  }) async {
    if (!isAdmin) return;
    if (!_initialized) await init();

    for (final item in inventoryList) {
      if (item.isDeleted) continue;
      final key = item.id ?? item.name;

      if (item.quantity <= item.minQuantity) {
        if (!_notifiedIds.contains(key)) {
          _notifiedIds.add(key);
          await _showNotification(
            id: key.hashCode.abs() % 100000,
            title: '⚠️ Tồn kho thấp: ${item.name}',
            body:
                'Còn ${item.quantity} ${item.unit ?? ''} — tối thiểu ${item.minQuantity} ${item.unit ?? ''}',
          );
          await Future.delayed(const Duration(milliseconds: 300));
        }
      } else {
        _notifiedIds.remove(key);
      }
    }
  }
}
