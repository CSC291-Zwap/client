import 'package:client/services/dio_client.dart';
import 'package:dio/dio.dart';

class AuthApiService {
  late final Dio dio;

  AuthApiService() {
    try {
      print('AuthApiService: Initializing with ApiService');
      dio = ApiService().dio;
      print('AuthApiService: Successfully initialized');
      print('AuthApiService: Base URL = ${dio.options.baseUrl}');
    } catch (e) {
      print('AuthApiService: Critical error during initialization: $e');
      print('AuthApiService: Stack trace: ${StackTrace.current}');
      rethrow; // This will cause the provider to fail
    }
  }

  Future<Response> signup(Map<String, dynamic> data) async {
    try {
      print(
        'AuthApiService: Attempting signup to ${dio.options.baseUrl}/auth/signup',
      );
      print('AuthApiService: Data: $data');

      final response = await dio.post('/auth/signup', data: data);
      print('AuthApiService: Signup successful');
      return response;
    } catch (e) {
      print('AuthApiService: Signup failed: $e');
      if (e is DioException) {
        print('AuthApiService: DioException type: ${e.type}');
        print('AuthApiService: DioException message: ${e.message}');
        if (e.response != null) {
          print('AuthApiService: Response status: ${e.response?.statusCode}');
          print('AuthApiService: Response data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }

  Future<Response> login(Map<String, dynamic> data) async {
    try {
      print(
        'AuthApiService: Attempting login to ${dio.options.baseUrl}/auth/login',
      );
      print(
        'AuthApiService: Data: ${data.keys.join(', ')}',
      ); // Don't log password

      final response = await dio.post('/auth/login', data: data);
      print('AuthApiService: Login successful');
      return response;
    } catch (e) {
      print('AuthApiService: Login failed: $e');
      if (e is DioException) {
        print('AuthApiService: DioException type: ${e.type}');
        print('AuthApiService: DioException message: ${e.message}');
        if (e.response != null) {
          print('AuthApiService: Response status: ${e.response?.statusCode}');
          print('AuthApiService: Response data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }
}
