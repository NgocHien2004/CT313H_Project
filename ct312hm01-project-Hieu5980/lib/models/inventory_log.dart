class InventoryLog {
  final String? id;
  final int inventoryId;
  final int quantityAdded;
  final String? note;
  final DateTime? createdAt;

  InventoryLog({
    this.id,
    required this.inventoryId,
    required this.quantityAdded,
    this.note,
    this.createdAt,
  });

  factory InventoryLog.fromJson(Map<String, dynamic> j) => InventoryLog(
    id: j['id']?.toString(),
    inventoryId: int.tryParse(j['inventory_id'].toString()) ?? 0,
    quantityAdded: int.tryParse(j['quantity_added'].toString()) ?? 0,
    note: j['note'],
    createdAt: j['created_at'] != null
        ? DateTime.tryParse(j['created_at'].toString())
        : null,
  );
}
