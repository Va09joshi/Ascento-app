import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/core/constants/api_endpoints.dart';

class ContentRepository {
  final DioClient _dioClient;

  ContentRepository(this._dioClient);

  Future<List<ContentItem>> getContent({String? classId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (classId != null) queryParams['class_id'] = classId;

      final response = await _dioClient.get(ApiEndpoints.content, queryParameters: queryParams);
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => ContentItem.fromJson(json))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch content');
    } catch (e) {
      AppLogger.error('Failed to get content', e);
      rethrow;
    }
  }

  Future<ContentItem> createContent(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post(ApiEndpoints.content, data: data);
      if (response.data['success'] == true) {
        return ContentItem.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create content');
    } catch (e) {
      AppLogger.error('Failed to create content', e);
      rethrow;
    }
  }

  Future<void> updateContent(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put('${ApiEndpoints.content}/$id', data: data);
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to update content');
      }
    } catch (e) {
      AppLogger.error('Failed to update content', e);
      rethrow;
    }
  }

  Future<void> deleteContent(String id) async {
    try {
      final response = await _dioClient.delete('${ApiEndpoints.content}/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete content');
      }
    } catch (e) {
      AppLogger.error('Failed to delete content', e);
      rethrow;
    }
  }

  Future<String> uploadDocument(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dioClient.post(ApiEndpoints.uploadDocument, data: formData);
      if (response.data['success'] == true) {
        return response.data['data']['url']; // Assuming the API returns the URL in data.url
      }
      throw Exception(response.data['message'] ?? 'Failed to upload document');
    } catch (e) {
      AppLogger.error('Failed to upload document', e);
      rethrow;
    }
  }
}

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository(ref.watch(dioClientProvider));
});
