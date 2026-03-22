import 'package:dio/dio.dart';
import 'api_services.dart';

class InventoryAPI {
  final Dio _dio = ApiServices().dio;

  Future<Response> getAll({Map<String, dynamic>? params}) =>
      _dio.get('/inventory', queryParameters: params);

  Future<Response> create(Map<String, dynamic> data) =>
      _dio.post('/inventory', data: data);

  Future<Response> update(int id, Map<String, dynamic> data) =>
      _dio.put('/inventory/$id', data: data);

  Future<Response> delete(int id) => _dio.delete('/inventory/$id');
}
