import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/services/profile_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(),
);

final profileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final box = Hive.box('authBox');
  final token = box.get('auth_token');
  if (token == null) return null;
  final service = ref.read(profileServiceProvider);
  return await service.getProfile(token);
});
