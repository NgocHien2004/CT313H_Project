import 'package:dio/dio.dart';
import 'api_services.dart';

class DishesAPI {
  final Dio _dio = ApiServices().dio;

  Future<Response> getAll({Map<String, dynamic>? params}) =>
      _dio.get('/dishes', queryParameters: params);

  Future<Response> getDetail(int id) => _dio.get('/dishes/$id/detail');

  Future<Response> create(FormData formData) =>
      _dio.post('/dishes', data: formData);

  Future<Response> update(int id, FormData formData) =>
      _dio.put('/dishes/$id', data: formData);

  Future<Response> delete(int id) => _dio.delete('/dishes/$id');
}
