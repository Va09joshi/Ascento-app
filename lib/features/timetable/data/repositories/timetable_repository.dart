import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';

class TimetableRepository {
  final DioClient _dioClient;

  TimetableRepository(this._dioClient);

  Future<List<TimetableSlot>> getSectionTimetable(String sectionId) async {
    try {
      final response = await _dioClient.get('/timetable/section/$sectionId');
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => TimetableSlot.fromJson(json))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch timetable');
    } catch (e) {
      AppLogger.error('Failed to get section timetable', e);
      rethrow;
    }
  }

  Future<List<TimetableSlot>> getTeacherTimetable(String teacherId) async {
    try {
      final response = await _dioClient.get('/timetable/teacher/$teacherId');
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => TimetableSlot.fromJson(json))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch timetable');
    } catch (e) {
      AppLogger.error('Failed to get teacher timetable', e);
      rethrow;
    }
  }

  Future<void> createTimetableSlot(Map<String, dynamic> payload) async {
    try {
      final response = await _dioClient.post('/timetable', data: payload);
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to create slot');
      }
    } catch (e) {
      AppLogger.error('Failed to create timetable slot', e);
      rethrow;
    }
  }

  Future<void> deleteTimetableSlot(String slotId) async {
    try {
      final response = await _dioClient.delete('/timetable/$slotId');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete slot');
      }
    } catch (e) {
      AppLogger.error('Failed to delete timetable slot', e);
      rethrow;
    }
  }
}

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  return TimetableRepository(ref.watch(dioClientProvider));
});
