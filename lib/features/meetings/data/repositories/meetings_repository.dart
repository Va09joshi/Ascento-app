import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/core/constants/api_endpoints.dart';

class MeetingsRepository {
  final DioClient _dioClient;

  MeetingsRepository(this._dioClient);

  Future<List<MeetingItem>> getMeetings({String? classId, String? sectionId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (classId != null) queryParams['class_id'] = classId;
      if (sectionId != null) queryParams['section_id'] = sectionId;

      final response = await _dioClient.get(ApiEndpoints.meetings, queryParameters: queryParams);
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => MeetingItem.fromJson(json))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch meetings');
    } catch (e) {
      AppLogger.error('Failed to get meetings', e);
      rethrow;
    }
  }

  Future<MeetingItem> createMeeting(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post(ApiEndpoints.meetings, data: data);
      if (response.data['success'] == true) {
        return MeetingItem.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create meeting');
    } catch (e) {
      AppLogger.error('Failed to create meeting', e);
      rethrow;
    }
  }
}

final meetingsRepositoryProvider = Provider<MeetingsRepository>((ref) {
  return MeetingsRepository(ref.watch(dioClientProvider));
});
