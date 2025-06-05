import 'package:client/services/dio_client.dart';
import 'package:dio/dio.dart';

class ProfileService {
  final Dio dio = ApiService().dio;

  Future<Map<String, dynamic>?> getProfile(String token) async {
    final response = await dio.get(
      '/user/profile',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.data != null && response.data['user'] != null) {
      return response.data['user'];
    }
    return null;
  }

  Future<bool> updateName(String token, String name) async {
    final response = await dio.patch(
      '/user/update-name',
      data: {'name': name},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['msg'] == 'Name updated successfully!';
  }
}
