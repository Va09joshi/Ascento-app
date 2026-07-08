import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';

class ExamsRepository {
  final DioClient _dioClient;

  ExamsRepository(this._dioClient);

  Future<List<ExamSchedule>> getExams() async {
    try {
      final response = await _dioClient.get('/exams');
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => ExamSchedule.fromJson(json))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch exams');
    } catch (e) {
      AppLogger.error('Failed to get exams', e);
      rethrow;
    }
  }

  Future<ExamSchedule> createExam(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post('/exams', data: data);
      if (response.data['success'] == true) {
        return ExamSchedule.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create exam');
    } catch (e) {
      AppLogger.error('Failed to create exam', e);
      rethrow;
    }
  }

  Future<ExamSchedule> updateExam(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.patch('/exams/$id', data: data);
      if (response.data['success'] == true) {
        return ExamSchedule.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update exam');
    } catch (e) {
      AppLogger.error('Failed to update exam', e);
      rethrow;
    }
  }

  Future<void> deleteExam(String id) async {
    try {
      final response = await _dioClient.delete('/exams/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete exam');
      }
    } catch (e) {
      AppLogger.error('Failed to delete exam', e);
      rethrow;
    }
  }
}

final examsRepositoryProvider = Provider<ExamsRepository>((ref) {
  return ExamsRepository(ref.watch(dioClientProvider));
});
