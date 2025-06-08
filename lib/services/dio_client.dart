import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:3000'; // Web
    } else if (Platform.isAndroid) {
      return 'http://192.168.1.133:3000';
      // return 'http://10.0.2.2:3000'; // Android Emulator
    } else {
      return 'http://localhost:3000'; // iOS Simulator/Mac/Windows
    }
  }

  // Usage:
  static final String _BaseUrl = getBaseUrl();

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
