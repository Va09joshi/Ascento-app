import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository(ref.watch(dioClientProvider));
});
