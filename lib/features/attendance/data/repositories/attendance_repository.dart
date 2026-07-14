import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/core/constants/api_endpoints.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';

final attendanceRepositoryProvider = Provider((ref) {
  return AttendanceRepository(ref.watch(dioClientProvider));
});

class AttendanceRepository {
  final DioClient _dioClient;

  AttendanceRepository(this._dioClient);

  Future<void> markBulkAttendance(String sectionId, DateTime date, List<Map<String, dynamic>> records) async {
    await _dioClient.post(ApiEndpoints.attendanceBulk, data: {
      'section_id': sectionId,
      'date': date.toIso8601String().split('T')[0],
      'records': records,
    });
  }

  Future<List<AttendanceRecord>> getAttendanceSheet(String sectionId, DateTime startDate, DateTime endDate) async {
    final response = await _dioClient.get(ApiEndpoints.attendanceSheet, queryParameters: {
      'section_id': sectionId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
    });
    return (response.data['data'] as List)
        .map((e) => AttendanceRecord.fromJson(e))
        .toList();
  }
}
