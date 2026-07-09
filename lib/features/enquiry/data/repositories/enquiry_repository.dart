import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/features/enquiry/data/models/enquiry_model.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';

class EnquiryRepository {
  final DioClient _dioClient;

  EnquiryRepository(this._dioClient);

  Future<List<EnquiryModel>> getEnquiries() async {
    try {
      final response = await _dioClient.get('/enquiries');
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => EnquiryModel.fromJson(json))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch enquiries');
    } catch (e) {
      AppLogger.error('Failed to get enquiries', e);
      rethrow;
    }
  }

  Future<EnquiryModel> updateEnquiry(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put('/enquiries/$id', data: data);
      if (response.data['success'] == true) {
        return EnquiryModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update enquiry');
    } catch (e) {
      AppLogger.error('Failed to update enquiry', e);
      rethrow;
    }
  }

  Future<void> deleteEnquiry(String id) async {
    try {
      final response = await _dioClient.delete('/enquiries/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete enquiry');
      }
    } catch (e) {
      AppLogger.error('Failed to delete enquiry', e);
      rethrow;
    }
  }
}

final enquiryRepositoryProvider = Provider<EnquiryRepository>((ref) {
  return EnquiryRepository(ref.watch(dioClientProvider));
});
