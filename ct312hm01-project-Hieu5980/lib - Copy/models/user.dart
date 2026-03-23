class User {
  final String? id;
  final String name;
  final String email;
  final String role;
  final bool isDeleted;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isDeleted = false,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['id']?.toString(),
    name: j['name'] ?? '',
    email: j['email'] ?? '',
    role: j['role'] ?? 'user',
    isDeleted: j['is_deleted'] ?? false,
  );
}
