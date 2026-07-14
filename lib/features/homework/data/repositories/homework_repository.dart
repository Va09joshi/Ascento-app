import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/core/constants/api_endpoints.dart';

class HomeworkRepository {
  final DioClient _dioClient;

  HomeworkRepository(this._dioClient);

  Future<List<HomeworkItem>> getHomeworks({String? classId, String? sectionId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (classId != null) queryParams['class_id'] = classId;
      if (sectionId != null) queryParams['section_id'] = sectionId;

      final response = await _dioClient.get(ApiEndpoints.homework, queryParameters: queryParams);
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => HomeworkItem.fromJson(json))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch homework');
    } catch (e) {
      AppLogger.error('Failed to get homeworks', e);
      rethrow;
    }
  }

  Future<HomeworkItem> createHomework(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post(ApiEndpoints.homework, data: data);
      if (response.data['success'] == true) {
        return HomeworkItem.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create homework');
    } catch (e) {
      AppLogger.error('Failed to create homework', e);
      rethrow;
    }
  }

  Future<void> submitHomework(String homeworkId, String fileUrl) async {
    try {
      final response = await _dioClient.post(
        '${ApiEndpoints.homework}/$homeworkId/submit',
        data: {'file_url': fileUrl},
      );
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to submit homework');
      }
    } catch (e) {
      AppLogger.error('Failed to submit homework', e);
      rethrow;
    }
  }

  Future<void> gradeHomework(String submissionId, int grade, String? remarks) async {
    try {
      final response = await _dioClient.patch(
        '${ApiEndpoints.homework}/submissions/$submissionId/grade',
        data: {'grade': grade, 'remarks': remarks},
      );
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to grade homework');
      }
    } catch (e) {
      AppLogger.error('Failed to grade homework', e);
      rethrow;
    }
  }
}

final homeworkRepositoryProvider = Provider<HomeworkRepository>((ref) {
  return HomeworkRepository(ref.watch(dioClientProvider));
});
