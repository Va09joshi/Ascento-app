import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/core/network/api_exception.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
class UsersRepository {
  final DioClient _dioClient;

  UsersRepository(this._dioClient);

  Future<List<UserModel>> fetchUsers(String role) async {
    try {
      final response = await _dioClient.get('/admin/users', queryParameters: {
        'role': role,
      });

      final List data = response.data['data'] ?? [];
      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Failed to fetch users for role $role', e);
      throw Exception('Failed to load users.');
    }
  }

  Future<UserModel> createUser(Map<String, dynamic> payload, {String? avatarPath}) async {
    try {
      dynamic data = payload;
      if (avatarPath != null) {
        final formData = FormData.fromMap(payload);
        formData.files.add(MapEntry('avatar', await MultipartFile.fromFile(avatarPath)));
        data = formData;
      }
      final response = await _dioClient.post('/admin/users', data: data);
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Failed to create user', e);
      if (e is ApiException) {
        if (e.message.contains('duplicate key value violates unique constraint')) {
          throw Exception('A user with this ID or email already exists.');
        }
        throw Exception(e.message);
      }
      throw Exception('Failed to create user.');
    }
  }

  Future<UserModel> updateUser(String id, Map<String, dynamic> payload, {String? avatarPath}) async {
    try {
      dynamic data = payload;
      if (avatarPath != null) {
        final formData = FormData.fromMap(payload);
        formData.files.add(MapEntry('avatar', await MultipartFile.fromFile(avatarPath)));
        data = formData;
      }
      final response = await _dioClient.patch('/admin/users/$id', data: data);
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Failed to update user', e);
      if (e is ApiException) {
        if (e.message.contains('duplicate key value violates unique constraint')) {
          throw Exception('A user with this ID or email already exists.');
        }
        throw Exception(e.message);
      }
      throw Exception('Failed to update user.');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _dioClient.delete('/admin/users/$id');
    } catch (e) {
      AppLogger.error('Failed to delete user', e);
      if (e is ApiException) {
        throw Exception(e.message);
      }
      throw Exception('Failed to delete user.');
    }
  }
}

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return UsersRepository(dioClient);
});
