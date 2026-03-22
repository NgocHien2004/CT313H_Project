class OrderItem {
  final String? id;
  final int orderId;
  final int dishId;
  final int quantity;
  final double price;
  final String? dishName;

  OrderItem({
    this.id,
    required this.orderId,
    required this.dishId,
    required this.quantity,
    required this.price,
    this.dishName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    id: j['id']?.toString(),
    orderId: int.tryParse(j['order_id'].toString()) ?? 0,
    dishId: int.tryParse(j['dish_id'].toString()) ?? 0,
    quantity: int.tryParse(j['quantity'].toString()) ?? 0,
    price: double.tryParse(j['price'].toString()) ?? 0.0,
    dishName: j['dish_name'],
  );
}
