import 'package:dio/dio.dart';
import 'api_services.dart';

class CategoriesAPI {
  final Dio _dio = ApiServices().dio;

  Future<Response> getAll() => _dio.get('/categories');

  Future<Response> create(Map<String, dynamic> data) =>
      _dio.post('/categories', data: data);

  Future<Response> update(int id, Map<String, dynamic> data) =>
      _dio.put('/categories/$id', data: data);

  Future<Response> delete(int id) => _dio.delete('/categories/$id');
}
