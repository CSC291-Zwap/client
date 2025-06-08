// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dio_client.dart'; // Import your dio_client

class ItemApiService {
  final Dio dio = ApiService().dio;

  Future<Map<String, dynamic>> createItem(Map<String, dynamic> itemData) async {
    try {
      final box = Hive.box('authBox');
      final token = box.get('auth_token');

      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await dio.post(
        '/items/new',
        data: itemData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('Item created successfully: ${response.data}');

      return {
        'success': true,
        'data': response.data,
        'message': 'Item created successfully',
      };
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to create item',
        };
      } else {
        return {'success': false, 'message': 'Network error: ${e.message}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getUserItems(String userId) async {
    try {
      final box = Hive.box('authBox');
      final token = box.get('auth_token');

      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await dio.get(
        '/api/items/user/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to fetch items',
        };
      } else {
        return {'success': false, 'message': 'Network error: ${e.message}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getAllItems({
    String? category,
    String? search,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await dio.get(
        '/items/all',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print(
        'Fetched all items successfully: ${response.data['data'][1]['images']}',
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to fetch items',
        };
      } else {
        return {'success': false, 'message': 'Network error: ${e.message}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: ${e.toString()}'};
    }
  }
}
