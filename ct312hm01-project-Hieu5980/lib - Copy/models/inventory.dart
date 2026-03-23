class Inventory {
  final String? id;
  final String name;
  final int quantity;
  final String? unit;
  final int minQuantity;
  final bool isDeleted;

  Inventory({
    this.id,
    required this.name,
    required this.quantity,
    this.unit,
    this.minQuantity = 5,
    this.isDeleted = false,
  });

  factory Inventory.fromJson(Map<String, dynamic> j) => Inventory(
    id: j['id']?.toString(),
    name: j['name'] ?? '',
    quantity: int.tryParse(j['quantity'].toString()) ?? 0,
    unit: j['unit'],
    minQuantity: int.tryParse(j['min_quantity'].toString()) ?? 5,
    isDeleted: j['is_deleted'] ?? false,
  );
}
