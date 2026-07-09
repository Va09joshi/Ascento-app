import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/shared/models/notice_model.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';

class NoticesRepository {
  final DioClient _dio;

  NoticesRepository(this._dio);

  Future<List<NoticeModel>> getNotices() async {
    try {
      final response = await _dio.get('/notices');
      if (response.data['status'] == 'success' && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((e) => NoticeModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('Failed to get notices', e);
      rethrow;
    }
  }

  Future<NoticeModel> createNotice(dynamic data) async {
    try {
      final response = await _dio.post('/notices', data: data);
      if (response.data['status'] == 'success' && response.data['data'] != null) {
        return NoticeModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to parse created notice');
    } catch (e) {
      AppLogger.error('Failed to create notice', e);
      rethrow;
    }
  }

  Future<NoticeModel> updateNotice(String id, dynamic data) async {
    try {
      final response = await _dio.patch('/notices/$id', data: data);
      if (response.data['status'] == 'success' && response.data['data'] != null) {
        return NoticeModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to parse updated notice');
    } catch (e) {
      AppLogger.error('Failed to update notice', e);
      rethrow;
    }
  }

  Future<void> deleteNotice(String id) async {
    try {
      final response = await _dio.delete('/notices/$id');
      if (response.data['status'] != 'success') {
        throw Exception('Failed to delete notice');
      }
    } catch (e) {
      AppLogger.error('Failed to delete notice', e);
      rethrow;
    }
  }
}

final noticesRepositoryProvider = Provider<NoticesRepository>((ref) {
  return NoticesRepository(ref.watch(dioClientProvider));
});
