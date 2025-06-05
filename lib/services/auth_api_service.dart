import 'package:client/services/dio_client.dart';
import 'package:dio/dio.dart';

class AuthApiService {
  final Dio dio = ApiService().dio;

  Future<Response> signup(Map<String, dynamic> data) async {
    return await dio.post('/auth/signup', data: data);
  }

  Future<Response> login(Map<String, dynamic> data) async {
    return await dio.post('/auth/login', data: data);
  }

}