import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';

class UsersRepository {
  final DioClient _dioClient;

  UsersRepository(this._dioClient);

  Future<List<UserModel>> fetchUsers(String role) async {
    try {
      final response = await _dioClient.get('/admin/users', queryParameters: {
        'role': role,
        'is_active': true,
      });

      final List data = response.data['data'] ?? [];
      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Failed to fetch users for role $role', e);
      throw Exception('Failed to load users.');
    }
  }

  Future<UserModel> createUser(Map<String, dynamic> payload) async {
    try {
      final response = await _dioClient.post('/admin/users', data: payload);
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Failed to create user', e);
      if (e is DioException && e.response?.data != null) {
        final errorMap = e.response!.data['error'];
        if (errorMap != null && errorMap['message'] != null) {
          throw Exception(errorMap['message']);
        }
      }
      throw Exception('Failed to create user.');
    }
  }

  Future<UserModel> updateUser(String id, Map<String, dynamic> payload) async {
    try {
      final response = await _dioClient.patch('/admin/users/$id', data: payload);
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Failed to update user', e);
      if (e is DioException && e.response?.data != null) {
        final errorMap = e.response!.data['error'];
        if (errorMap != null && errorMap['message'] != null) {
          throw Exception(errorMap['message']);
        }
      }
      throw Exception('Failed to update user.');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _dioClient.delete('/admin/users/$id');
    } catch (e) {
      AppLogger.error('Failed to delete user', e);
      if (e is DioException && e.response?.data != null) {
        final errorMap = e.response!.data['error'];
        if (errorMap != null && errorMap['message'] != null) {
          throw Exception(errorMap['message']);
        }
      }
      throw Exception('Failed to delete user.');
    }
  }
}

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return UsersRepository(dioClient);
});
