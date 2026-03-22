import 'package:dio/dio.dart';
import 'api_services.dart';

class DishIngredientsAPI {
  final Dio _dio = ApiServices().dio;

  Future<Response> getByDishId(int dishId) =>
      _dio.get('/dish-ingredients/dish/$dishId');

  Future<Response> create(Map<String, dynamic> data) =>
      _dio.post('/dish-ingredients', data: data);

  Future<Response> update(int id, Map<String, dynamic> data) =>
      _dio.put('/dish-ingredients/$id', data: data);

  Future<Response> delete(int id) => _dio.delete('/dish-ingredients/$id');
}
