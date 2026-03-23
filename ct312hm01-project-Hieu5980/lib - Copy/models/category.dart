class Category {
  final String? id;
  final String name;
  final String? description;
  final bool isDeleted;

  Category({
    this.id,
    required this.name,
    this.description,
    this.isDeleted = false,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
    id: j['id']?.toString(),
    name: j['name'] ?? '',
    description: j['description'],
    isDeleted: j['is_deleted'] ?? false,
  );
}
