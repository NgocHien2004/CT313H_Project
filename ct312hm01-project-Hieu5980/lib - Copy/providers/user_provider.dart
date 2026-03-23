import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  String _userName = '';
  String _userId = '';
  String _userRole = '';

  String get userName => _userName;
  String get userId => _userId;
  String get userRole => _userRole;
  bool get isAdmin => _userRole == 'admin';
  bool get isLoggedIn => _userId.isNotEmpty;

  Future<void> loadFromStorage() async {
    _userName = await _storage.read(key: 'user_name') ?? '';
    _userId = await _storage.read(key: 'user_id') ?? '';
    _userRole = await _storage.read(key: 'user_role') ?? '';
    notifyListeners();
  }

  Future<void> setUser({
    required String id,
    required String name,
    required String role,
    required String token,
  }) async {
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'user_id', value: id);
    await _storage.write(key: 'user_name', value: name);
    await _storage.write(key: 'user_role', value: role);

    _userId = id;
    _userName = name;
    _userRole = role;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _userName = '';
    _userId = '';
    _userRole = '';
    notifyListeners();
  }
}
