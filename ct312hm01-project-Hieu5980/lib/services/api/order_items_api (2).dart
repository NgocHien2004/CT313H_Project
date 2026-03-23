import 'package:dio/dio.dart';
import 'api_services.dart';

class OrderItemsAPI {
  final Dio _dio = ApiServices().dio;

  Future<Response> getByOrderId(int orderId) =>
      _dio.get('/order-items/order/$orderId');

  Future<Response> create(Map<String, dynamic> data) =>
      _dio.post('/order-items', data: data);

  Future<Response> update(int id, Map<String, dynamic> data) =>
      _dio.put('/order-items/$id', data: data);

  Future<Response> delete(int id) => _dio.delete('/order-items/$id');
}
