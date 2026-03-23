import 'package:dio/dio.dart';
import 'api_services.dart';

class AuthAPI {
  final Dio _dio = ApiServices().dio;

  Future<Response> login(Map<String, dynamic> data) =>
      _dio.post('/auth/login', data: data);

  Future<Response> register(Map<String, dynamic> data) =>
      _dio.post('/auth/register', data: data);
}
