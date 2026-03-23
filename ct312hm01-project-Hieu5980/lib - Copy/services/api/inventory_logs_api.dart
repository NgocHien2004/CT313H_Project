import 'package:dio/dio.dart';
import 'api_services.dart';

class InventoryLogsAPI {
  final Dio _dio = ApiServices().dio;

  Future<Response> getAll({Map<String, dynamic>? params}) =>
      _dio.get('/inventory-logs', queryParameters: params);

  Future<Response> create(Map<String, dynamic> data) =>
      _dio.post('/inventory-logs', data: data);
}
