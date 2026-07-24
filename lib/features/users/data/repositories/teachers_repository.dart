import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:dio/dio.dart';

class TeachersRepository {
  final DioClient _dioClient;

  TeachersRepository(this._dioClient);

  Future<List<UserModel>> getTeachers() async {
    final response = await _dioClient.get('/teachers');
    final data = response.data['data'] as List;
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<UserModel> createTeacher(Map<String, dynamic> teacherData) async {
    final formData = FormData.fromMap(teacherData);
    final response = await _dioClient.post('/teachers', data: formData);
    return UserModel.fromJson(response.data['data']);
  }

  Future<UserModel> updateTeacher(String id, Map<String, dynamic> teacherData) async {
    final formData = FormData.fromMap(teacherData);
    final response = await _dioClient.patch('/teachers/$id', data: formData);
    return UserModel.fromJson(response.data['data']);
  }

  Future<void> deactivateTeacher(String id) async {
    await _dioClient.delete('/teachers/$id');
  }
}
