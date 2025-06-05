import 'package:dio/dio.dart';

class ApiService {
  static const String _BaseUrl = 'http://localhost:3000';

  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  late final Dio dio;

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: _BaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }
}
