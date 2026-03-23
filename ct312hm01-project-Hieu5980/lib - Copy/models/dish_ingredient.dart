class DishIngredient {
  final String? id;
  final int dishId;
  final int inventoryId;
  final double quantityRequired;
  final String? ingredientName;
  final String? ingredientUnit;
  final String? dishName;

  DishIngredient({
    this.id,
    required this.dishId,
    required this.inventoryId,
    required this.quantityRequired,
    this.ingredientName,
    this.ingredientUnit,
    this.dishName,
  });

  factory DishIngredient.fromJson(Map<String, dynamic> j) => DishIngredient(
    id: j['id']?.toString(),
    dishId: int.tryParse(j['dish_id'].toString()) ?? 0,
    inventoryId: int.tryParse(j['inventory_id'].toString()) ?? 0,
    quantityRequired: double.tryParse(j['quantity_required'].toString()) ?? 0,
    ingredientName: j['ingredient_name'],
    ingredientUnit: j['ingredient_unit'],
    dishName: j['dish_name'],
  );
}
