import 'package:dio/dio.dart';
import 'api_services.dart';

class UserAPI {
  final Dio _dio = ApiServices().dio;

  Future<Response> getAll({Map<String, dynamic>? params}) =>
      _dio.get('/users', queryParameters: params);

  Future<Response> create(Map<String, dynamic> data) =>
      _dio.post('/users', data: data);

  Future<Response> update(int id, Map<String, dynamic> data) =>
      _dio.put('/users/$id', data: data);

  Future<Response> delete(int id) => _dio.delete('/users/$id');
}
