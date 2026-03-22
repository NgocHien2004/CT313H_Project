import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/app_config.dart';

class ApiServices {
  static final ApiServices _instance = ApiServices._internal();
  factory ApiServices() => _instance;

  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  ApiServices._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            debugPrint('[API] \${options.method} \${options.path}');
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          if (kDebugMode) {
            debugPrint(
              '[API ERR] \${e.requestOptions.path} \${e.response?.statusCode}',
            );
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<String?> get token => _storage.read(key: 'token');
  Future<String?> get userRole => _storage.read(key: 'user_role');
  Future<String?> get userId => _storage.read(key: 'user_id');
  Future<bool> get isAdmin async => (await userRole) == 'admin';
}
