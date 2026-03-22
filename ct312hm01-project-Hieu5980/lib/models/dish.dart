class Dish {
  final String? id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final int categoryId;
  final bool isDeleted;

  Dish({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    required this.categoryId,
    this.isDeleted = false,
  });

  factory Dish.fromJson(Map<String, dynamic> j) => Dish(
    id: j['id']?.toString(),
    name: j['name'] ?? '',
    description: j['description'],
    price: double.tryParse(j['price'].toString()) ?? 0.0,
    imageUrl: j['image_url'],
    isAvailable: j['is_available'] ?? true,
    categoryId: int.tryParse(j['category_id'].toString()) ?? 0,
    isDeleted: j['is_deleted'] ?? false,
  );
}
