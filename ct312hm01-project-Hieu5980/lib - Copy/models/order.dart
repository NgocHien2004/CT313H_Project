import 'order_item.dart';

class Order {
  final String? id;
  final int userId;
  final int tableNumber;
  final double totalAmount;
  final String status;
  final DateTime? createdAt;
  final List<OrderItem> items;

  Order({
    this.id,
    required this.userId,
    required this.tableNumber,
    required this.totalAmount,
    required this.status,
    this.createdAt,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id: j['id']?.toString(),
    userId: int.tryParse(j['user_id'].toString()) ?? 0,
    tableNumber: int.tryParse(j['table_number'].toString()) ?? 0,
    totalAmount: double.tryParse(j['total_amount'].toString()) ?? 0.0,
    status: j['status'] ?? 'pending',
    createdAt: j['created_at'] != null
        ? DateTime.tryParse(j['created_at'].toString())
        : null,
    items: (j['items'] as List? ?? [])
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
