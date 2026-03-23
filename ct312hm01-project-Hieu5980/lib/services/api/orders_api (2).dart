import 'package:dio/dio.dart';
import 'api_services.dart';

class OrdersAPI {
  final Dio _dio = ApiServices().dio;

  Future<Response> getAll({Map<String, dynamic>? params}) =>
      _dio.get('/orders', queryParameters: params);

  Future<Response> getById(int id) => _dio.get('/orders/$id');

  Future<Response> create(Map<String, dynamic> data) =>
      _dio.post('/orders', data: data);

  Future<Response> update(int id, Map<String, dynamic> data) =>
      _dio.put('/orders/$id', data: data);

  Future<Response> delete(int id) => _dio.delete('/orders/$id');
}
