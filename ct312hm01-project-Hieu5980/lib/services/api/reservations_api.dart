import 'package:dio/dio.dart';
import 'api_services.dart';

class ReservationsAPI {
  final Dio _dio = ApiServices().dio;

  Future<Response> getAll({Map<String, dynamic>? params}) =>
      _dio.get('/reservations', queryParameters: params);

  Future<Response> create(Map<String, dynamic> data) =>
      _dio.post('/reservations', data: data);

  Future<Response> update(int id, Map<String, dynamic> data) =>
      _dio.put('/reservations/$id', data: data);

  Future<Response> delete(int id) => _dio.delete('/reservations/$id');
}
